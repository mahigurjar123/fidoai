import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../shared/section_badge.dart';
import '../shared/gradient_button.dart';
import '../shared/tilt_3d.dart';
import '../shared/app_footer.dart';
import 'bloc/testimonials_cubit.dart';

class TestimonialsPage extends StatelessWidget {
  const TestimonialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          _HeroSection(),
          _FeaturedSection(),
          _GridSection(),
          _StatsSection(),
          _CTASection(),
          AppFooter(),
        ],
      ),
    );
  }
}

// ── 1. Hero Section ──────────────────────────────────────────────────────────
class _HeroSection extends StatefulWidget {
  const _HeroSection();
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late AnimationController _starsCtrl;
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _starsCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    _floatCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _starsCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 100),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _starsCtrl,
              builder: (_, __) => CustomPaint(
                painter: _StarsPainter(t: _starsCtrl.value),
              ),
            ),
          ),
          Column(
            children: [
              SectionBadge(label: "USER TESTIMONIALS", color: AppColors.gold),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (_, __) => ShaderMask(
                  shaderCallback: (b) => LinearGradient(
                    colors: const [
                      AppColors.gold,
                      AppColors.purple,
                      AppColors.cyan,
                      AppColors.gold
                    ],
                    stops: [
                      0.0,
                      _shimmerCtrl.value * 0.5,
                      _shimmerCtrl.value,
                      1.0
                    ],
                    tileMode: TileMode.mirror,
                  ).createShader(b),
                  child: Text(
                    "What Our Users Say",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1(context)
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Join 500K+ happy users who rely on Fido AI every day.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context)
                    .copyWith(fontSize: R.fs(context, 16, 20)),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final delay = i * 0.15;
                    final progress =
                        (_floatCtrl.value - delay).clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(0, -24 * progress),
                      child: Opacity(
                        opacity: progress,
                        child: const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 40),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "4.9 / 5.0  •  Based on 12,000+ reviews",
                style: GoogleFonts.inter(
                    color: AppColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double t;
  const _StarsPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint();
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final opacity = 0.08 + 0.25 * sin(t * 2 * pi + i * 0.7).abs();
      final radius = 0.5 + rng.nextDouble() * 1.5;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter o) => o.t != t;
}

// ── 2. Featured Section ───────────────────────────────────────────────────────
class _FeaturedSection extends StatefulWidget {
  const _FeaturedSection();
  @override
  State<_FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<_FeaturedSection> {
  Timer? _timer;
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _forward = true;
      context.read<TestimonialsCubit>().next();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _prev() {
    setState(() => _forward = false);
    context.read<TestimonialsCubit>().prev();
  }

  void _next() {
    setState(() => _forward = true);
    context.read<TestimonialsCubit>().next();
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 80),
      color: const Color(0xFF080820),
      child: Column(
        children: [
          SectionBadge(label: "FEATURED REVIEW", color: AppColors.purple),
          const SizedBox(height: 32),
          BlocBuilder<TestimonialsCubit, TestimonialsState>(
            builder: (ctx, state) {
              final t = testimonials[state.currentIndex];
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, anim) {
                  final offset = _forward
                      ? Tween<Offset>(
                          begin: const Offset(0.25, 0), end: Offset.zero)
                      : Tween<Offset>(
                          begin: const Offset(-0.25, 0), end: Offset.zero);
                  return SlideTransition(
                    position: offset.animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic)),
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: Tilt3DCard(
                  key: ValueKey(state.currentIndex),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0C24),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: t.color.withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: t.color.withOpacity(0.18),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote_rounded,
                              color: t.color, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            '"${t.quote}"',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: R.fs(context, 16, 22),
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [
                                    t.color,
                                    t.color.withOpacity(0.5)
                                  ]),
                                  boxShadow: [
                                    BoxShadow(
                                        color: t.color.withOpacity(0.4),
                                        blurRadius: 16)
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  t.initials,
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(t.name,
                                        style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16)),
                                    Text(t.role,
                                        style: AppTextStyles.body(context)
                                            .copyWith(fontSize: 13)),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(
                                    5,
                                    (_) => const Icon(Icons.star_rounded,
                                        color: AppColors.gold, size: 20)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          BlocBuilder<TestimonialsCubit, TestimonialsState>(
            builder: (ctx, state) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavArrow(onTap: _prev, icon: Icons.chevron_left),
                const SizedBox(width: 20),
                Row(
                  children: List.generate(testimonials.length, (i) {
                    return GestureDetector(
                      onTap: () => ctx.read<TestimonialsCubit>().goTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == state.currentIndex ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: i == state.currentIndex
                              ? AppColors.primaryGrad
                              : null,
                          color: i == state.currentIndex
                              ? null
                              : AppColors.border,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 20),
                _NavArrow(onTap: _next, icon: Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _NavArrow({required this.onTap, required this.icon});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1.5),
          color: const Color(0xFF0C0C24),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ── 3. Grid Section ──────────────────────────────────────────────────────────
class _GridSection extends StatefulWidget {
  const _GridSection();
  @override
  State<_GridSection> createState() => _GridSectionState();
}

class _GridSectionState extends State<_GridSection> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);
    return VisibilityDetector(
      key: const Key('grid-testimonials'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_visible) {
          setState(() => _visible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: 80),
        child: Column(
          children: [
            SectionBadge(label: "ALL REVIEWS", color: AppColors.cyan),
            const SizedBox(height: 12),
            Text("Every Voice Matters",
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(context)),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (context, constraints) {
              final cols = isMobile ? 1 : 2;
              final cardWidth = cols == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 24) / 2;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: List.generate(testimonials.length, (i) {
                  final t = testimonials[i];
                  return AnimatedOpacity(
                    opacity: _visible ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 400 + i * 150),
                    child: AnimatedSlide(
                      offset:
                          _visible ? Offset.zero : const Offset(0, 0.2),
                      duration: Duration(milliseconds: 400 + i * 150),
                      curve: Curves.easeOutCubic,
                      child: SizedBox(
                        width: cardWidth,
                        child: Tilt3DCard(
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C0C24),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: t.color.withOpacity(0.3),
                                  width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                    color: t.color.withOpacity(0.1),
                                    blurRadius: 24)
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [
                                        t.color,
                                        t.color.withOpacity(0.4)
                                      ]),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(t.initials,
                                        style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(t.name,
                                            style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14)),
                                        Text(t.role,
                                            style: AppTextStyles.body(
                                                    context)
                                                .copyWith(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                        5,
                                        (_) => const Icon(
                                            Icons.star_rounded,
                                            color: AppColors.gold,
                                            size: 16)),
                                  ),
                                ]),
                                const SizedBox(height: 16),
                                Text('"${t.quote}"',
                                    style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.6,
                                        fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── 4. Stats Section ─────────────────────────────────────────────────────────
class _StatsSection extends StatefulWidget {
  const _StatsSection();
  @override
  State<_StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<_StatsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  bool _visible = false;

  static const _stats = [
    _StatData('4.9★', 'Average Rating', AppColors.gold, 0.98),
    _StatData('500K+', 'Happy Users', AppColors.purple, 0.85),
    _StatData('98%', 'Would Recommend', AppColors.cyan, 0.98),
    _StatData('10M+', 'AI Interactions', AppColors.blue, 0.92),
  ];

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);
    return VisibilityDetector(
      key: const Key('stats-section-testimonials'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_visible) {
          setState(() => _visible = true);
          _progressCtrl.forward();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: 80),
        color: const Color(0xFF080820),
        child: Column(
          children: [
            SectionBadge(label: "BY THE NUMBERS", color: AppColors.pink),
            const SizedBox(height: 12),
            Text("Trusted Worldwide",
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(context)),
            const SizedBox(height: 56),
            LayoutBuilder(builder: (ctx, constraints) {
              final cols = isMobile ? 2 : 4;
              final spacing = (cols - 1) * 24.0;
              final itemW = (constraints.maxWidth - spacing) / cols;
              return Wrap(
                spacing: 24,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: _stats.map((s) {
                  return SizedBox(
                    width: itemW,
                    child: AnimatedBuilder(
                      animation: _progressCtrl,
                      builder: (_, __) => Column(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CustomPaint(
                              painter: _RingPainter(
                                progress:
                                    _progressCtrl.value * s.progress,
                                color: s.color,
                              ),
                              child: Center(
                                child: Text(s.value,
                                    style: GoogleFonts.inter(
                                        color: s.color,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(s.label,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(context)
                                  .copyWith(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  final String value;
  final String label;
  final Color color;
  final double progress;
  const _StatData(this.value, this.label, this.color, this.progress);
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 8;
    final trackPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

// ── 5. CTA Section ───────────────────────────────────────────────────────────
class _CTASection extends StatelessWidget {
  const _CTASection();

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 100),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: Geo3DBg(color: AppColors.purple)),
          Column(
            children: [
              Text("Join the Community",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1(context))
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.15, end: 0),
              const SizedBox(height: 16),
              Text(
                "Be part of 500K+ users who love Fido AI.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context)
                    .copyWith(fontSize: R.fs(context, 15, 18)),
              ).animate().fadeIn(duration: 600.ms, delay: 150.ms),
              const SizedBox(height: 40),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  GradientButton(label: "Start Free", onTap: () {}),
                  GradientButton(
                      label: "Read All Reviews",
                      onTap: () {},
                      outlined: true),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            ],
          ),
        ],
      ),
    );
  }
}
