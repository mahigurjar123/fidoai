import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../shared/gradient_button.dart';
import '../shared/section_badge.dart';
import '../shared/app_footer.dart';
import '../shared/svg_icons.dart';
import 'bloc/home_cubit.dart';
import 'widgets/sphere_3d.dart';

// Map FeatureModel.icon (IconData) → FidoIcon
FidoIcon _featureIcon(IconData icon) {
  if (icon == Icons.chat_bubble_rounded) return FidoIcon.chat;
  if (icon == Icons.auto_awesome_rounded) return FidoIcon.sparkle;
  if (icon == Icons.bolt_rounded) return FidoIcon.bolt;
  if (icon == Icons.shield_rounded) return FidoIcon.shield;
  return FidoIcon.sparkle;
}

// ═══════════════════════════════════════════════════════════
// MAIN HOME PAGE — 8 Sections
// ═══════════════════════════════════════════════════════════
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          _HeroSection(),
          _TrustedBySection(),
          _FeaturesSection(),
          _HowItWorksSection(),
          _DemoSection(),
          _StatsSection(),
          _PricingPreviewSection(),
          _CTASection(),
          AppFooter(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION 1 — HERO
// ═══════════════════════════════════════════════════════════
class _HeroSection extends StatefulWidget {
  const _HeroSection();
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> with TickerProviderStateMixin {
  late AnimationController _shimCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _glowCtrl;

  static const _stats = [
    ('500K+', 'Active Users'),
    ('10M+', 'AI Requests/Day'),
    ('99.9%', 'Uptime SLA'),
    ('4.9★', 'User Rating'),
  ];

  static const _tags = [
    'Flutter Web', 'GPT-4o', 'DALL·E 3', 'Stable Diffusion',
    'WebGL', 'MVVM + Bloc', '3D Canvas', 'Edge CDN',
  ];

  @override
  void initState() {
    super.initState();
    _shimCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = R.mobile(context);
    final hPad    = R.hp(context);
    final sphereSz = isMobile ? 220.0 : R.tablet(context) ? 300.0 : 400.0;

    return Stack(
      children: [
        // Animated circuit board background
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _shimCtrl,
              builder: (_, __) => CustomPaint(
                painter: _CircuitBgPainter(t: _shimCtrl.value),
              ),
            ),
          ),
        ),
        Container(
      padding: EdgeInsets.only(top: 100, left: hPad, right: hPad, bottom: 80),
      child: isMobile
          ? Column(children: [
              _buildSphere(sphereSz),
              const SizedBox(height: 40),
              _buildContent(context, true),
              const SizedBox(height: 48),
              _buildStats(context, true),
              const SizedBox(height: 28),
              _buildTags(context),
            ])
          : Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(flex: 55, child: _buildContent(context, false)),
                const SizedBox(width: 40),
                Expanded(flex: 45, child: Center(child: _buildSphere(sphereSz))),
              ]),
              const SizedBox(height: 64),
              _buildStats(context, false),
              const SizedBox(height: 28),
              _buildTags(context),
            ]),
        ),
      ],
    );
  }

  Widget _buildSphere(double sz) => AnimatedBuilder(
    animation: _floatCtrl,
    builder: (_, child) => Transform.translate(
      offset: Offset(0, -14 * _floatCtrl.value),
      child: child,
    ),
    child: RepaintBoundary(
      child: Sphere3D(size: sz)
          .animate()
          .fadeIn(duration: 1200.ms, delay: 400.ms)
          .scale(begin: const Offset(.7, .7), end: const Offset(1, 1), duration: 1200.ms),
    ),
  );

  Widget _buildContent(BuildContext ctx, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Badge
        const SectionBadge(label: '✨  NEXT-GEN AI PLATFORM')
            .animate().fadeIn(duration: 700.ms, delay: 200.ms).slideX(begin: -.2, end: 0),
        const SizedBox(height: 24),

        // Shimmer headline
        AnimatedBuilder(
          animation: _shimCtrl,
          builder: (_, __) => Column(
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                'The Future of',
                style: GoogleFonts.inter(
                  fontSize: R.fs(ctx, 34, 64),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -2,
                ),
                textAlign: isMobile ? TextAlign.center : TextAlign.left,
              ),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: const [AppColors.purple, AppColors.blue, AppColors.cyan, AppColors.purple],
                  stops: [0, _shimCtrl.value, min(_shimCtrl.value + .35, 1), 1],
                  tileMode: TileMode.mirror,
                ).createShader(b),
                child: Text(
                  'Artificial Intelligence',
                  style: GoogleFonts.inter(
                    fontSize: R.fs(ctx, 34, 64),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -2,
                  ),
                  textAlign: isMobile ? TextAlign.center : TextAlign.left,
                ),
              ),
              Text(
                '— In Your Hands',
                style: GoogleFonts.inter(
                  fontSize: R.fs(ctx, 22, 46),
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(.45),
                  height: 1.2,
                  letterSpacing: -1,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: isMobile ? TextAlign.center : TextAlign.left,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: .2, end: 0),
        const SizedBox(height: 24),

        // Typewriter
        SizedBox(
          height: 50,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Powered by GPT-4o, DALL·E 3 and Stable Diffusion.',
                textStyle: GoogleFonts.inter(fontSize: R.fs(ctx, 13, 16), color: AppColors.textSecondary, height: 1.6),
                speed: 40.ms,
              ),
              TypewriterAnimatedText(
                'Generate stunning images from simple text prompts.',
                textStyle: GoogleFonts.inter(fontSize: R.fs(ctx, 13, 16), color: AppColors.textSecondary, height: 1.6),
                speed: 40.ms,
              ),
              TypewriterAnimatedText(
                'Process data in real-time with edge-optimized AI.',
                textStyle: GoogleFonts.inter(fontSize: R.fs(ctx, 13, 16), color: AppColors.textSecondary, height: 1.6),
                speed: 40.ms,
              ),
            ],
            repeatForever: true,
            displayFullTextOnTap: true,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
        const SizedBox(height: 32),

        // Buttons
        Wrap(
          spacing: 14,
          runSpacing: 12,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            GradientButton(
              label: 'Start for Free',
              icon: Icons.rocket_launch_rounded,
              onTap: () => context.go('/contact'),
            ),
            GradientButton(
              label: 'Explore Features',
              outlined: true,
              onTap: () => context.go('/features'),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 900.ms).slideY(begin: .2, end: 0),
      ],
    );
  }

  Widget _buildStats(BuildContext context, bool isMobile) {
    return VisibilityDetector(
      key: const Key('home-stats'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > .5) context.read<HomeCubit>().activateCounters();
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (ctx, state) => AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, child) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border.withOpacity(.6 + .4 * _glowCtrl.value)),
              gradient: LinearGradient(colors: [Colors.white.withOpacity(.04), Colors.white.withOpacity(.01)]),
              boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(.05 + .04 * _glowCtrl.value), blurRadius: 30)],
            ),
            child: child,
          ),
          child: isMobile
              ? Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: _stats.asMap().entries.map((e) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 64) / 2,
                    child: _StatItem(value: e.value.$1, label: e.value.$2, doAnimate: state.countersActive),
                  )).toList(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _stats.map((s) => _StatItem(value: s.$1, label: s.$2, doAnimate: state.countersActive)).toList(),
                ),
        ),
      ),
    ).animate().fadeIn(duration: 700.ms, delay: 1100.ms);
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _tags.asMap().entries.map((e) =>
        _Tag(label: e.value)
            .animate()
            .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 1300 + e.key * 60))
            .slideX(begin: -.15, end: 0),
      ).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION 2 — TRUSTED BY (Infinite scroll)
