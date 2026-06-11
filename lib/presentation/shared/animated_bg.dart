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

class _Node3D {
  double x, y, z;          // Base coordinates in normalized 3D space
  double vx, vy, vz;       // Velocity for floating movement
  final double radius;
  final Color color;
  
  _Node3D({
    required this.x,
    required this.y,
    required this.z,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.radius,
    required this.color,
  });
}

class _ParticlesState extends State<Particles> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Node3D> _nodes;
  Offset _mousePosition = Offset.zero;
  Offset _targetMouse = Offset.zero;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _ctrl.addListener(() {
      _updateNodes();
    });
    
    final r = Random();
    _nodes = List.generate(widget.count, (_) {
      final x = r.nextDouble() * 2.4 - 1.2;
      final y = r.nextDouble() * 2.4 - 1.2;
      final z = r.nextDouble() * 2.4 - 1.2;
      
      final vx = r.nextDouble() * 0.16 - 0.08;
      final vy = r.nextDouble() * 0.16 - 0.08;
      final vz = r.nextDouble() * 0.16 - 0.08;
      
      final color = [
        const Color(0xFF7B2FFF), // Purple
        const Color(0xFF2F8FFF), // Blue
        const Color(0xFF00F5FF), // Cyan
        const Color(0xFFFF2FBE), // Pink
      ][r.nextInt(4)];
      
      final radius = r.nextDouble() * 2.5 + 1.5;
      
      return _Node3D(
        x: x, y: y, z: z,
        vx: vx, vy: vy, vz: vz,
        radius: radius,
        color: color,
      );
    });
  }

  void _updateNodes() {
    _mousePosition = Offset.lerp(_mousePosition, _targetMouse, 0.08)!;
    
    const dt = 0.005;
    for (final node in _nodes) {
      node.x += node.vx * dt;
      node.y += node.vy * dt;
      node.z += node.vz * dt;
      
      const limit = 1.3;
      if (node.x.abs() > limit) {
        node.vx *= -1;
        node.x = node.x.clamp(-limit, limit);
      }
      if (node.y.abs() > limit) {
        node.vy *= -1;
        node.y = node.y.clamp(-limit, limit);
      }
      if (node.z.abs() > limit) {
        node.vz *= -1;
        node.z = node.z.clamp(-limit, limit);
      }
      
      if (_isHovering) {
        final dx = _mousePosition.dx * 1.2 - node.x;
        final dy = _mousePosition.dy * 1.2 - node.y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < 0.8 && dist > 0.05) {
          final force = (0.8 - dist) * 0.1;
          node.vx -= (dx / dist) * force;
          node.vy -= (dy / dist) * force;
          
          final speed = sqrt(node.vx * node.vx + node.vy * node.vy);
          if (speed > 0.5) {
            node.vx = (node.vx / speed) * 0.5;
            node.vy = (node.vy / speed) * 0.5;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final size = MediaQuery.of(context).size;
        _targetMouse = Offset(
          (event.localPosition.dx / size.width - 0.5) * 2.0,
          (event.localPosition.dy / size.height - 0.5) * 2.0,
        );
        _isHovering = true;
      },
      onExit: (_) {
        _targetMouse = Offset.zero;
        _isHovering = false;
      },
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _3DConstellationPainter(
              nodes: _nodes,
              time: _ctrl.value,
              mousePos: _mousePosition,
              isHovering: _isHovering,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _3DConstellationPainter extends CustomPainter {
  final List<_Node3D> nodes;
  final double time;
  final Offset mousePos;
  final bool isHovering;
  
  _3DConstellationPainter({
    required this.nodes,
    required this.time,
    required this.mousePos,
    required this.isHovering,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = min(size.width, size.height) * 0.45;
    
    final baseAngleY = time * 2 * pi;
    final baseAngleX = sin(time * 2 * pi) * 0.15;
    
    final tiltY = mousePos.dx * 0.5;
    final tiltX = -mousePos.dy * 0.5;
    
    final angleY = baseAngleY + tiltY;
    final angleX = baseAngleX + tiltX;
    
    final cosY = cos(angleY);
    final sinY = sin(angleY);
    final cosX = cos(angleX);
    final sinX = sin(angleX);
    
    final projectedPoints = List<Offset?>.filled(nodes.length, null);
    final rotatedZ = List<double>.filled(nodes.length, 0.0);
    
    const cameraDist = 3.5; 
    
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      
      double x1 = node.x * cosY - node.z * sinY;
      double z1 = node.x * sinY + node.z * cosY;
      double y1 = node.y;
      
      double x2 = x1;
      double y2 = y1 * cosX - z1 * sinX;
      double z2 = y1 * sinX + z1 * cosX;
      
      rotatedZ[i] = z2;
      
      final perspective = cameraDist / (cameraDist - z2);
      final px = centerX + x2 * scale * perspective;
      final py = centerY + y2 * scale * perspective;
      
      if (px >= -150 && px <= size.width + 150 && py >= -150 && py <= size.height + 150) {
        projectedPoints[i] = Offset(px, py);
      }
    }
    
    const connectionThreshold = 1.15; 
    
    for (int i = 0; i < nodes.length; i++) {
      final p1 = projectedPoints[i];
      if (p1 == null) continue;
      
      final n1 = nodes[i];
      final z1 = rotatedZ[i];
      
      for (int j = i + 1; j < nodes.length; j++) {
        final p2 = projectedPoints[j];
        if (p2 == null) continue;
        
        final n2 = nodes[j];
        final z2 = rotatedZ[j];
        
        final dx = n1.x - n2.x;
        final dy = n1.y - n2.y;
        final dz = n1.z - n2.z;
        final dist = sqrt(dx * dx + dy * dy + dz * dz);
        
        if (dist < connectionThreshold) {
          final distFrac = 1.0 - (dist / connectionThreshold);
          final avgZ = (z1 + z2) / 2.0; 
          final depthOpacity = ((avgZ + 1.3) / 2.6).clamp(0.1, 1.0);
          
          final lineOpacity = distFrac * 0.28 * depthOpacity;
          
          if (lineOpacity > 0.01) {
            final linePaint = Paint()
              ..shader = LinearGradient(
                colors: [
                  n1.color.withOpacity(lineOpacity),
                  n2.color.withOpacity(lineOpacity),
                ],
              ).createShader(Rect.fromPoints(p1, p2))
              ..strokeWidth = (1.5 * distFrac * depthOpacity).clamp(0.2, 1.8)
              ..style = PaintingStyle.stroke;
              
            canvas.drawLine(p1, p2, linePaint);
            
            final packetSpeed = 1.2;
            final packetPhase = ((time * packetSpeed + (i * 0.17) + (j * 0.09)) % 1.0);
            
            if (packetPhase < 0.4) {
              final frac = packetPhase / 0.4;
              final packetPos = Offset.lerp(p1, p2, frac)!;
              final packetOpacity = sin(frac * pi) * 0.75 * depthOpacity;
              
              final packetColor = Color.lerp(n1.color, n2.color, frac)!;
              canvas.drawCircle(
                packetPos,
                1.8 + 1.2 * depthOpacity,
                Paint()
                  ..color = packetColor.withOpacity(packetOpacity)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
              );
            }
          }
        }
      }
    }
    
    final sortedIndices = List<int>.generate(nodes.length, (index) => index);
    sortedIndices.sort((a, b) => rotatedZ[a].compareTo(rotatedZ[b]));
    
    final nodePaint = Paint()..style = PaintingStyle.fill;
    
    for (final idx in sortedIndices) {
      final p = projectedPoints[idx];
      if (p == null) continue;
      
      final node = nodes[idx];
      final z = rotatedZ[idx];
      
      final depth = ((z + 1.3) / 2.6).clamp(0.0, 1.0);
      final perspective = cameraDist / (cameraDist - z);
      final size = node.radius * perspective;
      
      canvas.drawCircle(
        p,
        size * 4.5,
        Paint()
          ..style = PaintingStyle.fill
          ..color = node.color.withOpacity(0.08 * depth)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 2.2),
      );
      
      canvas.drawCircle(
        p,
        size * 1.8,
        Paint()
          ..style = PaintingStyle.fill
          ..color = node.color.withOpacity(0.28 * depth)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.9),
      );
      
      nodePaint.color = Color.lerp(node.color, Colors.white, 0.25)!.withOpacity(0.9 * depth);
      canvas.drawCircle(p, size, nodePaint);
      
      canvas.drawCircle(
        p,
        size * 0.45,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(0.98 * depth),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _3DConstellationPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.mousePos != mousePos ||
        oldDelegate.isHovering != isHovering;
  }
}
