import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_theme.dart';
import '../shared/section_badge.dart';
import '../shared/gradient_button.dart';
import '../shared/glass_card.dart';
import '../shared/tilt_3d.dart';
import '../shared/app_footer.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          _HeroSection(),
          _TimelineSection(),
          _DemoSection(),
          _ArchSection(),
          _CTASection(),
          AppFooter(),
        ],
      ),
    );
  }
}

// ── 1. Hero Section ──────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 100),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: Geo3DBg(color: AppColors.blue)),
          Column(
            children: [
              SectionBadge(label: "HOW IT WORKS", color: AppColors.cyan),
              const SizedBox(height: 24),
              Text(
                "Simple Setup,",
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(context),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              ShaderMask(
                shaderCallback: (b) => AppColors.cyanGrad.createShader(b),
                child: Text(
                  "Powerful Results",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1(context).copyWith(color: Colors.white),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
              Text(
                "From prompt to result in 3 simple steps. No learning curve required.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context)
                    .copyWith(fontSize: R.fs(context, 15, 19)),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Float3D(
                      amplitude: 8,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.purple.withOpacity(0.2),
                          border: Border.all(
                              color: AppColors.purple.withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: AppColors.purple, size: 28),
                      )),
                  const SizedBox(width: 20),
                  Float3D(
                      amplitude: 12,
                      period: const Duration(seconds: 3),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.blue.withOpacity(0.2),
                          border: Border.all(
                              color: AppColors.blue.withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.memory_rounded,
                            color: AppColors.blue, size: 28),
                      )),
                  const SizedBox(width: 20),
                  Float3D(
                      amplitude: 6,
                      period: const Duration(seconds: 5),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.cyan.withOpacity(0.2),
                          border: Border.all(
                              color: AppColors.cyan.withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            color: AppColors.cyan, size: 28),
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 2. Timeline Section ───────────────────────────────────────────────────────
class _TimelineSection extends StatefulWidget {
  const _TimelineSection();
  @override
  State<_TimelineSection> createState() => _TimelineSectionState();
}

class _TimelineSectionState extends State<_TimelineSection>
    with TickerProviderStateMixin {
  bool _visible = false;
  late List<AnimationController> _nodeCtrl;
  late AnimationController _lineCtrl;

  static const _steps = [
    _Step('01', Icons.edit_rounded, 'Type Your Prompt', AppColors.purple,
        'Enter your request in natural language. Fido AI understands context, intent, and nuance across 40+ languages.',
        ['Natural language input', 'File attachments', '40+ languages']),
    _Step('02', Icons.memory_rounded, 'AI Smart Routing', AppColors.blue,
        'Your request is automatically routed to the optimal AI model — GPT-4o for reasoning, DALL-E 3 for images.',
        ['Auto model selection', 'Parallel processing', 'GPT-4o + DALL-E 3']),
    _Step('03', Icons.bolt_rounded, 'Instant Results', AppColors.cyan,
        'Receive streaming responses in milliseconds. Results appear token-by-token and are auto-saved to history.',
        ['<100ms latency', 'Streaming output', 'Auto-saved history']),
  ];

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _nodeCtrl = List.generate(
        3,
        (i) =>
            AnimationController(vsync: this, duration: const Duration(seconds: 2))
              ..repeat(reverse: true));
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    for (final c in _nodeCtrl) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);
    return VisibilityDetector(
      key: const Key('timeline-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.15 && !_visible) {
          setState(() => _visible = true);
          _lineCtrl.forward();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: 80),
        color: const Color(0xFF080820),
        child: Column(
          children: [
            SectionBadge(label: "THE PROCESS", color: AppColors.blue),
            const SizedBox(height: 12),
            Text("3 Steps to AI Magic",
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(context)),
            const SizedBox(height: 60),
            isMobile ? _buildMobileTimeline() : _buildDesktopTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTimeline() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Animated connecting line
        Positioned(
          top: 44,
          left: 120,
          right: 120,
          child: AnimatedBuilder(
            animation: _lineCtrl,
            builder: (_, __) => CustomPaint(
              painter: _TimelinePainter(progress: _lineCtrl.value),
              size: const Size(double.infinity, 2),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _steps.asMap().entries.map((e) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: e.key == 0 ? 0 : 16,
                  right: e.key == 2 ? 0 : 16,
                ),
                child: _TimelineCard(
                  step: e.value,
                  nodeCtrl: _nodeCtrl[e.key],
                  visible: _visible,
                  delay: e.key * 200,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMobileTimeline() {
    return Column(
      children: _steps.asMap().entries.map((e) {
        return Column(
          children: [
            _TimelineCard(
              step: e.value,
              nodeCtrl: _nodeCtrl[e.key],
              visible: _visible,
              delay: e.key * 200,
            ),
            if (e.key < 2)
              AnimatedBuilder(
                animation: _lineCtrl,
                builder: (_, __) => Container(
                  width: 2,
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        e.value.color
                            .withOpacity(_lineCtrl.value),
                        _steps[e.key + 1].color
                            .withOpacity(_lineCtrl.value * 0.5),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final _Step step;
  final AnimationController nodeCtrl;
  final bool visible;
  final int delay;

  const _TimelineCard({
    required this.step,
    required this.nodeCtrl,
    required this.visible,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 600 + delay),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.2),
        duration: Duration(milliseconds: 600 + delay),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: nodeCtrl,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.color
                            .withOpacity(0.15 + 0.15 * nodeCtrl.value),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        step.color
                            .withOpacity(0.2 + 0.15 * nodeCtrl.value),
                        step.color.withOpacity(0.05),
                      ]),
                      border: Border.all(
                        color: step.color
                            .withOpacity(0.5 + 0.3 * nodeCtrl.value),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: step.color
                              .withOpacity(0.3 + 0.2 * nodeCtrl.value),
                          blurRadius: 20 + 12 * nodeCtrl.value,
                        )
                      ],
                    ),
                    child: Float3D(
                      amplitude: 4,
                      child: Icon(step.icon, color: step.color, size: 28),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: step.color.withOpacity(0.15),
                border: Border.all(color: step.color.withOpacity(0.4)),
              ),
              child: Text("Step ${step.num}",
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: step.color,
                      letterSpacing: 1.2)),
            ),
            const SizedBox(height: 16),
            GlassCard(
              glowColor: step.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(step.desc,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.6)),
                  const SizedBox(height: 14),
                  ...step.facts.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: step.color)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(f,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.65))),
                          ),
                        ]),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final double progress;
  const _TimelinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final grad = LinearGradient(colors: [
      AppColors.purple.withOpacity(0.6),
      AppColors.blue.withOpacity(0.6),
      AppColors.cyan.withOpacity(0.6),
    ]);
    paint.shader = grad.createShader(
        Rect.fromLTWH(0, 0, size.width * progress, size.height));
    double x = 0;
    final end = size.width * progress;
    while (x < end) {
      canvas.drawLine(Offset(x, 0), Offset((x + 8).clamp(0, end), 0), paint);
      x += 16;
    }
  }

  @override
  bool shouldRepaint(_TimelinePainter o) => o.progress != progress;
}

class _Step {
  final String num;
  final IconData icon;
  final String title;
  final Color color;
  final String desc;
  final List<String> facts;
  const _Step(this.num, this.icon, this.title, this.color, this.desc,
      this.facts);
}

// ── 3. Demo Section ───────────────────────────────────────────────────────────
class _DemoSection extends StatefulWidget {
  const _DemoSection();
  @override
  State<_DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<_DemoSection>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _typeCtrl;
  bool _visible = false;
  int _lineCount = 0;

  static const _lines = [
    '> fido chat "Explain quantum computing in simple terms"',
    '  Connecting to GPT-4o... ✓',
    '  Streaming response: Quantum computing is like...',
    '',
    '> fido image "Futuristic city at night, neon lights"',
    '  Routing to DALL-E 3... ✓',
    '  Generating 1024x1024 HD image...',
    '  Done! Image saved to /outputs/city_neon.png ✓',
    '',
    '> fido status',
    '  API: Connected ✓  |  Model: GPT-4o  |  Latency: 87ms',
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _typeCtrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _lines.length * 400));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  void _startTyping() {
    if (_lineCount > 0) return;
    Future.doWhile(() async {
      if (_lineCount >= _lines.length || !mounted) return false;
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) setState(() => _lineCount++);
      return _lineCount < _lines.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    return VisibilityDetector(
      key: const Key('demo-section-hiw'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_visible) {
          setState(() => _visible = true);
          _startTyping();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: 80),
        child: Column(
          children: [
            SectionBadge(label: "LIVE DEMO", color: AppColors.cyan),
            const SizedBox(height: 12),
            Text("See It In Action",
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(context)),
            const SizedBox(height: 8),
            Text("Watch Fido AI work in real time",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context)),
            const SizedBox(height: 40),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withOpacity(
                            0.1 + 0.12 * _glowCtrl.value),
                        blurRadius: 30 + 20 * _glowCtrl.value,
                        spreadRadius: 1,
                      )
                    ],
                    border: Border.all(
                      color: AppColors.cyan.withOpacity(
                          0.2 + 0.15 * _glowCtrl.value),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: const Color(0xFF060614),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                                width: 12,
                                height: 12,
                                margin:
                                    const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFF5F57))),
                            Container(
                                width: 12,
                                height: 12,
                                margin:
                                    const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFFBD2E))),
                            Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF28C840))),
                            const SizedBox(width: 12),
                            Text("fido-ai terminal",
                                style: GoogleFonts.firaCode(
                                    fontSize: 12,
                                    color: AppColors.textMuted)),
                          ]),
                          const SizedBox(height: 20),
                          ...List.generate(
                              _lineCount.clamp(0, _lines.length),
                              (i) {
                            final line = _lines[i];
                            final isCommand =
                                line.startsWith('>');
                            return Text(
                              line.isEmpty ? ' ' : line,
                              style: GoogleFonts.firaCode(
                                fontSize:
                                    R.fs(context, 11, 13),
                                color: isCommand
                                    ? AppColors.cyan
                                    : Colors.white
                                        .withOpacity(0.7),
                                height: 1.7,
                              ),
                            );
                          }),
                          if (_lineCount < _lines.length)
                            Row(children: [
                              Text("> ",
                                  style: GoogleFonts.firaCode(
                                      fontSize: 13,
                                      color: AppColors.cyan)),
                              _BlinkCursor(),
                            ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ).animate(target: _visible ? 1 : 0)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

class _BlinkCursor extends StatefulWidget {
  @override
  State<_BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<_BlinkCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Opacity(
          opacity: _c.value,
          child:
              Container(width: 8, height: 14, color: AppColors.cyan),
        ),
      );
}

