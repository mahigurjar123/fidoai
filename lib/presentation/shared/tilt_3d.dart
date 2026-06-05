import 'dart:math';
import 'package:flutter/material.dart';

// ── Reusable mouse-tracking 3D tilt card ──────────────────
class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  const Tilt3DCard({super.key, required this.child, this.maxTilt = 14});
  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}
class _Tilt3DCardState extends State<Tilt3DCard> {
  double _tiltX = 0, _tiltY = 0;
  bool _hovered = false;
  void _onHover(PointerEvent e) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(e.position);
    setState(() {
      _tiltX = (local.dy / box.size.height - .5) * widget.maxTilt;
      _tiltY = (local.dx / box.size.width  - .5) * -widget.maxTilt;
    });
  }
  @override
  Widget build(BuildContext context) => Listener(
    onPointerHover: _hovered ? _onHover : null,
    child: MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() { _hovered = false; _tiltX = 0; _tiltY = 0; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..setEntry(3, 2, .001)
          ..rotateX(_tiltX * pi / 180)
          ..rotateY(_tiltY * pi / 180),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    ),
  );
}

// ── Floating (sine-wave y-offset) ─────────────────────────
class Float3D extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration period;
  const Float3D({super.key, required this.child, this.amplitude = 10,
      this.period = const Duration(seconds: 4)});
  @override
  State<Float3D> createState() => _Float3DState();
}
class _Float3DState extends State<Float3D> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: widget.period)..repeat(reverse: true); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) => Transform.translate(offset: Offset(0, -widget.amplitude * _c.value), child: child),
    child: widget.child,
  );
}

// ── 3D Wireframe background (rotating cubes + octahedrons) ─
class Geo3DBg extends StatefulWidget {
  final Color color;
  const Geo3DBg({super.key, required this.color});
  @override
  State<Geo3DBg> createState() => _Geo3DBgState();
}
class _Geo3DBgState extends State<Geo3DBg> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        painter: _GeoPainter(t: _c.value, color: widget.color),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _GeoPainter extends CustomPainter {
  final double t;
  final Color color;
  const _GeoPainter({required this.t, required this.color});

  void _cube(Canvas canvas, Offset center, double sz, double angle, double opacity) {
    final ca = cos(angle), sa = sin(angle);
    final pts = [
      [-1,-1,-1],[1,-1,-1],[1,1,-1],[-1,1,-1],
      [-1,-1, 1],[1,-1, 1],[1,1, 1],[-1,1, 1],
    ].map((v) {
      final x = v[0]*ca + v[2]*sa, y = v[1]*1.0, z = -v[0]*sa + v[2]*ca;
      const d = 4.0; final f = d/(d+z*.4);
      return Offset(center.dx+x*f*sz, center.dy+y*f*sz);
    }).toList();
    final p = Paint()..color = color.withOpacity(opacity)..strokeWidth = 1.2;
    for (final e in [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]])
      canvas.drawLine(pts[e[0]], pts[e[1]], p);
  }

  void _octa(Canvas canvas, Offset center, double sz, double angle, double opacity) {
    final ca = cos(angle), sa = sin(angle);
    final pts = [
      [0.0,-1.0,0.0],[0.0,1.0,0.0],[1.0,0.0,0.0],[-1.0,0.0,0.0],[0.0,0.0,1.0],[0.0,0.0,-1.0],
    ].map((v) {
      final x = v[0]*ca+v[2]*sa, y=v[1], z=-v[0]*sa+v[2]*ca;
      const d=4.0; final f=d/(d+z*.4);
      return Offset(center.dx+x*f*sz, center.dy+y*f*sz);
    }).toList();
    final p = Paint()..color = color.withOpacity(opacity)..strokeWidth = 1.2;
    for (final e in [[0,2],[0,3],[0,4],[0,5],[1,2],[1,3],[1,4],[1,5],[2,4],[4,3],[3,5],[5,2]])
      canvas.drawLine(pts[e[0]], pts[e[1]], p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _cube(canvas, Offset(size.width*.88, size.height*.1), 55, t*2*pi, .07);
    _cube(canvas, Offset(size.width*.08, size.height*.75), 38, -t*2*pi*1.3, .06);
    _octa(canvas, Offset(size.width*.75, size.height*.88), 44, t*pi*1.7, .07);
    _octa(canvas, Offset(size.width*.2, size.height*.08), 32, -t*pi, .07);
    _cube(canvas, Offset(size.width*.55, size.height*.92), 28, t*pi*.9, .05);
  }

  @override
  bool shouldRepaint(_GeoPainter o) => o.t != t;
}
