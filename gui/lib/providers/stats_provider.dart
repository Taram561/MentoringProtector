import 'package:flutter/material.dart';
import 'dart:convert';
import '../ffi/core_bindings.dart';
import '../models/threat_stats.dart';
import '../models/scan_history.dart';
import '../models/threat_sources_aggregate.dart';

class StatsProvider extends ChangeNotifier {
  ThreatStats? _threatStats;
  ScanHistory? _scanHistory;
  ThreatSourcesAggregate? _threatSources;
  String? _statsError;
  int _statsPeriodDays = 30;

  ThreatStats? get threatStats => _threatStats;
  ScanHistory? get scanHistory => _scanHistory;
  ThreatSourcesAggregate? get threatSources => _threatSources;
  String? get statsError => _statsError;
  int get statsPeriodDays => _statsPeriodDays;

  Future<void> refreshStats(int days) async {
    _statsPeriodDays = days;

    if (!CoreBindings.isInitialized) {
      _statsError = 'core_not_ready';
      _threatStats = ThreatStats.empty(days);
      _scanHistory = ScanHistory.empty(days);
      _threatSources = ThreatSourcesAggregate.empty(days);
      notifyListeners();
      return;
    }

    _statsError = null;
    final b = CoreBindings.instance;

    try {
      final threatJson = b.callGetThreatStats(days);
      if (threatJson != null) {
        _threatStats = ThreatStats.fromJson(jsonDecode(threatJson) as Map<String, dynamic>);
      } else {
        _threatStats = ThreatStats.empty(days);
      }
    } on FormatException catch (e) {
      debugPrint('[MP] Stats: threat backend error: $e');
      _statsError = e.toString();
      _threatStats = ThreatStats.empty(days);
    } catch (e) {
      debugPrint('[MP] Stats: threat fetch error: $e');
      _threatStats = ThreatStats.empty(days);
    }

    try {
      final scanJson = b.callGetScanHistory(days);
      if (scanJson != null) {
        _scanHistory = ScanHistory.fromJson(jsonDecode(scanJson) as Map<String, dynamic>);
      } else {
        _scanHistory = ScanHistory.empty(days);
      }
    } on FormatException catch (e) {
      debugPrint('[MP] Stats: scan backend error: $e');
      _statsError = e.toString();
      _scanHistory = ScanHistory.empty(days);
    } catch (e) {
      debugPrint('[MP] Stats: scan fetch error: $e');
      _scanHistory = ScanHistory.empty(days);
    }

    try {
      final sourcesJson = b.callGetThreatSources(days);
      if (sourcesJson != null) {
        _threatSources = ThreatSourcesAggregate.fromJson(jsonDecode(sourcesJson) as Map<String, dynamic>);
      } else {
        _threatSources = ThreatSourcesAggregate.empty(days);
      }
    } on FormatException catch (e) {
      debugPrint('[MP] Stats: sources backend error: $e');
      _statsError = e.toString();
      _threatSources = ThreatSourcesAggregate.empty(days);
    } catch (e) {
      debugPrint('[MP] Stats: sources fetch error: $e');
      _threatSources = ThreatSourcesAggregate.empty(days);
    }

    notifyListeners();
  }
}