// ═══════════════════════════════════════════════════════════
// SECTION 2 — TRUSTED BY (Infinite 3D card scroll)
// ═══════════════════════════════════════════════════════════
class _TrustedBySection extends StatefulWidget {
  const _TrustedBySection();
  @override
  State<_TrustedBySection> createState() => _TrustedBySectionState();
}

class _TrustedBySectionState extends State<_TrustedBySection>
    with TickerProviderStateMixin {
  late AnimationController _scrollCtrl;
  late AnimationController _pulseCtrl;

  static const _logos = [
    ('NEXUS',   AppColors.purple, FidoIcon.hub),
    ('ORION',   AppColors.blue,   FidoIcon.globe),
    ('STELLAR', AppColors.cyan,   FidoIcon.star),
    ('VERTEX',  AppColors.pink,   FidoIcon.network),
    ('PRISM',   AppColors.purple, FidoIcon.diamond),
    ('APEX',    AppColors.blue,   FidoIcon.trending),
    ('FLUX',    AppColors.cyan,   FidoIcon.flash),
    ('NOVA',    AppColors.pink,   FidoIcon.sparkle),
  ];

  // Each badge is 200px wide; two sets = 1600px total scrollable width
  static const double _cardW = 200.0;
  static const double _totalW = _cardW * 8;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 32))..repeat();
    _pulseCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _scrollCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hPad = R.hp(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 70, horizontal: hPad),
      child: Column(
        children: [
          // Header
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Text(
              'TRUSTED BY 500K+ PROFESSIONALS WORLDWIDE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted.withOpacity(.5 + .3 * _pulseCtrl.value),
                letterSpacing: 2.5,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(duration: 700.ms),
          const SizedBox(height: 36),

          // Infinite scroll strip with edge fades
          SizedBox(
            height: 90,
            child: ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.06, 0.94, 1.0],
              ).createShader(b),
              blendMode: BlendMode.dstIn,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _scrollCtrl,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(-_scrollCtrl.value * _totalW, 0),
                    child: child,
                  ),
                  // OverflowBox lets the Row use its natural width (1600×2 px)
                  // without triggering the yellow overflow indicator.
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: _totalW * 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._logos.map((l) => _LogoBadge3D(name: l.$1, color: l.$2, icon: l.$3, pulse: _pulseCtrl)),
                        ..._logos.map((l) => _LogoBadge3D(name: l.$1, color: l.$2, icon: l.$3, pulse: _pulseCtrl)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3D Holographic Logo Badge ───────────────────────────────────────────────
class _LogoBadge3D extends StatefulWidget {
  final String name;
  final Color color;
  final FidoIcon icon;
  final AnimationController pulse;
  const _LogoBadge3D({required this.name, required this.color,
      required this.icon, required this.pulse});
  @override
  State<_LogoBadge3D> createState() => _LogoBadge3DState();
}

class _LogoBadge3DState extends State<_LogoBadge3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  bool _h = false;
  double _tiltX = 0, _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000 + (widget.name.hashCode % 800).abs()),
    )..repeat(reverse: true);
  }

  @override
  void dispose() { _floatCtrl.dispose(); super.dispose(); }

  void _onHover(PointerEvent e) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(e.position);
    setState(() {
      _tiltX = (local.dy / box.size.height - .5) * 20;
      _tiltY = (local.dx / box.size.width  - .5) * -20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: _h ? _onHover : null,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit:  (_) => setState(() { _h = false; _tiltX = 0; _tiltY = 0; }),
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatCtrl, widget.pulse]),
          builder: (_, __) => Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0012)
              ..rotateX(_tiltX * pi / 180)
              ..rotateY(_tiltY * pi / 180)
              ..translate(0.0, _h ? -6.0 : -_floatCtrl.value * 4.0),
            alignment: Alignment.center,
            child: Container(
              width: 192,
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    widget.color.withOpacity(_h ? .18 : .08),
                    widget.color.withOpacity(_h ? .06 : .02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: widget.color.withOpacity(_h ? .7 : .22 + .08 * widget.pulse.value),
                  width: _h ? 1.5 : 1.0,
                ),
                boxShadow: _h ? [
                  BoxShadow(color: widget.color.withOpacity(.35), blurRadius: 22, spreadRadius: 0),
                  BoxShadow(color: widget.color.withOpacity(.15), blurRadius: 44, spreadRadius: 2),
                ] : [
                  BoxShadow(color: widget.color.withOpacity(.06 + .04 * widget.pulse.value), blurRadius: 12),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Floating SVG icon
                  Transform.translate(
                    offset: Offset(0, _h ? -2 : -_floatCtrl.value * 2),
                    child: AnimatedSvgIcon(
                      type: widget.icon,
                      color: widget.color,
                      size: _h ? 30 : 26,
                      duration: Duration(milliseconds: 2800 + (widget.name.hashCode % 600).abs()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.name,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _h ? Colors.white : widget.color.withOpacity(.75),
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION 3 — FEATURES (3D flip cards)
// ═══════════════════════════════════════════════════════════
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();
  @override
  Widget build(BuildContext context) {
    final hPad = R.hp(context);
    final cols  = R.mobile(context) ? 1 : R.tablet(context) ? 2 : 2;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: hPad),
      child: Column(
        children: [
          // Header
          Column(children: [
            const SectionBadge(label: 'CORE FEATURES', color: AppColors.purple),
            const SizedBox(height: 16),
            GradientText(
              text: 'Everything You Need',
              gradient: AppColors.primaryGrad,
              style: AppTextStyles.h1(context),
            ),
            const SizedBox(height: 12),
            Text('Four powerful AI tools in one platform.',
                style: AppTextStyles.body(context), textAlign: TextAlign.center),
          ]).animate().fadeIn(duration: 700.ms).slideY(begin: .2, end: 0),
          const SizedBox(height: 60),
          // Grid — fixed 300px height cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisExtent: 300,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: features.length,
            itemBuilder: (_, i) => _FeatureFlipCard(feature: features[i], index: i),
          ),
          const SizedBox(height: 40),
          GradientButton(
            label: 'See All Features',
            outlined: true,
            icon: Icons.arrow_forward_rounded,
            onTap: () => context.go('/features'),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
        ],
      ),
    );
  }
}

class _FeatureFlipCard extends StatefulWidget {
  final FeatureModel feature;
  final int index;
  const _FeatureFlipCard({required this.feature, required this.index});
  @override
  State<_FeatureFlipCard> createState() => _FeatureFlipCardState();
}

class _FeatureFlipCardState extends State<_FeatureFlipCard> with TickerProviderStateMixin {
  late AnimationController _borderCtrl;   // rotating neon border (3s loop)
  late AnimationController _iconCtrl;     // icon float (2.5s loop)
  late AnimationController _sparkleCtrl;  // orbital sparkle dots (2s loop)
  late AnimationController _flipCtrl;     // Y-axis card flip (550ms)

  double _tiltX = 0, _tiltY = 0;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _borderCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _iconCtrl    = AnimationController(vsync: this, duration: 2500.ms)..repeat(reverse: true);
    _sparkleCtrl = AnimationController(vsync: this, duration: 2000.ms)..repeat();
    _flipCtrl    = AnimationController(vsync: this, duration: 550.ms);
  }

  @override
  void dispose() {
    _borderCtrl.dispose();
    _iconCtrl.dispose();
    _sparkleCtrl.dispose();
    _flipCtrl.dispose();
    super.dispose();
  }

  void _onPointerHover(PointerEvent e) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(e.position);
    setState(() {
      _tiltX = (local.dy / box.size.height - .5) * 12;
      _tiltY = (local.dx / box.size.width  - .5) * -12;
    });
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    return Listener(
      onPointerHover: _hovered ? _onPointerHover : null,
      child: MouseRegion(
        onEnter: (_) { setState(() => _hovered = true); _flipCtrl.forward(); },
        onExit:  (_) { setState(() { _hovered = false; _tiltX = 0; _tiltY = 0; }); _flipCtrl.reverse(); },
        child: AnimatedBuilder(
          animation: Listenable.merge([_borderCtrl, _iconCtrl, _sparkleCtrl, _flipCtrl]),
          builder: (_, __) {
            final flipAngle = _flipCtrl.value * pi;
            final isBack    = flipAngle > pi / 2;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, .0012)
                ..rotateX(_tiltX * pi / 180)
                ..rotateY(flipAngle),
              alignment: Alignment.center,
              child: isBack
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: _back(f),
                    )
                  : _front(f),
            );
          },
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 200 + widget.index * 120))
    .slideY(begin: .15, end: 0);
  }

  // ── FRONT FACE ─────────────────────────────────────────────
  Widget _front(FeatureModel f) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: CustomPaint(
      painter: _NeonBorderPainter(t: _borderCtrl.value, color: f.color, intensity: .4),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              f.color.withOpacity(.08 + .04 * _iconCtrl.value),
              const Color(0xFF05050F),
            ],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent tag pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: f.color.withOpacity(.15),
                border: Border.all(color: f.color.withOpacity(.4)),
              ),
              child: Text(f.tag, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: f.color, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 14),
            // Icon with orbital sparkles
            SizedBox(
              width: 72, height: 72,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Floating icon
                  Positioned(
                    top: 4 - 5 * _iconCtrl.value,
                    left: 4, right: 4,
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: f.gradient,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(
                          color: f.color.withOpacity(.55 + .2 * _iconCtrl.value),
                          blurRadius: 20 + 10 * _iconCtrl.value,
                          spreadRadius: 1 + 2 * _iconCtrl.value,
                        )],
                      ),
                      child: AnimatedSvgIcon(type: _featureIcon(f.icon), color: Colors.white, size: 30),
                    ),
                  ),
                  // Orbital sparkle particles
                  for (int i = 0; i < 5; i++) ...[
                    Positioned(
                      left: 32 + 28 * cos(i * 2 * pi / 5 + _sparkleCtrl.value * 2 * pi),
                      top:  32 + 28 * sin(i * 2 * pi / 5 + _sparkleCtrl.value * 2 * pi),
                      child: Opacity(
                        opacity: (sin(_sparkleCtrl.value * 2 * pi + i * pi * .7) + 1) / 2 * .8,
                        child: Container(
                          width: i % 2 == 0 ? 5 : 3.5,
                          height: i % 2 == 0 ? 5 : 3.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: f.color,
                            boxShadow: [BoxShadow(color: f.color.withOpacity(.7), blurRadius: 5)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(f.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 5),
            Text(f.shortDesc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
            const Spacer(),
            Row(children: [
              Text('Hover to flip  ', style: GoogleFonts.inter(fontSize: 10, color: f.color.withOpacity(.8))),
              Icon(Icons.flip_rounded, size: 11, color: f.color.withOpacity(.8)),
            ]),
          ],
        ),
      ),
    ),
  );

  // ── BACK FACE ──────────────────────────────────────────────
  Widget _back(FeatureModel f) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: CustomPaint(
      painter: _NeonBorderPainter(t: _borderCtrl.value, color: f.color, intensity: 1.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [f.color.withOpacity(.18), f.color.withOpacity(.06), const Color(0xFF05050F)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: f.gradient,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [BoxShadow(color: f.color.withOpacity(.55), blurRadius: 12)],
                ),
                child: AnimatedSvgIcon(type: _featureIcon(f.icon), color: f.color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(f.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
            ]),
            const SizedBox(height: 9),
            Text(f.longDesc, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary, height: 1.55)),
            const SizedBox(height: 12),
            // Bullet list — each bullet animates in as flip completes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: f.bullets.asMap().entries.map((e) {
                  // Staggered entrance: starts at 60% through the flip
                  final vis = ((_flipCtrl.value - .5 - e.key * .08).clamp(0.0, .15) / .15);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Opacity(
                      opacity: vis,
                      child: Transform.translate(
                        offset: Offset(0, (1 - vis) * 8),
                        child: Row(children: [
                          Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: f.color.withOpacity(.2),
                              border: Border.all(color: f.color.withOpacity(.6)),
                            ),
                            child: Icon(Icons.check_rounded, color: f.color, size: 10),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(e.value, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(.88)))),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Rotating neon SweepGradient border ────────────────────────────────────────
class _NeonBorderPainter extends CustomPainter {
  final double t;         // 0–1 (animation value)
  final Color color;
  final double intensity; // 0.4 = front, 1.0 = back

  const _NeonBorderPainter({required this.t, required this.color, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final rect  = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    // Glass background fill
    canvas.drawRRect(rrect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(.07 + .03 * intensity), const Color(0xFF04040E)],
      ).createShader(rect));

    // Rotating SweepGradient border
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: t * 2 * pi,
          endAngle:   t * 2 * pi + 2 * pi,
          colors: [
            color.withOpacity(.0),
            color.withOpacity(.9 * intensity),
            color.withOpacity(.5 * intensity),
            color.withOpacity(.0),
          ],
          stops: const [0.0, 0.25, 0.75, 1.0],
        ).createShader(rect)
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 1.5 + intensity,
    );

    // Outer glow ring
    if (intensity > .5) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(1.5), const Radius.circular(21.5)),
        Paint()
          ..color = color.withOpacity(.12 * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
  }

  @override
  bool shouldRepaint(_NeonBorderPainter o) => o.t != t || o.intensity != intensity;
}

