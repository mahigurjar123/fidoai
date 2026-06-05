import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBg extends StatefulWidget {
  final Color? orbColor1;
  final Color? orbColor2;
  const AnimatedBg({super.key, this.orbColor1, this.orbColor2});

  @override
  State<AnimatedBg> createState() => _AnimatedBgState();
}

class _AnimatedBgState extends State<AnimatedBg> with TickerProviderStateMixin {
  late AnimationController _c1, _c2, _c3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 11))
      ..repeat(reverse: true);
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Positioned.fill(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_c1, _c2, _c3]),
          builder: (_, __) => CustomPaint(
            painter: _BgPainter(
              v1: _c1.value,
              v2: _c2.value,
              v3: _c3.value,
              c1: widget.orbColor1 ?? const Color(0xFF7B2FFF),
              c2: widget.orbColor2 ?? const Color(0xFF2F8FFF),
              // Use a coarser grid on mobile to reduce draw calls
              gridStep: isMobile ? 90.0 : 60.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double v1, v2, v3;
  final Color c1, c2;
  final double gridStep;

  const _BgPainter({
    required this.v1,
    required this.v2,
    required this.v3,
    required this.c1,
    required this.c2,
    required this.gridStep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF060614),
    );

    _drawGrid(canvas, size);

    _orb(canvas, Offset(size.width * 0.8 + v1 * 60, size.height * 0.15 + v1 * 40),
        size.width * 0.28, c1, 0.2);
    _orb(canvas, Offset(size.width * 0.1 - v2 * 50, size.height * 0.75 - v2 * 30),
        size.width * 0.22, c2, 0.17);
    _orb(canvas, Offset(size.width * 0.25 + v3 * 20, size.height * 0.3 - v3 * 15),
        size.width * 0.12, const Color(0xFFFF2FBE), 0.08);
    _orb(canvas, Offset(size.width * 0.7, size.height * 0.8),
        size.width * 0.1 * (0.8 + 0.4 * v3), const Color(0xFF00F5FF), 0.06);
  }

  void _orb(Canvas canvas, Offset c, double r, Color color, double opacity) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          color.withOpacity(opacity),
          color.withOpacity(0),
        ]).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) =>
      old.v1 != v1 || old.v2 != v2 || old.v3 != v3;
}

// ─── Floating particles ──────────────────────────────────────────────────────

class Particles extends StatefulWidget {
  final int count;
  const Particles({super.key, this.count = 25});

  @override
  State<Particles> createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_P> _particles;

  @override
  void initState() {
    super.initState();
    // Reduce particle count on mobile automatically via widget param from router
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
    final r = Random();
    _particles = List.generate(widget.count, (_) => _P(r));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _PPainter(_particles, _ctrl.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _P {
  final double x, y, size, speed, opacity;
  final Color color;
  _P(Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        size = r.nextDouble() * 2.5 + 0.5,
        speed = r.nextDouble() * 0.25 + 0.08,
        opacity = r.nextDouble() * 0.4 + 0.1,
        color = [
          const Color(0xFF7B2FFF),
          const Color(0xFF2F8FFF),
          const Color(0xFF00F5FF),
          const Color(0xFFFF2FBE),
        ][r.nextInt(4)];
}

class _PPainter extends CustomPainter {
  final List<_P> particles;
  final double t;
  _PPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + t * p.speed) % 1.0;
      final x = p.x + sin(t * 2 * pi + p.y * 8) * 0.018;
      final op = (sin(t * 2 * pi * p.speed + p.x * 8) + 1) / 2 * p.opacity;
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        Paint()..color = p.color.withOpacity(op),
      );
    }
  }

  @override
  bool shouldRepaint(_PPainter old) => old.t != t;
}
