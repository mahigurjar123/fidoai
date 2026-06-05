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
import 'bloc/features_cubit.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          _HeroSection(),
          _TabSection(),
          _CardsSection(),
          _CapabilitiesSection(),
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
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 100),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: Geo3DBg(color: AppColors.purple)),
          Column(
            children: [
              SectionBadge(label: "CORE FEATURES", color: AppColors.purple),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (b) => AppColors.primaryGrad.createShader(b),
                child: Text(
                  "4 Powerful AI Tools",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1(context)
                      .copyWith(color: Colors.white),
                ),
              ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              Text(
                "Everything you need, built into one premium platform.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context)
                    .copyWith(fontSize: R.fs(context, 15, 19)),
              ).animate().fadeIn(duration: 700.ms, delay: 150.ms),
              const SizedBox(height: 48),
              // 3D floating feature icons
              Wrap(
                spacing: isMobile ? 24 : 48,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: features.map((f) {
                  return Float3D(
                    amplitude: 10 + features.indexOf(f) * 2.0,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: f.gradient,
                        boxShadow: [
                          BoxShadow(
                              color: f.color.withOpacity(0.4),
                              blurRadius: 20)
                        ],
                      ),
                      child: Icon(f.icon, color: Colors.white, size: 36),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              GradientButton(label: "Explore Features", onTap: () {})
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 2. Tab Section ───────────────────────────────────────────────────────────
class _TabSection extends StatefulWidget {
  const _TabSection();
  @override
  State<_TabSection> createState() => _TabSectionState();
}

class _TabSectionState extends State<_TabSection>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _slideCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _selectTab(int i) {
    if (i == _selectedTab) return;
    _slideCtrl.reset();
    setState(() => _selectedTab = i);
    _slideCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);
    final f = features[_selectedTab];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 80),
      color: const Color(0xFF080820),
      child: Column(
        children: [
          SectionBadge(label: "DEEP DIVE", color: AppColors.cyan),
          const SizedBox(height: 32),
          // Tab buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(features.length, (i) {
                final isSelected = i == _selectedTab;
                final feat = features[i];
                return GestureDetector(
                  onTap: () => _selectTab(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: isSelected ? feat.gradient : null,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.border,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: feat.color.withOpacity(0.35),
                                  blurRadius: 16)
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(feat.icon,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: 16),
                        const SizedBox(width: 8),
                        Text(feat.title,
                            style: GoogleFonts.inter(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 40),
          // Tab content with 3D slide-in
          AnimatedBuilder(
            animation: _slideCtrl,
            builder: (_, __) => Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..translate(
                    0.0, 30.0 * (1 - _slideCtrl.value))
                ..rotateX(
                    0.08 * (1 - _slideCtrl.value)),
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: _slideCtrl.value.clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C24),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: f.color.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: f.color.withOpacity(0.12),
                          blurRadius: 32)
                    ],
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _tabIcon(f),
                            const SizedBox(height: 20),
                            _tabContent(context, f),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _tabContent(context, f)),
                            const SizedBox(width: 48),
                            Expanded(flex: 3, child: _tabTerminal(context, f)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabIcon(FeatureModel f) => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: f.gradient,
          boxShadow: [
            BoxShadow(color: f.color.withOpacity(0.4), blurRadius: 20)
          ],
        ),
        child: Icon(f.icon, color: Colors.white, size: 32),
      );

  Widget _tabContent(BuildContext context, FeatureModel f) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: f.color.withOpacity(0.15),
              border: Border.all(color: f.color.withOpacity(0.4)),
            ),
            child: Text(f.tag,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: f.color,
                    letterSpacing: 1.5)),
          ),
          const SizedBox(height: 16),
          Text(f.title,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: R.fs(context, 22, 28),
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(f.longDesc,
              style: AppTextStyles.body(context).copyWith(height: 1.7)),
          const SizedBox(height: 20),
          ...f.bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: f.color.withOpacity(0.18)),
                    child: Icon(Icons.check_rounded,
                        color: f.color, size: 13),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(b,
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13)),
                  ),
                ]),
              )),
        ],
      );

  Widget _tabTerminal(BuildContext context, FeatureModel f) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF060614),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: f.color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF5F57))),
              Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFBD2E))),
              Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF28C840))),
              const SizedBox(width: 12),
              Text("fido-ai demo",
                  style: GoogleFonts.firaCode(
                      fontSize: 11, color: AppColors.textMuted)),
            ]),
            const SizedBox(height: 16),
            Text("> ${f.shortDesc}",
                style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: f.color,
                    height: 1.6)),
            const SizedBox(height: 8),
            ...f.bullets.take(3).map((b) => Text(
                  "  ✓ $b",
                  style: GoogleFonts.firaCode(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.8),
                )),
            const SizedBox(height: 8),
            Row(children: [
              Text("> ",
                  style: GoogleFonts.firaCode(
                      fontSize: 12, color: AppColors.cyan)),
              _BlinkingCursor(color: AppColors.cyan),
            ]),
          ],
        ),
      );
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  const _BlinkingCursor({required this.color});
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
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
          child: Container(
              width: 8,
              height: 14,
              color: widget.color),
        ),
      );
}

