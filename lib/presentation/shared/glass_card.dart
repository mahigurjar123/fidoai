import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;
  final bool enableHover;
  final Color? borderColor;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius,
    this.enableHover = true,
    this.borderColor,
    this.glowColor,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final br = widget.radius ?? BorderRadius.circular(20);
    return MouseRegion(
      onEnter: (_) => widget.enableHover ? setState(() => _hovered = true) : null,
      onExit: (_) => widget.enableHover ? setState(() => _hovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform:
            _hovered ? (Matrix4.identity()..translate(0.0, -6.0)) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: br,
          boxShadow: [
            BoxShadow(
              color: (_hovered
                      ? (widget.glowColor ?? AppColors.purple)
                      : Colors.black)
                  .withOpacity(_hovered ? 0.35 : 0.2),
              blurRadius: _hovered ? 32 : 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: br,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: br,
                gradient: LinearGradient(
                  colors: _hovered
                      ? [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.04),
                        ]
                      : [
                          Colors.white.withOpacity(0.06),
                          Colors.white.withOpacity(0.02),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _hovered
                      ? (widget.borderColor ?? AppColors.purple).withOpacity(0.6)
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