// ═══════════════════════════════════════════════════════════
// SECTION 4 — HOW IT WORKS (Animated timeline)
// ═══════════════════════════════════════════════════════════
class _HowItWorksSection extends StatefulWidget {
  const _HowItWorksSection();
  @override
  State<_HowItWorksSection> createState() => _HowItWorksSectionState();
}

class _HowItWorksSectionState extends State<_HowItWorksSection> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _lineCtrl;
  bool _visible = false;

  static const _steps = [
    (FidoIcon.person, AppColors.purple, 'Create Account',
     'Sign up in 30 seconds. No credit card required. Choose your plan and get instant access to all AI features.'),
    (FidoIcon.settings, AppColors.blue, 'Configure Your AI',
     'Personalize tone, style, language, and output preferences. Set up your workspace and connect your tools.'),
    (FidoIcon.sparkle, AppColors.cyan, 'Start Creating',
     'Generate images, chat with AI, process data in real-time. Export, share, and integrate anywhere.'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _lineCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); _lineCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hPad    = R.hp(context);
    final isMobile = R.mobile(context);

    return VisibilityDetector(
      key: const Key('how-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > .25 && !_visible) {
          setState(() => _visible = true);
          _lineCtrl.forward();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 100, horizontal: hPad),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF0A0A1A), const Color(0xFF0D0720), const Color(0xFF0A0A1A)],
          ),
        ),
        child: Column(
          children: [
            Column(children: [
              const SectionBadge(label: 'GET STARTED', color: AppColors.blue),
              const SizedBox(height: 16),
              GradientText(text: 'Up & Running in Minutes', gradient: AppColors.blueGrad, style: AppTextStyles.h1(context)),
              const SizedBox(height: 12),
              Text('Three steps to your AI-powered workflow.', style: AppTextStyles.body(context), textAlign: TextAlign.center),
            ]).animate().fadeIn(duration: 700.ms).slideY(begin: .2, end: 0),
            const SizedBox(height: 70),
            isMobile
                ? Column(children: _steps.asMap().entries.map((e) => _buildStepCard(context, e.key, e.value, true)).toList())
                : _buildDesktopSteps(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSteps(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Connecting line with animation
        Positioned(
          top: 52,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _lineCtrl,
            builder: (_, __) => CustomPaint(
              painter: _DashedLinePainter(
                progress: CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOutCubic).value,
                color: AppColors.border,
              ),
              child: const SizedBox(height: 2),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _steps.asMap().entries.map((e) =>
            Expanded(child: _buildStepCard(context, e.key, e.value, false)),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext ctx, int i, dynamic step, bool mobile) {
    final icon   = step.$1 as FidoIcon;
    final color  = step.$2 as Color;
    final title  = step.$3 as String;
    final desc   = step.$4 as String;

    return Padding(
      padding: EdgeInsets.only(
        left:  mobile ? 0 : i == 0 ? 0 : 12,
        right: mobile ? 0 : i == 2 ? 0 : 12,
        bottom: mobile ? 32 : 0,
      ),
      child: Column(
        children: [
          // Pulsing node
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) => Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(.08 + .06 * _pulseCtrl.value),
              ),
              child: child,
            ),
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [color, color.withOpacity(.6)]),
                boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 20, spreadRadius: 2)],
              ),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedSvgIcon(type: icon, color: Colors.white, size: 32,
                    duration: const Duration(milliseconds: 2400)),
                  const SizedBox(height: 2),
                  Text('0${i + 1}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(.7))),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(desc, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.65), textAlign: TextAlign.center),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 300 + i * 200))
        .slideY(begin: .15, end: 0);
  }
}

class _DashedLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  const _DashedLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5;
    const dashW = 8.0;
    const gapW  = 6.0;
    final total = size.width * progress;
    double x = 0;
    while (x < total) {
      final end = min(x + dashW, total);
      canvas.drawLine(Offset(x, 0), Offset(end, 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════
// SECTION 5 — LIVE DEMO (Terminal animation)
// ═══════════════════════════════════════════════════════════
class _DemoSection extends StatefulWidget {
  const _DemoSection();
  @override
  State<_DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<_DemoSection> with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  final _lines = <(bool, String)>[];
  Timer? _timer;
  int _step = 0;
  bool _visible = false;

  static const _seq = <(bool, String)>[
    (true,  '> fido chat "Explain quantum computing"'),
    (false, '  ↳ Connecting to GPT-4o (128K context)...'),
    (false, '  ↳ Streaming response...'),
    (false, ''),
    (false, '  Quantum computing uses qubits that can'),
    (false, '  exist in superposition — unlike classical'),
    (false, '  bits, they solve problems exponentially'),
    (false, '  faster through entanglement & interference.'),
    (false, ''),
    (true,  '> fido generate --prompt "neon cityscape, 4K"'),
    (false, '  ↳ Loading DALL·E 3 model...'),
    (false, '  ↳ Generating 1024×1024 HD image...'),
    (false, '  ✓ Ready in 2.3s  →  [View Output]'),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  void _startTyping() {
    _timer = Timer.periodic(185.ms, (_) {
      if (!mounted) return;
      if (_step < _seq.length) {
        setState(() => _lines.add(_seq[_step++]));
      } else {
        _timer?.cancel();
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() { _lines.clear(); _step = 0; });
          _startTyping();
        });
      }
    });
  }

  @override
  void dispose() { _glowCtrl.dispose(); _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hPad    = R.hp(context);
    final isMobile = R.mobile(context);

    return VisibilityDetector(
      key: const Key('demo-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > .2 && !_visible) {
          setState(() => _visible = true);
          _startTyping();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 100, horizontal: hPad),
        child: Column(children: [
          Column(children: [
            const SectionBadge(label: 'LIVE DEMO', color: AppColors.cyan),
            const SizedBox(height: 16),
            GradientText(text: 'See AI in Action', gradient: AppColors.cyanGrad, style: AppTextStyles.h1(context)),
            const SizedBox(height: 12),
            Text('Watch Fido AI respond to any request in real-time.', style: AppTextStyles.body(context), textAlign: TextAlign.center),
          ]).animate().fadeIn(duration: 700.ms).slideY(begin: .2, end: 0),
          const SizedBox(height: 60),
          isMobile
              ? Column(children: [_buildTerminal(), const SizedBox(height: 40), _buildHighlights(context)])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 55, child: _buildTerminal()),
                  const SizedBox(width: 48),
                  Expanded(flex: 45, child: _buildHighlights(context)),
                ]),
        ]),
      ),
    );
  }

  Widget _buildTerminal() {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cyan.withOpacity(.18 + .12 * _glowCtrl.value)),
          boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(.07 + .05 * _glowCtrl.value), blurRadius: 40)],
        ),
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: [
          // TitleBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF12122A),
            child: Row(children: [
              _dot(const Color(0xFFFF5F57)),
              _dot(const Color(0xFFFFBD2E)),
              _dot(const Color(0xFF28CA41)),
              const SizedBox(width: 12),
              Text('fido_ai — terminal', style: GoogleFonts.firaCode(fontSize: 12, color: AppColors.textMuted)),
            ]),
          ),
          // Body
          Container(
            height: 320, width: double.infinity,
            color: const Color(0xFF0D0D1E),
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Fido AI v2.0  •  GPT-4o  •  DALL·E 3',
                  style: GoogleFonts.firaCode(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    ..._lines.map((line) {
                      if (line.$2.isEmpty) return const SizedBox(height: 6);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          line.$2,
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            color: line.$1 ? AppColors.cyan
                                : line.$2.contains('✓') ? const Color(0xFF28CA41)
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }),
                    _BlinkingCursor(),
                  ],
                ),
              ),
            ]),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideX(begin: -.1, end: 0);
  }

  Widget _dot(Color c) => Container(
    width: 11, height: 11,
    margin: const EdgeInsets.only(right: 7),
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );

  Widget _buildHighlights(BuildContext context) {
    const hl = [
      (FidoIcon.flash,    AppColors.cyan,   'Ultra-Fast Streaming', 'Sub-100ms first token, real-time output'),
      (FidoIcon.brain,    AppColors.purple, 'Smart Context',        '128K token memory for long sessions'),
      (FidoIcon.image,    AppColors.blue,   'HD Image Generation',  'DALL·E 3 at 1024×1024 resolution'),
      (FidoIcon.lock,     AppColors.pink,   'Zero Data Retention',  'Your conversations stay private'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: hl.asMap().entries.map((e) {
        final h = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Row(children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(shape: BoxShape.circle, color: h.$2.withOpacity(.1),
                  border: Border.all(color: h.$2.withOpacity(.3))),
              child: Center(child: AnimatedSvgIcon(type: h.$1, color: h.$2, size: 28,
                  duration: const Duration(milliseconds: 2600))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.$3, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(h.$4, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            ])),
          ]),
        ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: 200 + e.key * 100)).slideX(begin: .1, end: 0);
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION 6 — STATS (Circular progress rings)
// ═══════════════════════════════════════════════════════════
class _StatsSection extends StatefulWidget {
  const _StatsSection();
  @override
  State<_StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<_StatsSection> with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  bool _visible = false;

  static const _stats = [
    ('500K+', 'Active Users',     AppColors.purple, 0.92),
    ('10M+',  'AI Requests/Day',  AppColors.blue,   0.87),
    ('4.9/5', 'User Rating',      AppColors.cyan,   0.98),
    ('99.9%', 'Platform Uptime',  AppColors.pink,   0.999),
  ];

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() { _progressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hPad    = R.hp(context);

    return VisibilityDetector(
      key: const Key('stats-rings'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > .3 && !_visible) {
          setState(() => _visible = true);
          _progressCtrl.forward();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 100, horizontal: hPad),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [const Color(0xFF0A0A1A), const Color(0xFF0F0820), const Color(0xFF0A0A1A)],
          ),
        ),
        child: Column(children: [
          Column(children: [
            const SectionBadge(label: 'BY THE NUMBERS', color: AppColors.purple),
            const SizedBox(height: 16),
            GradientText(text: 'Scale That Speaks', gradient: AppColors.primaryGrad, style: AppTextStyles.h1(context)),
            const SizedBox(height: 12),
            Text("Numbers that prove Fido AI's impact worldwide.", style: AppTextStyles.body(context), textAlign: TextAlign.center),
          ]).animate().fadeIn(duration: 700.ms).slideY(begin: .2, end: 0),
          const SizedBox(height: 70),
          Wrap(
            spacing: 24, runSpacing: 24,
            alignment: WrapAlignment.center,
            children: _stats.asMap().entries.map((e) {
              final s = e.value;
              return AnimatedBuilder(
                animation: _progressCtrl,
                builder: (_, __) {
                  final val = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic).value;
                  return _buildRing(s.$1, s.$2, s.$3, s.$4 * val, 155);
                },
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 200 + e.key * 100))
                  .scale(begin: const Offset(.75, .75), end: const Offset(1, 1), duration: 600.ms);
            }).toList(),
          ),
        ]),
      ),
    );
  }

  Widget _buildRing(String val, String label, Color color, double frac, double sz) {
    return SizedBox(
      width: sz, height: sz,
      child: Stack(alignment: Alignment.center, children: [
        RepaintBoundary(
          child: CustomPaint(
            size: Size(sz, sz),
            painter: _RingPainter(fraction: frac, color: color),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          ShaderMask(
            shaderCallback: (b) => LinearGradient(colors: [color, color.withOpacity(.6)]).createShader(b),
            child: Text(val, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ]),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color color;
  const _RingPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;

    canvas.drawCircle(c, r, Paint()
      ..color = color.withOpacity(.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2, 2 * pi * fraction, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2, 2 * pi * fraction, false,
      Paint()
        ..color = color.withOpacity(.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.fraction != fraction;
}

// ═══════════════════════════════════════════════════════════
// SECTION 7 — PRICING PREVIEW (3D mouse tilt cards)
// ═══════════════════════════════════════════════════════════
class _PricingPreviewSection extends StatelessWidget {
  const _PricingPreviewSection();
  @override
  Widget build(BuildContext context) {
    final hPad    = R.hp(context);
    final isMobile = R.mobile(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: hPad),
      child: Column(children: [
        Column(children: [
          const SectionBadge(label: 'PRICING', color: AppColors.pink),
          const SizedBox(height: 16),
          GradientText(text: 'Plans for Everyone', gradient: AppColors.pinkGrad, style: AppTextStyles.h1(context)),
          const SizedBox(height: 12),
          Text('Start free. Scale when you are ready.', style: AppTextStyles.body(context), textAlign: TextAlign.center),
        ]).animate().fadeIn(duration: 700.ms).slideY(begin: .2, end: 0),
        const SizedBox(height: 60),
        isMobile
            ? Column(children: pricingPlans.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _PricingCard3D(plan: e.value, index: e.key),
              )).toList())
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: pricingPlans.asMap().entries.map((e) =>
                  Expanded(child: Padding(
                    padding: EdgeInsets.only(left: e.key == 0 ? 0 : 12, right: e.key == 2 ? 0 : 12),
                    child: _PricingCard3D(plan: e.value, index: e.key),
                  )),
                ).toList(),
              ),
        const SizedBox(height: 40),
        GradientButton(
          label: 'Compare All Plans',
          outlined: true,
          icon: Icons.compare_arrows_rounded,
          onTap: () => context.go('/pricing'),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
      ]),
    );
  }
}

class _PricingCard3D extends StatefulWidget {
  final PricingModel plan;
  final int index;
  const _PricingCard3D({required this.plan, required this.index});
  @override
  State<_PricingCard3D> createState() => _PricingCard3DState();
}

class _PricingCard3DState extends State<_PricingCard3D> with SingleTickerProviderStateMixin {
  double _tiltX = 0, _tiltY = 0;
  bool _hovered = false;
  late AnimationController _badgeCtrl;

  @override
  void initState() {
    super.initState();
    _badgeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _badgeCtrl.dispose(); super.dispose(); }

  void _onHover(PointerEvent e) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(e.position);
    setState(() {
      _tiltX = (local.dy / box.size.height - .5) * 18;
      _tiltY = (local.dx / box.size.width  - .5) * -18;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plan;
    return Listener(
      onPointerHover: _hovered ? _onHover : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() { _hovered = false; _tiltX = 0; _tiltY = 0; }),
        child: AnimatedContainer(
          duration: 300.ms,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .001)
            ..rotateX(_tiltX * pi / 180)
            ..rotateY(_tiltY * pi / 180),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(colors: [
              p.isPopular ? p.color.withOpacity(.2) : Colors.white.withOpacity(.06),
              Colors.white.withOpacity(.02),
            ]),
            border: Border.all(
              color: p.isPopular ? p.color.withOpacity(.65) : (_hovered ? p.color.withOpacity(.3) : AppColors.border),
            ),
            boxShadow: [BoxShadow(
              color: p.color.withOpacity(p.isPopular ? .25 : _hovered ? .12 : 0),
              blurRadius: 40,
            )],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (p.isPopular)
              AnimatedBuilder(
                animation: _badgeCtrl,
                builder: (_, __) => Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: AppColors.primaryGrad,
                    boxShadow: [BoxShadow(
                      color: AppColors.purple.withOpacity(.4 + .2 * _badgeCtrl.value),
                      blurRadius: 12,
                    )],
                  ),
                  child: Text('⭐  MOST POPULAR',
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                ),
              ),
            Text(p.name, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: p.color, letterSpacing: 2)),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (p.monthlyPrice != 'FREE')
                Padding(padding: const EdgeInsets.only(top: 8),
                    child: Text('\$', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
              Text(
                p.monthlyPrice == 'FREE' ? 'FREE' : p.monthlyPrice.replaceAll('\$', ''),
                style: GoogleFonts.inter(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
              ),
              if (p.monthlyPrice != 'FREE')
                Padding(padding: const EdgeInsets.only(top: 22),
                    child: Text('/mo', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary))),
            ]),
            const SizedBox(height: 18),
            ...p.features.take(5).map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(children: [
                Icon(f.$1 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: f.$1 ? p.color : AppColors.textMuted.withOpacity(.4), size: 15),
                const SizedBox(width: 7),
                Expanded(child: Text(f.$2,
                    style: GoogleFonts.inter(fontSize: 12, color: f.$1 ? Colors.white.withOpacity(.85) : AppColors.textMuted))),
              ]),
            )),
            const SizedBox(height: 18),
            GradientButton(
              label: p.cta,
              outlined: !p.isPopular,
              onTap: () => context.go('/pricing'),
              width: double.infinity,
            ),
          ]),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 200 + widget.index * 120))
        .slideY(begin: .1, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION 8 — CTA (Rocket + star particles)
// ═══════════════════════════════════════════════════════════
class _CTASection extends StatefulWidget {
  const _CTASection();
  @override
  State<_CTASection> createState() => _CTASectionState();
}

class _CTASectionState extends State<_CTASection> with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _rocketCtrl;

  @override
  void initState() {
    super.initState();
    _starCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _waveCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _rocketCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  }

  @override
  void dispose() { _starCtrl.dispose(); _waveCtrl.dispose(); _rocketCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hPad = R.hp(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: hPad),
      child: Stack(alignment: Alignment.center, children: [
        // Stars background
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              painter: _StarFieldPainter(t: _starCtrl.value),
              child: const SizedBox(height: 400, width: double.infinity),
            ),
          ),
        ),
        // Glowing orbs
        Positioned(top: 0, left: 0, child: AnimatedBuilder(
          animation: _waveCtrl,
          builder: (_, __) => Container(
            width: 400, height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.purple.withOpacity(.12 + .06 * _waveCtrl.value),
                Colors.transparent,
              ]),
            ),
          ),
        )),
        Positioned(bottom: 0, right: 0, child: AnimatedBuilder(
          animation: _waveCtrl,
          builder: (_, __) => Container(
            width: 350, height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.blue.withOpacity(.1 + .06 * _waveCtrl.value),
                Colors.transparent,
              ]),
            ),
          ),
        )),
        // Content
        Column(children: [
          // 3D Rocket
          AnimatedBuilder(
            animation: _rocketCtrl,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, -200 * _rocketCtrl.value),
              child: Opacity(
                opacity: (1 - _rocketCtrl.value * 1.4).clamp(0.0, 1.0),
                child: _Rocket3DWidget(launchProgress: _rocketCtrl.value),
              ),
            ),
          ).animate().fadeIn(duration: 900.ms).slideY(begin: .4, end: 0),
          const SizedBox(height: 24),
          // Shimmer headline
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, __) => ShaderMask(
              shaderCallback: (b) {
                final o = _waveCtrl.value;
                return LinearGradient(
                  colors: const [AppColors.purple, AppColors.blue, AppColors.cyan, AppColors.purple],
                  stops: [0, o * .8, min(o * .8 + .3, 1), 1],
                  tileMode: TileMode.mirror,
                ).createShader(b);
              },
              child: Text(
                'Ready to Transform\nYour Workflow?',
                style: GoogleFonts.inter(
                  fontSize: R.fs(context, 28, 50),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
          const SizedBox(height: 20),
          Text(
            'Join 500,000+ creators already using Fido AI.',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          const SizedBox(height: 44),
          Wrap(
            spacing: 16, runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              GradientButton(
                label: 'Start Free — No Credit Card',
                icon: Icons.rocket_launch_rounded,
                onTap: () {
                  _rocketCtrl.forward().then((_) {
                    if (mounted) { _rocketCtrl.reset(); context.go('/contact'); }
                  });
                },
              ),
              GradientButton(
                label: 'View Pricing',
                outlined: true,
                onTap: () => context.go('/pricing'),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: .15, end: 0),
          const SizedBox(height: 60),
          // Footer
          _buildFooter(context),
        ]),
      ]),
    );
  }

  Widget _buildFooter(BuildContext ctx) {
    return Column(children: [
      Container(height: 1, decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent, AppColors.border, Colors.transparent]),
      )),
      const SizedBox(height: 32),
      GradientText(
        text: '© 2025 Fido AI — All Rights Reserved',
        gradient: AppColors.primaryGrad,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Text('Built with Flutter Web • Powered by GPT-4o & DALL·E 3',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
      const SizedBox(height: 20),
      Wrap(spacing: 24, runSpacing: 8, alignment: WrapAlignment.center,
          children: ['Privacy Policy', 'Terms of Service', 'API Docs', 'Status', 'Contact'].map((t) =>
            Text(t, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted.withOpacity(.6)))).toList()),
    ]);
  }
}

