import 'dart:math';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// FIDO AI — Animated SVG Icon System
// Each icon is drawn using Path (no addOval/addRect) so PathMetrics
// gives a smooth "pen-drawing" animation.
// ═══════════════════════════════════════════════════════════════════

enum FidoIcon {
  chat, image, bolt, shield,
  hub,  globe, star, network,
  brain, settings, person, sparkle,
  flash, lock, trending, diamond,
}

// Convert Material IconData → FidoIcon
FidoIcon fidoIconFrom(IconData icon) {
  const map = <int, FidoIcon>{
    0xe0ca: FidoIcon.chat,      // chat_bubble_rounded
    0xe65d: FidoIcon.sparkle,   // auto_awesome_rounded
    0xe1a7: FidoIcon.bolt,      // bolt_rounded
    0xef64: FidoIcon.shield,    // shield_rounded
    0xe1e3: FidoIcon.hub,       // hub_rounded
    0xe894: FidoIcon.globe,     // language_rounded
    0xe838: FidoIcon.star,      // star_rounded
    0xe86a: FidoIcon.network,   // scatter_plot_rounded
    0xef6e: FidoIcon.diamond,   // lens_blur_rounded
    0xe8e5: FidoIcon.trending,  // trending_up_rounded
    0xe3f7: FidoIcon.flash,     // electric_bolt_rounded
    0xe29a: FidoIcon.sparkle,   // flare_rounded
    0xe7fe: FidoIcon.person,    // person_add_rounded
    0xe429: FidoIcon.settings,  // tune_rounded
    0xe315: FidoIcon.flash,     // flash_on_rounded
    0xef68: FidoIcon.brain,     // psychology_rounded
    0xe3f4: FidoIcon.image,     // image_rounded
    0xe897: FidoIcon.lock,      // lock_rounded
  };
  return map[icon.codePoint] ?? FidoIcon.sparkle;
}

// ── Animated SVG Icon Widget ──────────────────────────────────────
class AnimatedSvgIcon extends StatefulWidget {
  final FidoIcon type;
  final Color color;
  final double size;
  final Duration duration;