// ── 4. Architecture Section ───────────────────────────────────────────────────
class _ArchSection extends StatefulWidget {
  const _ArchSection();
  @override
  State<_ArchSection> createState() => _ArchSectionState();
}

class _ArchSectionState extends State<_ArchSection> {
  bool _visible = false;

  static const _pillars = [
    _Pillar('Flutter', 'Cross-platform UI framework\nwith 60fps animations',
        AppColors.blue, Icons.flutter_dash),
    _Pillar('GPT-4o', '128K context window\nMultimodal reasoning',
        AppColors.purple, Icons.psychology_rounded),
    _Pillar('Edge CDN', 'Global infrastructure\n<100ms worldwide latency',
        AppColors.cyan, Icons.language_rounded),
    _Pillar('AES-256', 'Military-grade encryption\nZero data retention',
        AppColors.pink, Icons.shield_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);
    return VisibilityDetector(
      key: const Key('arch-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_visible) {
          setState(() => _visible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: 80),
        color: const Color(0xFF080820),
        child: Column(
          children: [
            SectionBadge(label: "ARCHITECTURE", color: AppColors.purple),
            const SizedBox(height: 12),
            Text("Built on Modern Architecture",
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(context)),
            const SizedBox(height: 8),
            Text("4 pillars that make Fido AI blazing fast and secure",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context)),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (context, constraints) {
              final cols = isMobile ? 2 : 4;
              final spacing = (cols - 1) * 20.0;
              final cardWidth = (constraints.maxWidth - spacing) / cols;
              return Stack(
                children: [
                  // Connection lines between nodes
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _visible ? 1 : 0,
                      duration: const Duration(milliseconds: 800),
                      child: CustomPaint(
                        painter: _ConnectorPainter(cols: cols),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: _pillars.asMap().entries.map((e) {
                      final p = e.value;
                      return AnimatedOpacity(
                        opacity: _visible ? 1 : 0,
                        duration:
                            Duration(milliseconds: 400 + e.key * 150),
                        child: AnimatedSlide(
                          offset: _visible
                              ? Offset.zero
                              : const Offset(0, 0.2),
                          duration:
                              Duration(milliseconds: 400 + e.key * 150),
                          curve: Curves.easeOutCubic,
                          child: SizedBox(
                            width: cardWidth,
                            child: _HexCard(pillar: p),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HexCard extends StatefulWidget {
  final _Pillar pillar;
  const _HexCard({required this.pillar});
  @override
  State<_HexCard> createState() => _HexCardState();
}

class _HexCardState extends State<_HexCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pillar;
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _rotCtrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _rotCtrl.reverse();
      },
      child: AnimatedBuilder(
        animation: _rotCtrl,
        builder: (_, __) => Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_rotCtrl.value * pi * 0.15),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovered
                    ? p.color.withOpacity(0.6)
                    : p.color.withOpacity(0.25),
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: p.color.withOpacity(_hovered ? 0.22 : 0.08),
                  blurRadius: _hovered ? 28 : 12,
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [p.color, p.color.withOpacity(0.5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: p.color.withOpacity(0.4),
                          blurRadius: 16)
                    ],
                  ),
                  child: Icon(p.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text(p.name,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(p.desc,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(context)
                        .copyWith(fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pillar {
  final String name;
  final String desc;
  final Color color;
  final IconData icon;
  const _Pillar(this.name, this.desc, this.color, this.icon);
}

class _ConnectorPainter extends CustomPainter {
  final int cols;
  const _ConnectorPainter({required this.cols});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    if (cols >= 2) {
      final midY = size.height / 2;
      canvas.drawLine(
          Offset(size.width * 0.25, midY),
          Offset(size.width * 0.75, midY),
          paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter o) => false;
}

// ── 5. CTA Section ───────────────────────────────────────────────────────────
class _CTASection extends StatefulWidget {
  const _CTASection();
  @override
  State<_CTASection> createState() => _CTASectionState();
}

class _CTASectionState extends State<_CTASection>
    with SingleTickerProviderStateMixin {
  late AnimationController _countCtrl;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _countCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 30))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    return VisibilityDetector(
      key: const Key('cta-hiw'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_visible) {
          setState(() => _visible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(child: Geo3DBg(color: AppColors.cyan)),
            Column(
              children: [
                SectionBadge(label: "GET STARTED", color: AppColors.cyan),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.cyanGrad.createShader(b),
                  child: Text(
                    "Start in 30 Seconds",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1(context)
                        .copyWith(color: Colors.white),
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _CountBadge(
                        "1", "Sign Up", AppColors.purple, _visible),
                    _CountBadge(
                        "2", "Pick a Plan", AppColors.blue, _visible),
                    _CountBadge(
                        "3", "Start Creating", AppColors.cyan, _visible),
                  ],
                ),
                const SizedBox(height: 40),
                GradientButton(
                  label: "Start Free Now",
                  onTap: () {},
                  icon: Icons.rocket_launch_rounded,
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                const SizedBox(height: 16),
                Text("No credit card required",
                    style: AppTextStyles.body(context)
                        .copyWith(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatefulWidget {
  final String num;
  final String label;
  final Color color;
  final bool animate;
  const _CountBadge(this.num, this.label, this.color, this.animate);
  @override
  State<_CountBadge> createState() => _CountBadgeState();
}

class _CountBadgeState extends State<_CountBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: widget.color.withOpacity(0.1 + 0.05 * _c.value),
            border: Border.all(
                color: widget.color.withOpacity(0.4 + 0.2 * _c.value)),
            boxShadow: [
              BoxShadow(
                  color: widget.color
                      .withOpacity(0.1 + 0.1 * _c.value),
                  blurRadius: 12 + 8 * _c.value)
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    widget.color,
                    widget.color.withOpacity(0.6)
                  ])),
              alignment: Alignment.center,
              child: Text(widget.num,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(widget.label,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}