class _StarFieldPainter extends CustomPainter {
  final double t;
  const _StarFieldPainter({required this.t});

  static const _pts = [
    (.10, .20), (.30, .55), (.70, .30), (.90, .75), (.50, .12),
    (.20, .82), (.80, .42), (.42, .62), (.62, .90), (.15, .45),
    (.85, .18), (.35, .78), (.78, .55), (.55, .28), (.25, .65),
    (.60, .38), (.95, .50), (.05, .70), (.45, .05), (.70, .95),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _pts.length; i++) {
      final phase   = (t + i / _pts.length) % 1;
      final opacity = (sin(phase * 2 * pi) * .5 + .5) * .5;
      final radius  = 1.0 + sin(phase * 2 * pi) * .7;
      canvas.drawCircle(
        Offset(size.width * _pts[i].$1, size.height * _pts[i].$2),
        radius,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter o) => o.t != t;
}

// ═══════════════════════════════════════════════════════════
// SHARED HELPERS
// ═══════════════════════════════════════════════════════════
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: 600.ms)..repeat(reverse: true); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Opacity(
      opacity: _ctrl.value,
      child: Text('█', style: GoogleFonts.firaCode(fontSize: 12, color: AppColors.cyan)),
    ),
  );
}

class _StatItem extends StatefulWidget {
  final String value, label;
  final bool doAnimate;
  const _StatItem({required this.value, required this.label, required this.doAnimate});
  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  String get _num    => RegExp(r'[\d.]+').firstMatch(widget.value)?.group(0) ?? '0';
  String get _suffix => widget.value.replaceAll(RegExp(r'[\d.]+'), '');