  const AnimatedSvgIcon({
    super.key,
    required this.type,
    required this.color,
    this.size = 28,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedSvgIcon> createState() => _AnimatedSvgIconState();
}

class _AnimatedSvgIconState extends State<AnimatedSvgIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _SvgIconPainter(
          type: widget.type,
          color: widget.color,
          t: _ctrl.value,
        ),
        size: Size(widget.size, widget.size),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────
class _SvgIconPainter extends CustomPainter {
  final FidoIcon type;
  final Color color;
  final double t; // 0–1 repeating

  const _SvgIconPainter({required this.type, required this.color, required this.t});

  // Draw-on phase: 0→0.65; hold+pulse phase: 0.65→1.0
  double get _drawPhase  => (t < 0.65) ? t / 0.65 : 1.0;
  double get _pulsePhase => t > 0.65 ? (t - 0.65) / 0.35 : 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final rawPath = _buildIconPath(type);
    final metrics = rawPath.computeMetrics().toList();
    final totalLen = metrics.fold(0.0, (s, m) => s + m.length);
    var remaining = totalLen * _drawPhase;

    final drawnPath = Path();
    for (final m in metrics) {
      if (remaining <= 0) break;
      final take = min(m.length, remaining);
      drawnPath.addPath(m.extractPath(0, take), Offset.zero);
      remaining -= take;
    }

    // Outer glow
    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = color.withOpacity(0.20 + 0.15 * _pulsePhase)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Main stroke
    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = color.withOpacity(0.90 + 0.10 * _pulsePhase)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Icon-specific continuous animations (drawn AFTER path is fully shown)
    if (_drawPhase > 0.8) {
      _drawExtra(canvas, t, color, (_drawPhase - 0.8) / 0.2);
    }

    canvas.restore();
  }

  // Extra icon-specific flourishes
  void _drawExtra(Canvas canvas, double t, Color color, double alpha) {
    final p = Paint()..style = PaintingStyle.fill;

    switch (type) {
      case FidoIcon.hub:
        for (int i = 0; i < 6; i++) {
          final a = i * pi / 3;
          final pulse = (sin(t * 2 * pi * 2 + i * pi / 3) + 1) / 2;
          p.color = color.withOpacity(alpha * (0.4 + 0.5 * pulse));
          canvas.drawCircle(
            Offset(12 + 9 * cos(a), 12 + 9 * sin(a)),
            1.4 + 0.6 * pulse,
            p,
          );
        }
      case FidoIcon.star:
        // Rotating sparkle dot
        final a = t * 2 * pi;
        p.color = color.withOpacity(alpha * 0.8);
        canvas.drawCircle(Offset(12 + 10 * cos(a), 12 + 10 * sin(a)), 1.2, p);
      case FidoIcon.bolt:
        // Flashing inner fill
        final flash = (sin(t * 2 * pi * 3) + 1) / 2;
        canvas.drawPath(
          _buildIconPath(FidoIcon.bolt),
          Paint()
            ..color = color.withOpacity(alpha * flash * 0.3)
            ..style = PaintingStyle.fill,
        );
      case FidoIcon.network:
        // Traveling data packet
        final dot = (t * 4) % 1.0;
        const pts = [Offset(6, 6), Offset(18, 6), Offset(18, 18), Offset(6, 18), Offset(6, 6)];
        final idx = (dot * 4).floor();
        final frac = (dot * 4) - idx;
        if (idx < pts.length - 1) {
          final from = pts[idx], to = pts[idx + 1];
          p.color = color.withOpacity(alpha * 0.9);
          canvas.drawCircle(Offset.lerp(from, to, frac)!, 1.5, p);
        }
      case FidoIcon.brain:
        // Synapse flashes
        for (int i = 0; i < 3; i++) {
          final flash = (sin(t * 2 * pi * 2 + i * 2.1) + 1) / 2;
          p.color = color.withOpacity(alpha * flash * 0.7);
          final positions = [Offset(7, 12), Offset(12, 10), Offset(17, 12)];
          canvas.drawCircle(positions[i], 1.2 + 0.5 * flash, p);
        }
      case FidoIcon.settings:
        // Nothing extra — gear rotation is in path phase
        break;
      case FidoIcon.flash:
        final ring = (sin(t * 2 * pi * 2) + 1) / 2;
        canvas.drawCircle(
          const Offset(12, 12),
          10 + ring * 2,
          Paint()
            ..color = color.withOpacity(alpha * ring * 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      case FidoIcon.globe:
        // Animated meridian dot (simulates rotation)
        final a = t * 2 * pi;
        final x = 12 + 8 * cos(a);
        p.color = color.withOpacity(alpha * 0.7);
        canvas.drawCircle(Offset(x, 12), 1.3, p);
      default:
        // Generic twinkle
        final tw = (sin(t * 2 * pi * 1.5) + 1) / 2;
        canvas.drawCircle(
          const Offset(20, 4),
          1.0 + 0.5 * tw,
          Paint()..color = color.withOpacity(alpha * tw * 0.6),
        );
    }
  }

  @override
  bool shouldRepaint(_SvgIconPainter o) => o.t != t || o.color != color;
}

// ── Circle helper (4 cubic bezier curves, PathMetrics-compatible) ──
void _circle(Path p, double cx, double cy, double r) {
  const k = 0.5523;
  p.moveTo(cx + r, cy);
  p.cubicTo(cx + r, cy + k * r, cx + k * r, cy + r, cx, cy + r);
  p.cubicTo(cx - k * r, cy + r, cx - r, cy + k * r, cx - r, cy);
  p.cubicTo(cx - r, cy - k * r, cx - k * r, cy - r, cx, cy - r);
  p.cubicTo(cx + k * r, cy - r, cx + r, cy - k * r, cx + r, cy);
}

// ── Rounded-rect helper ────────────────────────────────────────────
void _rrect(Path p, double x, double y, double w, double h, double r) {
  p.moveTo(x + r, y);
  p.lineTo(x + w - r, y);
  p.cubicTo(x + w, y, x + w, y, x + w, y + r);
  p.lineTo(x + w, y + h - r);
  p.cubicTo(x + w, y + h, x + w, y + h, x + w - r, y + h);
  p.lineTo(x + r, y + h);
  p.cubicTo(x, y + h, x, y + h, x, y + h - r);
  p.lineTo(x, y + r);
  p.cubicTo(x, y, x, y, x + r, y);
  p.close();
}

// ── Icon Path Definitions (24×24 coordinate space) ────────────────
Path _buildIconPath(FidoIcon type) {
  final p = Path();

  switch (type) {
    // ── CHAT ─────────────────────────────────────────────────────
    case FidoIcon.chat:
      _rrect(p, 2, 3, 18, 12, 3.5);
      p.moveTo(5, 15); p.lineTo(3, 20); p.lineTo(9, 15);
      p.moveTo(7.5, 9.5); p.lineTo(7.5, 9.5);
      _circle(p, 7.5, 9.5, 1.0);
      _circle(p, 12.0, 9.5, 1.0);
      _circle(p, 16.5, 9.5, 1.0);

    // ── IMAGE ────────────────────────────────────────────────────
    case FidoIcon.image:
      _rrect(p, 2, 4, 20, 16, 2);
      p.moveTo(4, 18); p.lineTo(9, 11); p.lineTo(13.5, 16);
      p.lineTo(16, 13.5); p.lineTo(20, 18);
      _circle(p, 16.5, 8.5, 2.2);

    // ── BOLT / LIGHTNING ─────────────────────────────────────────
    case FidoIcon.bolt:
      p.moveTo(13.5, 2);
      p.lineTo(6, 13.5);
      p.lineTo(11.5, 13.5);
      p.lineTo(10.5, 22);
      p.lineTo(18, 10.5);
      p.lineTo(12.5, 10.5);
      p.close();

    // ── SHIELD ───────────────────────────────────────────────────
    case FidoIcon.shield:
      p.moveTo(12, 2);
      p.cubicTo(12, 2, 3.5, 5.5, 3.5, 12);
      p.cubicTo(3.5, 18.5, 12, 22, 12, 22);
      p.cubicTo(20.5, 18.5, 20.5, 12, 20.5, 12);
      p.cubicTo(20.5, 5.5, 12, 2, 12, 2);
      p.moveTo(8, 12.5); p.lineTo(11, 15.5); p.lineTo(16.5, 9);

    // ── HUB / NETWORK NODE ───────────────────────────────────────
    case FidoIcon.hub:
      _circle(p, 12, 12, 2.5);
      for (int i = 0; i < 6; i++) {
        final a = i * pi / 3;
        p.moveTo(12 + 2.5 * cos(a), 12 + 2.5 * sin(a));
        p.lineTo(12 + 8.5 * cos(a), 12 + 8.5 * sin(a));
        _circle(p, 12 + 9.5 * cos(a), 12 + 9.5 * sin(a), 1.2);
      }

    // ── GLOBE ────────────────────────────────────────────────────
    case FidoIcon.globe:
      _circle(p, 12, 12, 10);
      p.moveTo(2, 12); p.lineTo(22, 12);
      p.moveTo(12, 2); p.lineTo(12, 22);
      // longitude ellipse (approximated)
      p.moveTo(12, 2);
      p.cubicTo(7, 2, 5, 7, 5, 12);
      p.cubicTo(5, 17, 7, 22, 12, 22);
      p.cubicTo(17, 22, 19, 17, 19, 12);
      p.cubicTo(19, 7, 17, 2, 12, 2);

    // ── STAR ─────────────────────────────────────────────────────
    case FidoIcon.star:
      final pts = List.generate(10, (i) {
        final a = -pi / 2 + i * pi / 5;
        final r = i.isEven ? 9.5 : 4.0;
        return Offset(12 + r * cos(a), 12 + r * sin(a));
      });
      p.moveTo(pts[0].dx, pts[0].dy);
      for (final pt in pts.skip(1)) p.lineTo(pt.dx, pt.dy);
      p.close();

    // ── NETWORK / SCATTER ────────────────────────────────────────
    case FidoIcon.network:
      const nodes = [Offset(6,6), Offset(18,6), Offset(18,18), Offset(6,18)];
      _circle(p, 12, 12, 2.2);
      for (final n in nodes) {
        _circle(p, n.dx, n.dy, 2.0);
        p.moveTo(12, 12); p.lineTo(n.dx, n.dy);
      }
      p.moveTo(6, 6); p.lineTo(18, 6);
      p.moveTo(18, 6); p.lineTo(18, 18);
      p.moveTo(18, 18); p.lineTo(6, 18);
      p.moveTo(6, 18); p.lineTo(6, 6);

    // ── BRAIN ────────────────────────────────────────────────────
    case FidoIcon.brain:
      // Left lobe
      p.moveTo(12, 7);
      p.cubicTo(5, 7, 3, 11, 4.5, 14.5);
      p.cubicTo(6, 18, 10, 19, 12, 18.5);
      // Right lobe
      p.moveTo(12, 7);
      p.cubicTo(19, 7, 21, 11, 19.5, 14.5);
      p.cubicTo(18, 18, 14, 19, 12, 18.5);
      // Divider
      p.moveTo(12, 7); p.lineTo(12, 18.5);
      // Circuit lines
      p.moveTo(6, 11); p.lineTo(10, 11); p.lineTo(10, 15);
      p.moveTo(18, 11); p.lineTo(14, 11); p.lineTo(14, 15);

    // ── SETTINGS / SLIDERS ───────────────────────────────────────
    case FidoIcon.settings:
      // 3 horizontal slider lines with knobs
      p.moveTo(2, 7); p.lineTo(22, 7);
      _circle(p, 8, 7, 2.5);
      p.moveTo(2, 12); p.lineTo(22, 12);
      _circle(p, 16, 12, 2.5);
      p.moveTo(2, 17); p.lineTo(22, 17);
      _circle(p, 10, 17, 2.5);

    // ── PERSON / USER ────────────────────────────────────────────
    case FidoIcon.person:
      _circle(p, 11, 7.5, 4.5);
      p.moveTo(2, 21);
      p.cubicTo(2, 15.5, 6.5, 14, 11, 14);
      p.cubicTo(15.5, 14, 20, 15.5, 20, 21);
      // Plus sign
      p.moveTo(19, 5); p.lineTo(23, 5);
      p.moveTo(21, 3); p.lineTo(21, 7);

    // ── SPARKLE / MAGIC ──────────────────────────────────────────
    case FidoIcon.sparkle:
      // 4-pointed large star
      p.moveTo(12, 2); p.lineTo(13.5, 10.5);
      p.lineTo(22, 12); p.lineTo(13.5, 13.5);
      p.lineTo(12, 22); p.lineTo(10.5, 13.5);
      p.lineTo(2, 12); p.lineTo(10.5, 10.5);
      p.close();
      // Small sparkle top-right
      p.moveTo(19, 4); p.lineTo(19.8, 6.5); p.lineTo(22, 4);
      p.moveTo(4, 18); p.lineTo(4.8, 20.5); p.lineTo(7, 18);

    // ── FLASH / ELECTRIC BOLT ────────────────────────────────────
    case FidoIcon.flash:
      _circle(p, 12, 12, 10);
      p.moveTo(14, 3.5); p.lineTo(8, 13); p.lineTo(12.5, 13);
      p.lineTo(10, 20.5); p.lineTo(16, 11); p.lineTo(11.5, 11);
      p.close();

    // ── LOCK ─────────────────────────────────────────────────────
    case FidoIcon.lock:
      _rrect(p, 5, 11, 14, 11, 2);
      p.moveTo(8, 11); p.lineTo(8, 8);
      p.cubicTo(8, 4, 16, 4, 16, 8);
      p.lineTo(16, 11);
      _circle(p, 12, 16.5, 2.0);
      p.moveTo(12, 18.5); p.lineTo(12, 20.5);

    // ── TRENDING UP ──────────────────────────────────────────────
    case FidoIcon.trending:
      p.moveTo(2, 18.5); p.lineTo(9, 11); p.lineTo(13.5, 15.5);
      p.lineTo(22, 6);
      p.moveTo(16.5, 6); p.lineTo(22, 6); p.lineTo(22, 11.5);

    // ── DIAMOND / LENS ───────────────────────────────────────────
    case FidoIcon.diamond:
      p.moveTo(12, 2);
      p.lineTo(22, 10.5);
      p.lineTo(18, 22);
      p.lineTo(6, 22);
      p.lineTo(2, 10.5);
      p.close();
      p.moveTo(2, 10.5); p.lineTo(22, 10.5);
      p.moveTo(6, 22); p.lineTo(12, 2); p.lineTo(18, 22);
  }

  return p;
}
