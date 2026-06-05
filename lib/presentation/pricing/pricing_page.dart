import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../shared/gradient_button.dart';
import '../shared/section_badge.dart';
import '../shared/app_footer.dart';
import 'bloc/pricing_cubit.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = R.mobile(context);
    final isTablet = R.tablet(context);
    final hPad = R.hp(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
        padding: EdgeInsets.only(
          top: 100,
          left: hPad,
          right: hPad,
          bottom: 80,
        ),
        child: VisibilityDetector(
          key: const Key('pricing-page'),
          onVisibilityChanged: (info) {
            if (info.visibleFraction > 0.05) context.read<PricingCubit>().setVisible();
          },
          child: Column(
            children: [
              _buildHeader(context).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              // Toggle
              BlocBuilder<PricingCubit, PricingState>(
                builder: (ctx, state) => _BillingToggle(
                  isYearly: state.isYearly,
                  onToggle: () => ctx.read<PricingCubit>().toggleBilling(),
                ),
              ),
              const SizedBox(height: 56),
              BlocBuilder<PricingCubit, PricingState>(
                builder: (ctx, state) {
                  if (isMobile) {
                    return Column(
                      children: pricingPlans
                          .asMap()
                          .entries
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _PlanCard3D(
                                  plan: e.value,
                                  isYearly: state.isYearly,
                                  visible: state.visible,
                                  delay: e.key * 150,
                                ),
                              ))
                          .toList(),
                    );
                  }
                  if (isTablet) {
                    // Tablet: 2-column grid
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: pricingPlans
                          .map((plan) => SizedBox(
                                width: (MediaQuery.of(ctx).size.width - hPad * 2 - 20) / 2,
                                child: _PlanCard3D(
                                  plan: plan,
                                  isYearly: state.isYearly,
                                  visible: state.visible,
                                  delay: pricingPlans.indexOf(plan) * 150,
                                ),
                              ))
                          .toList(),
                    );
                  }
                  // Desktop: row layout
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pricingPlans
                        .asMap()
                        .entries
                        .map((e) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: e.key == 0 ? 0 : 12,
                                  right: e.key == 2 ? 0 : 12,
                                ),
                                child: _PlanCard3D(
                                  plan: e.value,
                                  isYearly: state.isYearly,
                                  visible: state.visible,
                                  delay: e.key * 150,
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'No hidden fees • No credit card required for free tier • Cancel anytime',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext ctx) {
    return Column(
      children: [
        const SectionBadge(label: 'PRICING PLANS', color: AppColors.purple),
        const SizedBox(height: 20),
        GradientText(
          text: 'Simple, Transparent Pricing',
          gradient: AppColors.primaryGrad,
          style: AppTextStyles.h1(ctx),
        ),
        const SizedBox(height: 12),
        Text('Start free and scale as you grow.',
            style: AppTextStyles.body(ctx), textAlign: TextAlign.center),
      ],
    );
  }
}

class _BillingToggle extends StatelessWidget {
  final bool isYearly;
  final VoidCallback onToggle;

  const _BillingToggle({required this.isYearly, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 14,
      runSpacing: 10,
      children: [
        Text('Monthly', style: GoogleFonts.inter(
            fontSize: 14, color: isYearly ? AppColors.textMuted : Colors.white, fontWeight: FontWeight.w600)),
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: 300.ms,
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: isYearly ? AppColors.primaryGrad : null,
              border: Border.all(color: isYearly ? Colors.transparent : AppColors.border),
              color: isYearly ? null : AppColors.bgCard,
            ),
            child: AnimatedAlign(
              duration: 300.ms,
              alignment: isYearly ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
            ),
          ),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Yearly', style: GoogleFonts.inter(
              fontSize: 14, color: isYearly ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.purple.withOpacity(0.2),
              border: Border.all(color: AppColors.purple.withOpacity(0.4)),
            ),
            child: Text('Save 20%',
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.purple, fontWeight: FontWeight.w700)),
          ),
        ]),
      ],
    );
  }
}

class _PlanCard3D extends StatefulWidget {
  final PricingModel plan;
  final bool isYearly;
  final bool visible;
  final int delay;

