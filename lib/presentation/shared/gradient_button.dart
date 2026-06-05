import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final IconData? icon;
  final double? width;
  final List<Color>? colors;
  final double fontSize;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.outlined = false,
    this.icon,
    this.width,
    this.colors,
    this.fontSize = 15,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cols = widget.colors ?? [AppColors.purple, AppColors.blue];
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width,
          transform: Matrix4.identity()
            ..scale(_pressed ? 0.95 : (_hovered ? 1.04 : 1.0)),
          transformAlignment: Alignment.center,
          decoration: widget.outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: _hovered
                        ? AppColors.purple
                        : Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  color: _hovered ? AppColors.purple.withOpacity(0.12) : Colors.transparent,
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: LinearGradient(colors: cols),
                  boxShadow: [
                    BoxShadow(
                      color: cols.first.withOpacity(_hovered ? 0.55 : 0.3),
                      blurRadius: _hovered ? 28 : 14,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