  @override
  void initState() {
    super.initState();
    final end = double.tryParse(_num) ?? 0;
    _ctrl = AnimationController(vsync: this, duration: 2000.ms);
    _anim = Tween(begin: 0.0, end: end).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    if (widget.doAnimate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_StatItem old) {
    super.didUpdateWidget(old);
    if (widget.doAnimate && !old.doAnimate) _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) {
      final v = _num.contains('.') ? _anim.value.toStringAsFixed(1) : _anim.value.toInt().toString();
      return Column(mainAxisSize: MainAxisSize.min, children: [
        GradientText(
          text: '$v$_suffix',
          gradient: AppColors.primaryGrad,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(widget.label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
      ]);
    },
  );
}

class _Tag extends StatefulWidget {
  final String label;
  const _Tag({required this.label});
  @override
  State<_Tag> createState() => _TagState();
}

class _TagState extends State<_Tag> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: 200.ms,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _h ? AppColors.purple.withOpacity(.7) : AppColors.border),
        color: _h ? AppColors.purple.withOpacity(.1) : Colors.white.withOpacity(.03),
      ),
      child: Text(widget.label,
          style: GoogleFonts.inter(fontSize: 12, color: _h ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w500)),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// 3D ANIMATED ROCKET
// ═══════════════════════════════════════════════════════════
class _Rocket3DWidget extends StatefulWidget {
  final double launchProgress;
  const _Rocket3DWidget({required this.launchProgress});