  const _PlanCard3D({required this.plan, required this.isYearly, required this.visible, required this.delay});

  @override
  State<_PlanCard3D> createState() => _PlanCard3DState();
}

class _PlanCard3DState extends State<_PlanCard3D> with SingleTickerProviderStateMixin {
  double _tiltX = 0;
  double _tiltY = 0;
  bool _hovered = false;
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: 2000.ms);
    if (widget.plan.isPopular) _glowCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent e, RenderBox box) {
    final local = box.globalToLocal(e.position);
    final w = box.size.width;
    final h = box.size.height;
    setState(() {
      _tiltX = (local.dy / h - 0.5) * 18;
      _tiltY = (local.dx / w - 0.5) * -18;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.visible ? 1 : 0,
      duration: Duration(milliseconds: 700 + widget.delay),
      child: AnimatedSlide(
        offset: widget.visible ? Offset.zero : const Offset(0, 0.1),
        duration: Duration(milliseconds: 700 + widget.delay),
        curve: Curves.easeOutCubic,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() {
            _hovered = false;
            _tiltX = 0;
            _tiltY = 0;
          }),
          child: Builder(builder: (ctx) {
            return Listener(
              onPointerMove: (e) {
                if (_hovered) {
                  final box = ctx.findRenderObject() as RenderBox?;
                  if (box != null) _onHover(e, box);
                }
              },
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, __) => AnimatedContainer(
                  duration: _hovered ? const Duration(milliseconds: 50) : const Duration(milliseconds: 300),
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_tiltX * pi / 180)
                    ..rotateY(_tiltY * pi / 180)
                    ..translate(0.0, _hovered ? -8.0 : 0.0),
                  transformAlignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (widget.plan.isPopular)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.plan.color.withOpacity(0.3 + 0.2 * _glowCtrl.value),
                                  blurRadius: 40 + 20 * _glowCtrl.value,
                                )
                              ],
                            ),
                          ),
                        ),
                      _buildCard(),
                      if (widget.plan.isPopular)
                        Positioned(
                          top: -14,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: widget.plan.gradient,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [BoxShadow(color: widget.plan.color.withOpacity(0.4), blurRadius: 12)],
                              ),
                              child: Text('⭐  MOST POPULAR',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                                      color: Colors.white, letterSpacing: 1.5)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final price = widget.isYearly ? widget.plan.yearlyPrice : widget.plan.monthlyPrice;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: widget.plan.isPopular
            ? LinearGradient(colors: [
                widget.plan.color.withOpacity(0.22),
                widget.plan.color.withOpacity(0.06),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : LinearGradient(colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)]),
        border: Border.all(
          color: widget.plan.isPopular
              ? widget.plan.color.withOpacity(_hovered ? 0.8 : 0.5)
              : (_hovered ? AppColors.border.withOpacity(0.8) : AppColors.border),
          width: widget.plan.isPopular ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.plan.name,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                  color: widget.plan.color, letterSpacing: 2)),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ShaderMask(
              shaderCallback: (b) => LinearGradient(
                  colors: [widget.plan.color, widget.plan.color.withOpacity(0.7)]).createShader(b),
              child: Text(price,
                  style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -1)),
            ),
            if (!price.contains('FREE'))
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text('/mo',
                    style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
              ),
          ]),
          if (widget.isYearly && !price.contains('FREE'))
            Text('Billed annually',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 24),
          ...widget.plan.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          color: f.$1 ? widget.plan.color.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
                      child: Icon(f.$1 ? Icons.check_rounded : Icons.close_rounded,
                          color: f.$1 ? widget.plan.color : AppColors.textMuted, size: 12)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f.$2,
                      style: GoogleFonts.inter(fontSize: 13,
                          color: f.$1 ? Colors.white.withOpacity(0.85) : AppColors.textMuted))),
                ]),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: widget.plan.isPopular
                ? GradientButton(label: widget.plan.cta,
                    colors: [widget.plan.color, widget.plan.color.withOpacity(0.7)], width: double.infinity)
                : GradientButton(label: widget.plan.cta, outlined: true, width: double.infinity),
          ),
        ],
      ),
    );
  }
}
