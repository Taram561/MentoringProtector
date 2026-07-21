import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'core_bindings.dart';
import 'service_interfaces.dart';
import '../models/scan_result.dart';
import '../models/vulnerability.dart';

class CoreService implements IScannerService {
  static final _scanWorker = _ScanWorker();
  final CoreBindings? _bindings;

  CoreService({CoreBindings? bindings}) : _bindings = bindings ?? (CoreBindings.isInitialized ? CoreBindings.instance : null);

  String get coreVersion => _bindings == null ? '' : _bindings!.callReturningString(_bindings!.getCoreVersion);

  List<String> getActiveEngines() {
    if (_bindings?.getActiveEngines == null) return const [];
    try {
      final json = _bindings!.callReturningString(_bindings!.getActiveEngines!);
      if (json.isEmpty) return const [];
      final map = jsonDecode(json) as Map<String, dynamic>;
      final raw = map['engines'] as List?;
      return raw?.map((e) => e.toString()).toList() ?? const [];
    } catch (e) {
      debugPrint('[MP] getActiveEngines parse error: $e');
      return const [];
    }
  }

  @override
  Future<ScanResult> scanFile(String filePath) async {
    final json = await _scanWorker.scanFile(filePath);
    return _parseScanResult(json, filePath);
  }

  @override
  Future<String> getFileHash(String filePath) async {
    return Future.delayed(Duration.zero, () {
      if (_bindings?.getFileHash == null) return '';
      return _bindings!.callWithOneStringArg(_bindings!.getFileHash!, filePath);
    });
  }

  Future<VulnerabilityReport> scanVulnerabilities() async {
    return Future.delayed(Duration.zero, () {
      if (_bindings?.scanVulnerabilities == null) return VulnerabilityReport(scannedAt: DateTime.now(), osVersion: 'Unknown', vulnerabilities: []);
      final json = _bindings!.callReturningString(_bindings!.scanVulnerabilities!);
      return _parseVulnerabilityReport(json);
    });
  }

  ScanResult _parseScanResult(String jsonStr, String filePath) {
    if (jsonStr.isEmpty) return ScanResult.empty(filePath);
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ScanResult.fromJson(map);
    } catch (e) { debugPrint('[MP] core_service error: $e'); return ScanResult.empty(filePath); }
  }

  VulnerabilityReport _parseVulnerabilityReport(String jsonStr) {
    if (jsonStr.isEmpty) return VulnerabilityReport(scannedAt: DateTime.now(), osVersion: 'Unknown', vulnerabilities: []);
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final vulns = (map['vulnerabilities'] as List? ?? []).map((v) => Vulnerability(id: v['id'] ?? '', title: v['title'] ?? '', description: v['description'] ?? '', severity: v['severity'] ?? 'low', affectedComponent: v['category'] ?? v['affected_component'] ?? '', howToFix: v['how_to_fix'] ?? '', moreInfo: v['more_info'] ?? '', autoFixable: v['auto_fixable'] == true)).toList();
      return VulnerabilityReport(scannedAt: DateTime.now(), osVersion: map['os_version'] ?? map['os'] ?? 'Unknown', vulnerabilities: vulns);
    } catch (e) { debugPrint('[MP] core_service error: $e'); return VulnerabilityReport(scannedAt: DateTime.now(), osVersion: 'Unknown', vulnerabilities: []); }
  }
}

const _scanCommandScanFile = 'scan_file';
const _scanMessageReady = 'ready';
const _scanMessageInitError = 'init_error';
const _scanMessageResult = 'result';
const _scanMessageError = 'error';

final class _ScanWorker {
  Future<SendPort>? _commandPortFuture;
  ReceivePort? _responsePort;
  ReceivePort? _errorPort;
  ReceivePort? _exitPort;
  final Map<int, Completer<String>> _pending = <int, Completer<String>>{};
  int _nextRequestId = 0;

