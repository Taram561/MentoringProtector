import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

abstract final class Snack {
  static const Duration _defaultDuration = Duration(seconds: 2);

  static void error(BuildContext context, String message,
          {Duration? duration}) =>
      _show(context, message, _bg(context, _Kind.error), duration: duration);

  static void success(BuildContext context, String message,
          {Duration? duration}) =>
      _show(context, message, _bg(context, _Kind.success), duration: duration);

  static void info(BuildContext context, String message,
          {Duration? duration}) =>
      _show(context, message, _bg(context, _Kind.info), duration: duration);

  static void _show(BuildContext context, String message, Color? bg,
      {Duration? duration}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? _defaultDuration,
      ),
    );
  }

  static Color? _bg(BuildContext context, _Kind kind) {
    final provider = context.read<AppStateProvider?>();
    if (provider == null) return null;
    final c = provider.colors;
    return switch (kind) {
      _Kind.error   => c.danger,
      _Kind.success => c.success,
      _Kind.info    => c.primary,
    };
  }
}

enum _Kind { error, success, info }

