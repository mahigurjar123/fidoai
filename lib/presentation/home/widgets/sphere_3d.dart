import 'dart:math';
import 'package:flutter/material.dart';

class Sphere3D extends StatefulWidget {
  final double size;
  final Color color;
  final Color accentColor;

  const Sphere3D({
    super.key,
    this.size = 320,
    this.color = const Color(0xFF7B2FFF),
    this.accentColor = const Color(0xFF2F8FFF),
  });

  @override
  State<Sphere3D> createState() => _Sphere3DState();
}

class _Sphere3DState extends State<Sphere3D> with TickerProviderStateMixin {
  late AnimationController _rotCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotCtrl, _pulseCtrl]),
        builder: (_, __) {
          final rot = _rotCtrl.value * 2 * pi;
          final pulse = _pulseCtrl.value;
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: widget.size * (1.1 + 0.05 * pulse),
                  height: widget.size * (1.1 + 0.05 * pulse),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      widget.color.withOpacity(0.15 + 0.05 * pulse),
                      widget.accentColor.withOpacity(0.08),
                      Colors.transparent,
                    ]),
                  ),
                ),
                // Sphere wireframe
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _SpherePainter(
                    rotation: rot,
                    color: widget.color,
                    accentColor: widget.accentColor,
                    pulse: pulse,
                  ),
                ),
                // Center glow
                Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      widget.color.withOpacity(0.25 + 0.1 * pulse),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpherePainter extends CustomPainter {
  final double rotation;
  final Color color;
  final Color accentColor;
  final double pulse;

  const _SpherePainter({
    required this.rotation,
    required this.color,
    required this.accentColor,
    required this.pulse,
  });

  // 3D → 2D perspective projection
  Offset _project(double x, double y, double z, double cx, double cy, double r) {
    const d = 3.5;
    final f = d / (d - z / r * 0.6);
    return Offset(cx + x * f, cy - y * f);
  }

  // Rotate around Y axis
  List<double> _rotY(double x, double y, double z, double a) {
    return [x * cos(a) + z * sin(a), y, -x * sin(a) + z * cos(a)];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // ── Draw latitude lines ─────────────────────────────────
    // Step changed from 4° to 6° — reduces loop iterations by ~33 %
    for (int latDeg = -75; latDeg <= 75; latDeg += 15) {
      final lat = latDeg * pi / 180;
      final cosLat = cos(lat);
      final sinLat = sin(lat);
      final isEquator = latDeg == 0;

      final pts = <Offset>[];
      final vis = <bool>[];

      for (int lonDeg = 0; lonDeg <= 360; lonDeg += 6) {
        final lon = lonDeg * pi / 180;
        double x = r * cosLat * cos(lon);
        double y = r * sinLat;
        double z = r * cosLat * sin(lon);
        final rv = _rotY(x, y, z, rotation);
        x = rv[0]; y = rv[1]; z = rv[2];
        pts.add(_project(x, y, z, cx, cy, r));
        vis.add(z > -r * 0.1);
      }

      for (int i = 0; i < pts.length - 1; i++) {
        if (vis[i] && vis[i + 1]) {
          canvas.drawLine(
            pts[i],
            pts[i + 1],
            Paint()
              ..color = isEquator
                  ? color.withOpacity(0.7)
                  : color.withOpacity(0.2 + (1 - (latDeg.abs() / 90)) * 0.15)
              ..strokeWidth = isEquator ? 1.5 : 1,
          );
        }
      }
    }

    // ── Draw longitude lines ────────────────────────────────
    // Step changed from 4° to 6°
    for (int lonDeg = 0; lonDeg < 180; lonDeg += 30) {
      final lon = lonDeg * pi / 180;
      final pts = <Offset>[];
      final vis = <bool>[];

      for (int latDeg = -90; latDeg <= 90; latDeg += 6) {
        final lat = latDeg * pi / 180;
        double x = r * cos(lat) * cos(lon);
        double y = r * sin(lat);
        double z = r * cos(lat) * sin(lon);
        final rv = _rotY(x, y, z, rotation);
        x = rv[0]; y = rv[1]; z = rv[2];
        pts.add(_project(x, y, z, cx, cy, r));
        vis.add(z > -r * 0.1);
      }

      for (int i = 0; i < pts.length - 1; i++) {
        if (vis[i] && vis[i + 1]) {
          canvas.drawLine(
            pts[i],
            pts[i + 1],
            Paint()
              ..color = accentColor.withOpacity(0.22)
              ..strokeWidth = 1,
          );
        }
      }

      // Mirror longitude
      final pts2 = <Offset>[];
      final vis2 = <bool>[];
      for (int latDeg = -90; latDeg <= 90; latDeg += 6) {
        final lat = latDeg * pi / 180;
        double x = r * cos(lat) * cos(lon + pi);
        double y = r * sin(lat);
        double z = r * cos(lat) * sin(lon + pi);
        final rv = _rotY(x, y, z, rotation);
        x = rv[0]; y = rv[1]; z = rv[2];
        pts2.add(_project(x, y, z, cx, cy, r));
        vis2.add(z > -r * 0.1);
      }
      for (int i = 0; i < pts2.length - 1; i++) {
        if (vis2[i] && vis2[i + 1]) {
          canvas.drawLine(
            pts2[i],
            pts2[i + 1],
            Paint()
              ..color = accentColor.withOpacity(0.22)
              ..strokeWidth = 1,
          );
        }
      }
    }

    // ── Draw glowing dots at intersections ──────────────────
    for (int latDeg = -75; latDeg <= 75; latDeg += 15) {
      for (int lonDeg = 0; lonDeg < 360; lonDeg += 30) {
        final lat = latDeg * pi / 180;
        final lon = lonDeg * pi / 180;
        double x = r * cos(lat) * cos(lon);
        double y = r * sin(lat);
        double z = r * cos(lat) * sin(lon);
        final rv = _rotY(x, y, z, rotation);
        x = rv[0]; y = rv[1]; z = rv[2];
        if (z > r * 0.1) {
          final p = _project(x, y, z, cx, cy, r);
          final dotSize = 2.5 + pulse * 1.0;
          // Glow
          canvas.drawCircle(
            p,
            dotSize + 3,
            Paint()..color = color.withOpacity(0.15 + 0.1 * pulse),
          );
          // Core
          canvas.drawCircle(
            p,
            dotSize,
            Paint()..color = color.withOpacity(0.8),
          );
        }
      }
    }

    // ── Draw "data stream" dots on surface ──────────────────
    final r2 = Random(42);
    for (int i = 0; i < 12; i++) {
      final lat = (r2.nextDouble() * 150 - 75) * pi / 180;
      final lon = (r2.nextDouble() * 360) * pi / 180;
      double x = r * cos(lat) * cos(lon);
      double y = r * sin(lat);
      double z = r * cos(lat) * sin(lon);
      final rv = _rotY(x, y, z, rotation + r2.nextDouble() * 0.5);
      x = rv[0]; y = rv[1]; z = rv[2];
      if (z > r * 0.2) {
        final p = _project(x, y, z, cx, cy, r);
        canvas.drawCircle(
          p,
          3.5 + pulse * 1.5,
          Paint()..color = const Color(0xFF00F5FF).withOpacity(0.7 + 0.3 * pulse),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SpherePainter old) =>
      old.rotation != rotation || old.pulse != pulse;
}
