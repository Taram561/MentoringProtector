import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme/app_theme.dart';

class AppTitleBar extends StatelessWidget {
  final String title;
  final AdaptiveColors colors;

  const AppTitleBar({
    super.key,
    required this.title,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: colors.gradientEnd,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/icon.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: AppTextStyles.sizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const WindowControls(),
          ],
        ),
      ),
    );
  }
}

class AppTitleBarScaffold extends StatelessWidget {
  final String title;
  final AdaptiveColors colors;
  final Widget body;

  const AppTitleBarScaffold({
    super.key,
    required this.title,
    required this.colors,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          DragToMoveArea(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: colors.gradientEnd,
              ),
              padding: const EdgeInsets.only(left: 4, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.onPrimary, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      'assets/icon.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: AppTextStyles.sizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const WindowControls(),
                ],
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class WindowControls extends StatefulWidget {
  const WindowControls({super.key});

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    final m = await windowManager.isMaximized();
    if (mounted) setState(() => _isMaximized = m);
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WinBtn(
          icon: Icons.remove_rounded,
          onTap: () => windowManager.minimize(),
          hoverColor: AppColors.onPrimary.withValues(alpha: 0.15),
        ),
        _WinBtn(
          icon: _isMaximized
              ? Icons.filter_none_rounded
              : Icons.crop_square_rounded,
          onTap: () async {
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
          hoverColor: AppColors.onPrimary.withValues(alpha: 0.15),
        ),
        _WinBtn(
          icon: Icons.close_rounded,
          onTap: () => windowManager.close(),
          hoverColor: const Color(0xFFE81123),
        ),
      ],
    );
  }
}

class _WinBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color hoverColor;

  const _WinBtn({
    required this.icon,
    required this.onTap,
    required this.hoverColor,
  });

  @override
  State<_WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<_WinBtn> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 34,
          decoration: BoxDecoration(
            color: _hovering ? widget.hoverColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, color: AppColors.onPrimary, size: 20),
        ),
      ),
    );
  }
}