  Future<String> scanFile(String filePath) async {
    final commandPort = await _ensureCommandPort();
    final requestId = _nextRequestId++;
    final completer = Completer<String>();
    _pending[requestId] = completer;
    commandPort.send(<Object>[_scanCommandScanFile, requestId, filePath]);
    return completer.future.timeout(const Duration(seconds: 120), onTimeout: () { _pending.remove(requestId); return '{"error":"scan_timeout","file":"$filePath"}'; });
  }

  Future<SendPort> _ensureCommandPort() {
    final existing = _commandPortFuture;
    if (existing != null) return existing;

    final ready = Completer<SendPort>();
    _commandPortFuture = ready.future;

    final responsePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    _responsePort = responsePort;
    _errorPort = errorPort;
    _exitPort = exitPort;

    responsePort.listen((dynamic message) { _handleResponse(message, ready); });

    errorPort.listen((dynamic message) {
      final error = StateError('Scan worker isolate crashed: $message');
      _failWorker(error);
      if (!ready.isCompleted) ready.completeError(error);
    });

    exitPort.listen((dynamic _) {
      final error = StateError('Scan worker isolate stopped.');
      _failWorker(error);
      if (!ready.isCompleted) ready.completeError(error);
    });

    Isolate.spawn<SendPort>(_scanWorkerMain, responsePort.sendPort, onError: errorPort.sendPort, onExit: exitPort.sendPort, errorsAreFatal: true).then((_) {}, onError: (Object error, StackTrace stackTrace) { _failWorker(error, stackTrace); if (!ready.isCompleted) ready.completeError(error, stackTrace); });

    return ready.future;
  }

  void _handleResponse(dynamic message, Completer<SendPort> ready) {
    if (message is! List || message.isEmpty || message[0] is! String) return;

    switch (message[0] as String) {
      case _scanMessageReady:
        final commandPort = message.length > 1 ? message[1] : null;
        if (commandPort is SendPort && !ready.isCompleted) ready.complete(commandPort);
        return;
      case _scanMessageInitError:
        final error = StateError(message.length > 1 && message[1] is String ? message[1] as String : 'Failed to initialize scan worker isolate.');
        _failWorker(error);
        if (!ready.isCompleted) ready.completeError(error);
        return;
      case _scanMessageResult:
        if (message.length < 3) return;
        final requestId = message[1];
        final json = message[2];
        if (requestId is int) _pending.remove(requestId)?.complete(json is String ? json : '');
        return;
      case _scanMessageError:
        if (message.length < 3) return;
        final requestId = message[1];
        final reason = message[2];
        if (requestId is int) _pending.remove(requestId)?.completeError(StateError(reason is String ? reason : 'Scan worker request failed.'));
        return;
    }
  }

  void _failWorker(Object error, [StackTrace? stackTrace]) {
    final pending = _pending.values.toList(growable: false);
    _pending.clear();
    for (final completer in pending) if (!completer.isCompleted) completer.completeError(error, stackTrace);
    _commandPortFuture = null;
    final rp = _responsePort; _responsePort = null; rp?.close();
    final ep = _errorPort; _errorPort = null; ep?.close();
    final xp = _exitPort; _exitPort = null; xp?.close();
  }
}

void _scanWorkerMain(SendPort responsePort) {
  final initResult = CoreBindings.tryInitialize();
  if (initResult is DllInitFailure) { responsePort.send(<Object>[_scanMessageInitError, initResult.reason]); return; }

  final bindings = CoreBindings.instance;
  if (bindings.coreInitialize != null) try { bindings.callReturningString(bindings.coreInitialize!); } catch (_) {}

  final commandPort = ReceivePort();
  responsePort.send(<Object>[_scanMessageReady, commandPort.sendPort]);

  commandPort.listen((dynamic message) {
    if (message is! List || message.length < 3) return;
    final command = message[0];
    final requestId = message[1];
    final filePath = message[2];
    if (command != _scanCommandScanFile || requestId is! int || filePath is! String) return;
    try { final json = bindings.callWithOneStringArg(bindings.scanFile, filePath); responsePort.send(<Object>[_scanMessageResult, requestId, json]); } catch (error) { responsePort.send(<Object>[_scanMessageError, requestId, '$error']); }
  });
}