  @override
  State<_Rocket3DWidget> createState() => _Rocket3DWidgetState();
}

class _Rocket3DWidgetState extends State<_Rocket3DWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _flameCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _trailCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _flameCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120))
      ..repeat(reverse: true);
    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _trailCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _floatCtrl.dispose(); _flameCtrl.dispose();
    _orbitCtrl.dispose(); _glowCtrl.dispose(); _trailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_floatCtrl, _flameCtrl, _orbitCtrl, _glowCtrl, _trailCtrl]),
      builder: (_, __) => RepaintBoundary(
        child: CustomPaint(
          size: const Size(200, 280),
          painter: _Rocket3DPainter(
            float:   _floatCtrl.value,
            flame:   _flameCtrl.value,
            orbit:   _orbitCtrl.value,
            glow:    _glowCtrl.value,
            trail:   _trailCtrl.value,
            launch:  widget.launchProgress,
          ),
        ),
      ),
    );
  }
}

class _Rocket3DPainter extends CustomPainter {
  final double float, flame, orbit, glow, trail, launch;
  const _Rocket3DPainter({
    required this.float, required this.flame, required this.orbit,
    required this.glow,  required this.trail,  required this.launch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx   = size.width  / 2;        // 100
    final cy   = size.height / 2;        // 140
    final floatY = -12 * sin(float * pi); // ±12px bob

    // ── 1. Background glow ──────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy + floatY + 20),
      85 + 10 * glow,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF2F8FFF).withOpacity(0.18 + 0.08 * glow),
          const Color(0xFF7B2FFF).withOpacity(0.10 + 0.05 * glow),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
            center: Offset(cx, cy + floatY + 20), radius: 85 + 10 * glow)),
    );

    // ── 2. Motion trails (scroll upward as trail advances) ──────────
    _drawTrails(canvas, cx, floatY, trail);

    // ── 3. Back orbit ring arc ──────────────────────────────────────
    _drawOrbitBack(canvas, cx, cy + floatY, orbit);

    // ── 4. Exhaust flame + particles ────────────────────────────────
    _drawFlame(canvas, cx, floatY, flame, trail);

    // ── 5. Rocket fins (drawn before body so body overlaps) ─────────
    _drawFins(canvas, cx, floatY);

    // ── 6. Rocket body ──────────────────────────────────────────────
    _drawBody(canvas, cx, floatY);

    // ── 7. Nose cone ────────────────────────────────────────────────
    _drawNose(canvas, cx, floatY);

    // ── 8. Porthole window ──────────────────────────────────────────
    _drawWindow(canvas, cx, floatY, orbit);

    // ── 9. Front orbit ring arc + particle ─────────────────────────
    _drawOrbitFront(canvas, cx, cy + floatY, orbit);

    // ── 10. Specular body shine ─────────────────────────────────────
    _drawSpecular(canvas, cx, floatY);
  }

  // ── TRAILS ────────────────────────────────────────────────────────
  void _drawTrails(Canvas canvas, double cx, double floatY, double t) {
    const trailOffs = [-18.0, -8.0, 8.0, 18.0];
    for (int i = 0; i < trailOffs.length; i++) {
      final phase  = (t + i * 0.22) % 1.0;
      final opacity = sin(phase * pi) * 0.5;
      final topY   = 30 + floatY - phase * 40;
      final botY   = 55 + floatY - phase * 30;
      canvas.drawLine(
        Offset(cx + trailOffs[i], topY),
        Offset(cx + trailOffs[i], botY),
        Paint()
          ..color = const Color(0xFF7B2FFF).withOpacity(opacity)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // ── ORBIT BACK (behind rocket) ────────────────────────────────────
  void _drawOrbitBack(Canvas canvas, double cx, double cy, double t) {
    final oy = cy + 15;
    final rect = Rect.fromCenter(center: Offset(cx, oy), width: 130, height: 36);
    final startAngle = t * 2 * pi;
    canvas.drawArc(
      rect, startAngle + pi * 0.08, pi - 0.16, false,
      Paint()
        ..color = const Color(0xFF7B2FFF).withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  // ── FLAME ─────────────────────────────────────────────────────────
  void _drawFlame(Canvas canvas, double cx, double floatY, double f, double t) {
    final baseY = 200 + floatY;

    // Particle trail (sparks falling down)
    for (int i = 0; i < 12; i++) {
      final phase  = (t * 1.8 + i * 0.14) % 1.0;
      final px     = cx + (i % 3 - 1) * 10.0 + sin(phase * pi * 3) * 6;
      final py     = baseY + 10 + phase * 55;
      final pOpacity = (1 - phase) * 0.7;
      final pSize  = (1 - phase) * 3.5 + 1;
      canvas.drawCircle(
        Offset(px, py),
        pSize,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFFF8C00),
            const Color(0xFFFF4500),
            phase,
          )!.withOpacity(pOpacity),
      );
    }

    // Flame layer 1 — wide orange base
    final fl1 = 18 + f * 12;
    final path1 = Path()
      ..moveTo(cx - 22, baseY)
      ..quadraticBezierTo(cx - 28, baseY + fl1 * .6, cx, baseY + fl1)
      ..quadraticBezierTo(cx + 28, baseY + fl1 * .6, cx + 22, baseY)
      ..close();
    canvas.drawPath(path1, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF6000).withOpacity(0.95),
          const Color(0xFFFF8C00).withOpacity(0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(cx - 28, baseY, 56, fl1))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Flame layer 2 — yellow core
    final fl2 = 14 + f * 9;
    final path2 = Path()
      ..moveTo(cx - 14, baseY)
      ..quadraticBezierTo(cx - 18, baseY + fl2 * .55, cx, baseY + fl2)
      ..quadraticBezierTo(cx + 18, baseY + fl2 * .55, cx + 14, baseY)
      ..close();
    canvas.drawPath(path2, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFE500).withOpacity(0.95),
          const Color(0xFFFFAA00).withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(cx - 18, baseY, 36, fl2)));

    // Flame layer 3 — white hot inner core
    final fl3 = 8 + f * 5;
    final path3 = Path()
      ..moveTo(cx - 7, baseY)
      ..quadraticBezierTo(cx - 8, baseY + fl3 * .5, cx, baseY + fl3)
      ..quadraticBezierTo(cx + 8, baseY + fl3 * .5, cx + 7, baseY)
      ..close();
    canvas.drawPath(path3, Paint()
      ..color = Colors.white.withOpacity(0.9));
  }

  // ── FINS ──────────────────────────────────────────────────────────
  void _drawFins(Canvas canvas, double cx, double floatY) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [const Color(0xFFE63946), const Color(0xFF9B2335)],
      ).createShader(Rect.fromLTWH(cx - 60, 140 + floatY, 120, 65));

    // Left fin
    final leftFin = Path()
      ..moveTo(cx - 30, 150 + floatY)
      ..lineTo(cx - 48, 155 + floatY)
      ..lineTo(cx - 42, 200 + floatY)
      ..lineTo(cx - 28, 200 + floatY)
      ..close();
    canvas.drawPath(leftFin, paint);

    // Right fin
    final rightFin = Path()
      ..moveTo(cx + 30, 150 + floatY)
      ..lineTo(cx + 48, 155 + floatY)
      ..lineTo(cx + 42, 200 + floatY)
      ..lineTo(cx + 28, 200 + floatY)
      ..close();
    canvas.drawPath(rightFin, paint);

    // Bottom exhaust nozzle
    final nozzle = Path()
      ..moveTo(cx - 20, 193 + floatY)
      ..lineTo(cx + 20, 193 + floatY)
      ..lineTo(cx + 14, 205 + floatY)
      ..lineTo(cx - 14, 205 + floatY)
      ..close();
    canvas.drawPath(nozzle, Paint()
      ..color = const Color(0xFF2C2C54));
  }

  // ── BODY ──────────────────────────────────────────────────────────
  void _drawBody(Canvas canvas, double cx, double floatY) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, 130 + floatY), width: 64, height: 150),
      const Radius.circular(32),
    );

    // Main body gradient (3D cylinder shading)
    canvas.drawRRect(bodyRect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end:   Alignment.centerRight,
        colors: [
          const Color(0xFFDDE4F0),
          const Color(0xFFBBC5D8),
          const Color(0xFF8A95B0),
          const Color(0xFF6B7799),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCenter(
          center: Offset(cx, 130 + floatY), width: 64, height: 150)));

    // Red accent stripe
    final stripeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 32, 150 + floatY, 64, 16),
      const Radius.circular(2),
    );
    canvas.drawRRect(stripeRect, Paint()
      ..color = const Color(0xFFE63946).withOpacity(0.85));

    // Body border/outline
    canvas.drawRRect(bodyRect, Paint()
      ..color = const Color(0xFF4A5580).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0);
  }

  // ── NOSE CONE ─────────────────────────────────────────────────────
  void _drawNose(Canvas canvas, double cx, double floatY) {
    final nosePath = Path()
      ..moveTo(cx, 42 + floatY)
      ..cubicTo(cx - 4, 52 + floatY, cx - 18, 62 + floatY, cx - 32, 70 + floatY)
      ..lineTo(cx + 32, 70 + floatY)
      ..cubicTo(cx + 18, 62 + floatY, cx + 4, 52 + floatY, cx, 42 + floatY)
      ..close();
    canvas.drawPath(nosePath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFFE63946), const Color(0xFF9B2335)],
      ).createShader(Rect.fromLTWH(cx - 32, 42 + floatY, 64, 28)));

    // Nose tip glow
    canvas.drawCircle(
      Offset(cx, 48 + floatY),
      6,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // ── WINDOW ────────────────────────────────────────────────────────
  void _drawWindow(Canvas canvas, double cx, double floatY, double orbit) {
    final winCenter = Offset(cx, 108 + floatY);

    // Outer ring
    canvas.drawCircle(winCenter, 18, Paint()
      ..color = const Color(0xFF2C2C54));

    // Glass fill
    canvas.drawCircle(winCenter, 15, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.35, -.35),
        colors: [
          const Color(0xFF2E86C1),
          const Color(0xFF1A3A6B),
          const Color(0xFF0D1B3E),
        ],
      ).createShader(Rect.fromCircle(center: winCenter, radius: 15)));

    // Earth/planet inside window
    canvas.drawCircle(winCenter, 10, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.2, -.2),
        colors: [
          const Color(0xFF48CAE4),
          const Color(0xFF2196F3),
          const Color(0xFF0D47A1),
        ],
      ).createShader(Rect.fromCircle(center: winCenter, radius: 10)));

    // Cloud streaks on planet (orbit-animated)
    final cloudPath = Path()
      ..moveTo(cx - 8, 105 + floatY + sin(orbit * 2 * pi) * 2)
      ..lineTo(cx + 6, 105 + floatY + sin(orbit * 2 * pi) * 2);
    canvas.drawPath(cloudPath, Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);

    // Specular highlight on window glass
    canvas.drawCircle(
      Offset(cx - 6, 100 + floatY),
      5,
      Paint()
        ..color = Colors.white.withOpacity(0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Inner ring glow (orbit-animated color)
    canvas.drawCircle(winCenter, 17, Paint()
      ..color = const Color(0xFF2F8FFF)
          .withOpacity(0.15 + 0.12 * sin(orbit * 2 * pi).abs())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);
  }

  // ── ORBIT FRONT (in front of rocket) ─────────────────────────────
  void _drawOrbitFront(Canvas canvas, double cx, double cy, double t) {
    final oy = cy + 15;
    final rect = Rect.fromCenter(center: Offset(cx, oy), width: 130, height: 36);
    final startAngle = t * 2 * pi;

    // Front arc (solid)
    canvas.drawArc(
      rect, startAngle + pi * 0.08 + pi, pi - 0.16, false,
      Paint()
        ..color = const Color(0xFF7B2FFF).withOpacity(0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Orbiting particle
    final particleAngle = startAngle + pi;
    final px = cx + 65 * cos(particleAngle);
    final py = oy + 18 * sin(particleAngle);
    // Only draw particle on front half
    if (sin(particleAngle) > 0) {
      canvas.drawCircle(Offset(px, py), 5, Paint()
        ..color = const Color(0xFF7B2FFF).withOpacity(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(Offset(px, py), 2.5, Paint()
        ..color = Colors.white.withOpacity(0.85));
    }
  }

  // ── SPECULAR BODY HIGHLIGHT ────────────────────────────────────────
  void _drawSpecular(Canvas canvas, double cx, double floatY) {
    // Left edge highlight (simulates 3D cylinder light from left)
    final specPath = Path()
      ..moveTo(cx - 27, 80 + floatY)
      ..cubicTo(cx - 31, 100 + floatY, cx - 31, 140 + floatY, cx - 26, 175 + floatY);
    canvas.drawPath(specPath, Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Top nose shine
    canvas.drawCircle(
      Offset(cx - 10, 52 + floatY),
      4.5,
      Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_Rocket3DPainter o) =>
      o.float != float || o.flame != flame || o.orbit != orbit ||
      o.glow != glow || o.trail != trail;
}

// ═══════════════════════════════════════════════════════════
// HERO BACKGROUND — Animated Circuit Board
// ═══════════════════════════════════════════════════════════
class _CircuitBgPainter extends CustomPainter {
  final double t;
  const _CircuitBgPainter({required this.t});

  static const _nodes = [
    (0.10, 0.20), (0.30, 0.15), (0.55, 0.25), (0.80, 0.18),
    (0.15, 0.50), (0.40, 0.45), (0.65, 0.40), (0.88, 0.55),
    (0.22, 0.75), (0.50, 0.70), (0.75, 0.80), (0.92, 0.30),
  ];
  static const _edges = [
    (0, 1), (1, 2), (2, 3), (0, 4), (1, 5), (2, 6), (3, 7),
    (4, 5), (5, 6), (6, 7), (4, 8), (5, 9), (6, 10), (7, 11),
    (8, 9), (9, 10),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF7B2FFF).withOpacity(0.06)
      ..strokeWidth = 1.0;
    final nodePaint = Paint();
    final packetPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Draw edges (circuit lines)
    for (final edge in _edges) {
      final a = _nodes[edge.$1];
      final b = _nodes[edge.$2];
      final p1 = Offset(a.$1 * size.width, a.$2 * size.height);
      final p2 = Offset(b.$1 * size.width, b.$2 * size.height);

      // Draw L-shaped circuit line (horizontal then vertical)
      canvas.drawLine(p1, Offset(p2.dx, p1.dy), linePaint);
      canvas.drawLine(Offset(p2.dx, p1.dy), p2, linePaint);

      // Animated data packet along this edge
      final phase = ((t * 2 + edge.$1 * 0.15 + edge.$2 * 0.07) % 1.0);
      if (phase < 0.6) {
        final frac = phase / 0.6;
        final mid = Offset(p2.dx, p1.dy);
        final Offset packetPos;
        if (frac < 0.5) {
          packetPos = Offset.lerp(p1, mid, frac * 2)!;
        } else {
          packetPos = Offset.lerp(mid, p2, (frac - 0.5) * 2)!;
        }
        final pOpacity = sin(phase * pi / 0.6) * 0.6;
        packetPaint.color = const Color(0xFF2F8FFF).withOpacity(pOpacity);
        canvas.drawCircle(packetPos, 2.0, packetPaint);
      }
    }

    // Draw nodes (intersection points)
    for (int i = 0; i < _nodes.length; i++) {
      final n = _nodes[i];
      final pos = Offset(n.$1 * size.width, n.$2 * size.height);
      final pulse = (sin(t * 2 * pi * 1.5 + i * 0.8) + 1) / 2;

      // Glow ring
      nodePaint.color = const Color(0xFF7B2FFF).withOpacity(0.04 + 0.06 * pulse);
      canvas.drawCircle(pos, 7 + 3 * pulse, nodePaint);

      // Core dot
      nodePaint.color = const Color(0xFF7B2FFF).withOpacity(0.15 + 0.15 * pulse);
      canvas.drawCircle(pos, 2.5, nodePaint);

      // Inner bright dot
      nodePaint.color = Colors.white.withOpacity(0.08 + 0.10 * pulse);
      canvas.drawCircle(pos, 1.2, nodePaint);
    }
  }

  @override
  bool shouldRepaint(_CircuitBgPainter o) => o.t != t;
}
