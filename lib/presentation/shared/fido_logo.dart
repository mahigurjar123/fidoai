import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════
// FIDO AI — 3D/4D Animated Logo
//
// Features:
//  • 3 orbital rings on genuinely different 3D tilted planes
//  • 9 particles (4+3+2) with depth-based brightness
//  • Rotating radial energy spokes
//  • Pulsing outer atmosphere rings
//  • Color-cycling particles (purple→blue→cyan→pink cycle = "4D")
//  • 3D perspective tilt on mouse hover
//  • Shimmer gradient on the "Fido AI" text
// ═══════════════════════════════════════════════════════════════════════

class FidoAILogo extends StatefulWidget {
  final double size;
  final bool showText;

  const FidoAILogo({super.key, this.size = 48, this.showText = true});

  @override
  State<FidoAILogo> createState() => _FidoAILogoState();
}

class _FidoAILogoState extends State<FidoAILogo> with TickerProviderStateMixin {
  late AnimationController _ringA;     // Orbit A — 4s
  late AnimationController _ringB;     // Orbit B — 6s  (counter-rotate)
  late AnimationController _ringC;     // Orbit C — 3.2s
  late AnimationController _pulse;     // Outer atmosphere — 2s
  late AnimationController _spokes;    // Energy spokes — 8s
  late AnimationController _colorCycle;// 4D color shift — 7s
  late AnimationController _hoverCtrl; // 3D tilt ease — 280ms