// ── 3. Cards Section ─────────────────────────────────────────────────────────
class _CardsSection extends StatefulWidget {
  const _CardsSection();
  @override
  State<_CardsSection> createState() => _CardsSectionState();
}

class _CardsSectionState extends State<_CardsSection> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);
    return VisibilityDetector(
      key: const Key('features-cards'),
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
            SectionBadge(label: "FEATURE CARDS", color: AppColors.blue),
            const SizedBox(height: 12),
            Text("What Fido AI Can Do",
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(context)),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (context, constraints) {
              final cols = isMobile ? 1 : 2;
              final spacing = (cols - 1) * 24.0;
              final cardWidth = (constraints.maxWidth - spacing) / cols;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: features.asMap().entries.map((e) {
                  return AnimatedOpacity(
                    opacity: _visible ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500 + e.key * 120),
                    child: AnimatedSlide(
                      offset:
                          _visible ? Offset.zero : const Offset(0, 0.15),
                      duration: Duration(milliseconds: 500 + e.key * 120),
                      curve: Curves.easeOutCubic,
                      child: SizedBox(
                        width: cardWidth,
                        child: Tilt3DCard(
                          child: _FeatureCardInner(
                              feature: e.value),
                        ),
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

class _FeatureCardInner extends StatefulWidget {
  final FeatureModel feature;
  const _FeatureCardInner({required this.feature});
  @override
  State<_FeatureCardInner> createState() => _FeatureCardInnerState();
}

class _FeatureCardInnerState extends State<_FeatureCardInner>
    with TickerProviderStateMixin {
  late AnimationController _rotCtrl;
  late AnimationController _glowCtrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotCtrl, _glowCtrl]),
        builder: (_, __) => Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C24),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? f.color.withOpacity(0.6)
                  : f.color.withOpacity(
                      0.2 + 0.1 * _glowCtrl.value),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: f.color.withOpacity(
                    _hovered ? 0.22 : 0.08 + 0.06 * _glowCtrl.value),
                blurRadius: _hovered ? 32 : 16,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: f.color.withOpacity(0.15),
                    border: Border.all(color: f.color.withOpacity(0.4)),
                  ),
                  child: Text(f.tag,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: f.color,
                          letterSpacing: 1.5)),
                ),
                // 3D rotating icon
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(_rotCtrl.value * 2 * pi),
                  alignment: Alignment.center,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: f.gradient,
                      boxShadow: [
                        BoxShadow(
                            color: f.color.withOpacity(0.4),
                            blurRadius: 12)
                      ],
                    ),
                    child: Icon(f.icon, color: Colors.white, size: 24),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              Text(f.title,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: R.fs(context, 18, 22),
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(f.shortDesc,
                  style: AppTextStyles.body(context)
                      .copyWith(fontSize: 14, height: 1.6)),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _hovered
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                              height: 1,
                              color: f.color.withOpacity(0.2)),
                          const SizedBox(height: 14),
                          ...f.bullets.map((b) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8),
                                child: Row(children: [
                                  Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: f.color)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(b,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.white
                                                .withOpacity(0.7))),
                                  ),
                                ]),
                              )),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 4. Capabilities Section ───────────────────────────────────────────────────
class _CapabilitiesSection extends StatefulWidget {
  const _CapabilitiesSection();
  @override
  State<_CapabilitiesSection> createState() => _CapabilitiesSectionState();
}

class _CapabilitiesSectionState extends State<_CapabilitiesSection> {
  bool _visible = false;