  double _tiltX = 0, _tiltY = 0;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ringA      = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _ringB      = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _ringC      = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
    _pulse      = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _spokes     = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _colorCycle = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
    _hoverCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  }

  @override
  void dispose() {
    _ringA.dispose(); _ringB.dispose(); _ringC.dispose();
    _pulse.dispose(); _spokes.dispose(); _colorCycle.dispose();
    _hoverCtrl.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent e) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(e.position);
    setState(() {
      _tiltX = (local.dy / box.size.height - .5) * 28;
      _tiltY = (local.dx / box.size.width  - .5) * -28;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sz = widget.size;
    return Listener(
      onPointerHover: _hovered ? _onHover : null,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) { setState(() => _hovered = true);  _hoverCtrl.forward(); },
        onExit:  (_) { setState(() { _hovered = false; _tiltX = 0; _tiltY = 0; }); _hoverCtrl.reverse(); },
        child: AnimatedBuilder(
          animation: Listenable.merge([_ringA, _ringB, _ringC, _pulse, _spokes, _colorCycle, _hoverCtrl]),
          builder: (_, __) => Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0018)
              ..rotateX(_tiltX * pi / 180 * _hoverCtrl.value)
              ..rotateY(_tiltY * pi / 180 * _hoverCtrl.value),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Logo orb ──
                RepaintBoundary(
                  child: SizedBox(
                    width: sz,
                    height: sz,
                    child: CustomPaint(
                      painter: _LogoPainter(
                        tA:    _ringA.value,
                        tB:    1 - _ringB.value,  // counter-rotate
                        tC:    _ringC.value,
                        pulse: _pulse.value,
                        spokes: _spokes.value,
                        color: _colorCycle.value,
                      ),
                    ),
                  ),
                ),

                // ── "Fido AI" shimmer text ──
                if (widget.showText) ...[
                  SizedBox(width: sz * .22),
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: const [
                        AppColors.purple, AppColors.blue,
                        AppColors.cyan,   AppColors.purple,
                      ],
                      stops: [0, _colorCycle.value * .5 + .1, _colorCycle.value * .5 + .4, 1],
                      tileMode: TileMode.clamp,
                    ).createShader(b),
                    child: Text(
                      'Fido AI',
                      style: GoogleFonts.inter(
                        fontSize: sz * .42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom Painter ─────────────────────────────────────────────────────────────
class _LogoPainter extends CustomPainter {
  final double tA, tB, tC;   // orbit angles 0–1
  final double pulse;         // breathe 0–1
  final double spokes;        // spoke rotation 0–1
  final double color;         // 4D color cycle 0–1

  const _LogoPainter({
    required this.tA, required this.tB, required this.tC,
    required this.pulse, required this.spokes, required this.color,
  });

  // 4D color: cycle through purple→blue→cyan→pink→purple
  Color _cycleColor(double offset) {
    const cols = [
      Color(0xFF7B2FFF), // purple
      Color(0xFF2F8FFF), // blue
      Color(0xFF00F5FF), // cyan
      Color(0xFFFF2FBE), // pink
      Color(0xFF7B2FFF), // loop back
    ];
    final t = ((color + offset) % 1.0) * (cols.length - 1);
    final i = t.floor().clamp(0, cols.length - 2);
    return Color.lerp(cols[i], cols[i + 1], t - i.floor())!;
  }

  // Project 3D point → 2D with perspective
  Offset _proj(double x, double y, double z, double cx, double cy) {
    const d = 5.0;
    final f = d / (d + z * .5);
    return Offset(cx + x * f, cy + y * f);
  }

  // Rotate point by tiltX around X-axis and tiltY around Y-axis
  (double rx, double ry, double rz) _rotate3D(
      double x, double y, double z, double tiltX, double tiltY) {
    // Rotate around X
    final y1 = y * cos(tiltX) - z * sin(tiltX);
    final z1 = y * sin(tiltX) + z * cos(tiltX);
    // Rotate around Y
    final x2 = x * cos(tiltY) + z1 * sin(tiltY);
    final z2 = -x * sin(tiltY) + z1 * cos(tiltY);
    return (x2, y1, z2);
  }

  // Draw one orbit ring + its particles
  void _drawOrbit(Canvas canvas, double cx, double cy, double r, double t,
      double tiltX, double tiltY, Color col, int dots, double dotR) {

    // ── Ring path (64-segment polyline = accurate 3D curve) ──
    final path = Path();
    bool first = true;
    for (int i = 0; i <= 64; i++) {
      final a = i / 64 * 2 * pi;
      final raw = _rotate3D(r * cos(a), r * sin(a), 0, tiltX, tiltY);
      final p = _proj(raw.$1, raw.$2, raw.$3, cx, cy);
      if (first) { path.moveTo(p.dx, p.dy); first = false; }
      else path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()
      ..color = col.withOpacity(.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8);

    // ── Particles ──
    for (int i = 0; i < dots; i++) {
      final a = (t + i / dots) * 2 * pi;
      final raw = _rotate3D(r * cos(a), r * sin(a), 0, tiltX, tiltY);
      final p = _proj(raw.$1, raw.$2, raw.$3, cx, cy);

      // Depth: raw.$3 goes -r..+r; map to 0..1 (1 = closest)
      final depth = (raw.$3 / r + 1) / 2;
      final opacity = .3 + .7 * depth;
      final size    = dotR * (.6 + .5 * depth);

      // Particle color from 4D cycle — each particle offset in the cycle
      final pCol = _cycleColor(i / dots * .3);

      // Outer glow
      canvas.drawCircle(p, size * 2.8, Paint()
        ..color = pCol.withOpacity(opacity * .25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      // Core dot
      canvas.drawCircle(p, size, Paint()..color = pCol.withOpacity(opacity));
      // Bright inner dot
      canvas.drawCircle(p, size * .45, Paint()
        ..color = Colors.white.withOpacity(opacity * .7));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = min(cx, cy);

    // ── 1. Outer atmosphere rings (pulsing) ─────────────────────
    for (int i = 0; i < 3; i++) {
      final scale = .82 + i * .07 + .04 * pulse;
      final opacity = .10 + (.04 - i * .012) * (1 - pulse);
      final col = _cycleColor(i * .33);
      canvas.drawCircle(Offset(cx, cy), r * scale, Paint()
        ..color = col.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 - i * .25);
    }

    // ── 2. Radial energy spokes ──────────────────────────────────
    final spokeBase = spokes * 2 * pi;
    for (int i = 0; i < 8; i++) {
      final a = spokeBase + i * pi / 4;
      final opacity = ((sin(a * 2 + spokes * 4 * pi) + 1) / 2 * .18).clamp(.02, .18);
      final col = _cycleColor(i / 8.0);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + r * .78 * cos(a), cy + r * .78 * sin(a)),
        Paint()
          ..color = col.withOpacity(opacity)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── 3. Three 3D orbital rings ────────────────────────────────
    //  Ring A: tilted 42° on X-axis — 4 purple/blue particles
    _drawOrbit(canvas, cx, cy, r * .64,
        tA, 42 * pi / 180, 0,
        _cycleColor(0), 4, 3.8);

    //  Ring B: tilted 55° on Y-axis (counter-rotating) — 3 cyan particles
    _drawOrbit(canvas, cx, cy, r * .54,
        tB, 0, 55 * pi / 180,
        _cycleColor(.33), 3, 3.2);

    //  Ring C: tilted 28° X + 38° Y — 2 pink particles
    _drawOrbit(canvas, cx, cy, r * .42,
        tC, 28 * pi / 180, 38 * pi / 180,
        _cycleColor(.66), 2, 2.6);

    // ── 4. Central core glow ─────────────────────────────────────
    final coreR = r * .30;
    final glowCol = _cycleColor(0);

    // Soft halo
    canvas.drawCircle(Offset(cx, cy), coreR * 2.0, Paint()
      ..shader = RadialGradient(colors: [
        glowCol.withOpacity(.30 + .10 * pulse),
        glowCol.withOpacity(.12),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: coreR * 2.0)));

    // Core fill (gradient sphere)
    canvas.drawCircle(Offset(cx, cy), coreR, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.3, -.3),
        colors: [
          const Color(0xFF9B5FFF),
          const Color(0xFF4B8FFF),
          const Color(0xFF2B4FBF),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: coreR)));

    // Core border ring
    canvas.drawCircle(Offset(cx, cy), coreR, Paint()
      ..color = Colors.white.withOpacity(.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);

    // ── 5. "F" letterform on canvas ──────────────────────────────
    final tp = TextPainter(
      text: TextSpan(
        text: 'F',
        style: TextStyle(
          color: Colors.white,
          fontSize: coreR * 1.35,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(cx - tp.width / 2 + .5, cy - tp.height / 2 + .5),
    );

    // ── 6. Specular shine on core ────────────────────────────────
    canvas.drawCircle(
      Offset(cx - coreR * .28, cy - coreR * .28),
      coreR * .32,
      Paint()
        ..color = Colors.white.withOpacity(.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ── 7. "AI" data-stream dots (equatorial ring micro-dots) ────
    for (int i = 0; i < 12; i++) {
      final a = i / 12 * 2 * pi + spokes * 3 * pi;
      final dotOp = ((sin(a + spokes * 6 * pi) + 1) / 2 * .55).clamp(.05, .55);
      final dotCol = _cycleColor(i / 12.0 * .4);
      final dx = cx + coreR * 1.55 * cos(a);
      final dy = cy + coreR * 1.55 * sin(a);
      canvas.drawCircle(Offset(dx, dy), 1.4, Paint()
        ..color = dotCol.withOpacity(dotOp));
    }
  }

  @override
  bool shouldRepaint(_LogoPainter o) =>
      o.tA != tA || o.tB != tB || o.tC != tC ||
      o.pulse != pulse || o.spokes != spokes || o.color != color;
}