  static const _useCases = [
    _UseCase(
      "Marketing",
      AppColors.purple,
      Icons.campaign_rounded,
      "> Write a product launch email for our new AI app",
      "Subject: Meet Fido AI — Your New AI Superpower\n\nDear [Name],\nWe're thrilled to introduce Fido AI, the all-in-one AI platform that replaces 5 tools...",
    ),
    _UseCase(
      "Development",
      AppColors.blue,
      Icons.code_rounded,
      "> Generate a Flutter widget with 3D tilt effect",
      "class Tilt3DCard extends StatefulWidget {\n  final Widget child;\n  // Full implementation with mouse tracking,\n  // Matrix4 transforms, and perspective...",
    ),
    _UseCase(
      "Design",
      AppColors.pink,
      Icons.palette_rounded,
      "> Generate: futuristic UI dashboard, dark theme, neon",
      "[HD IMAGE GENERATED]\n1024x1024 • DALL-E 3\nStyle: Cyberpunk • Dark UI\nDownload ready in 3s ✓",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);
    return VisibilityDetector(
      key: const Key('capabilities-section'),
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
            SectionBadge(label: "USE CASES", color: AppColors.pink),
            const SizedBox(height: 12),
            Text("What You Can Build",
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(context)),
            const SizedBox(height: 8),
            Text("Real examples from real workflows",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context)),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (context, constraints) {
              final cols = isMobile ? 1 : 3;
              final spacing = (cols - 1) * 20.0;
              final cardWidth = (constraints.maxWidth - spacing) / cols;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: _useCases.asMap().entries.map((e) {
                  final uc = e.value;
                  return AnimatedOpacity(
                    opacity: _visible ? 1.0 : 0.0,
                    duration: Duration(
                        milliseconds: 400 + e.key * 200),
                    child: AnimatedSlide(
                      offset: _visible
                          ? Offset.zero
                          : Offset(0, 0.3 * (e.key + 1)),
                      duration: Duration(
                          milliseconds: 500 + e.key * 200),
                      curve: Curves.easeOutCubic,
                      child: SizedBox(
                        width: cardWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C0C24),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: uc.color.withOpacity(0.3),
                                width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color: uc.color.withOpacity(0.12),
                                  blurRadius: 24)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                  gradient: LinearGradient(colors: [
                                    uc.color.withOpacity(0.2),
                                    uc.color.withOpacity(0.05)
                                  ]),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          uc.color.withOpacity(0.2),
                                    ),
                                    child: Icon(uc.icon,
                                        color: uc.color, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(uc.label,
                                      style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.w700,
                                          fontSize: 14)),
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(
                                          12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                            0xFF060614),
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                        border: Border.all(
                                            color: uc.color
                                                .withOpacity(0.2)),
                                      ),
                                      child: Text(uc.prompt,
                                          style:
                                              GoogleFonts.firaCode(
                                                  fontSize: 11,
                                                  color: uc.color,
                                                  height: 1.5)),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(
                                          12),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(0.03),
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                        border: Border.all(
                                            color: AppColors.border),
                                      ),
                                      child: Text(uc.output,
                                          style: GoogleFonts.firaCode(
                                              fontSize: 11,
                                              color: Colors.white
                                                  .withOpacity(0.7),
                                              height: 1.6)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _UseCase {
  final String label;
  final Color color;
  final IconData icon;
  final String prompt;
  final String output;
  const _UseCase(
      this.label, this.color, this.icon, this.prompt, this.output);
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
          const Positioned.fill(child: Geo3DBg(color: AppColors.cyan)),
          Column(
            children: [
              Float3D(
                amplitude: 12,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppColors.cyanGrad,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.cyan.withOpacity(0.4),
                          blurRadius: 28)
                    ],
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Text("Ready to Explore?",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1(context))
                  .animate()
                  .fadeIn(duration: 600.ms),
              const SizedBox(height: 16),
              Text(
                "Start building with the most powerful AI platform.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context)
                    .copyWith(fontSize: R.fs(context, 15, 18)),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  GradientButton(
                    label: "Get Started Free",
                    onTap: () {},
                    icon: Icons.rocket_launch_rounded,
                  ),
                  GradientButton(
                    label: "View Pricing",
                    onTap: () {},
                    outlined: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
