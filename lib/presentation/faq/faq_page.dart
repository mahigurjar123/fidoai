import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../shared/section_badge.dart';
import '../shared/app_footer.dart';
import 'bloc/faq_cubit.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> with SingleTickerProviderStateMixin {
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = R.mobile(context);
    final hPad = R.hp(context);

    return Stack(
      children: [
        // Rotating geometric shapes background — isolated in RepaintBoundary
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                painter: _GeoPainter(t: _bgCtrl.value),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
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
                  key: const Key('faq-page'),
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction > 0.05) context.read<FAQCubit>().setVisible();
                  },
                  child: Column(
                    children: [
                      _buildHeader(context).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 60),
                      BlocBuilder<FAQCubit, FAQState>(
                        builder: (ctx, state) => ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: Column(
                            children: faqs
                                .asMap()
                                .entries
                                .map((e) => AnimatedOpacity(
                                      opacity: state.visible ? 1 : 0,
                                      duration: Duration(milliseconds: 600 + e.key * 80),
                                      child: AnimatedSlide(
                                        offset: state.visible ? Offset.zero : const Offset(0, 0.1),
                                        duration: Duration(milliseconds: 600 + e.key * 80),
                                        curve: Curves.easeOutCubic,
                                        child: _FAQItem(
                                          faq: e.value,
                                          index: e.key,
                                          isExpanded: state.expandedIndex == e.key,
                                          onTap: () => ctx.read<FAQCubit>().toggle(e.key),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const AppFooter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext ctx) {
    return Column(
      children: [
        const SectionBadge(label: 'FAQ', color: AppColors.pink),
        const SizedBox(height: 20),
        Text('Got Questions?', style: AppTextStyles.h1(ctx), textAlign: TextAlign.center),
        GradientText(
          text: 'We Have Answers.',
          gradient: AppColors.pinkGrad,
          style: AppTextStyles.h1(ctx),
        ),
        const SizedBox(height: 12),
        Text('Everything you need to know about Fido AI.',
            style: AppTextStyles.body(ctx), textAlign: TextAlign.center),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final FAQModel faq;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FAQItem({required this.faq, required this.index, required this.isExpanded, required this.onTap});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;
  late Animation<double> _rotateAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 350.ms);
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _rotateAnim = Tween(begin: 0.0, end: 0.5).animate(_expandAnim);
  }

  @override
  void didUpdateWidget(_FAQItem old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != old.isExpanded) {
      widget.isExpanded ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = R.mobile(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: 250.ms,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: widget.isExpanded
                    ? [AppColors.pink.withOpacity(0.12), AppColors.purple.withOpacity(0.06)]
                    : [Colors.white.withOpacity(_hovered ? 0.07 : 0.04), Colors.white.withOpacity(0.01)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: widget.isExpanded
                    ? AppColors.pink.withOpacity(0.45)
                    : (_hovered ? AppColors.border.withOpacity(0.8) : AppColors.border),
              ),
              boxShadow: widget.isExpanded
                  ? [BoxShadow(color: AppColors.pink.withOpacity(0.1), blurRadius: 20)]
                  : [],
            ),
            child: Column(
              children: [
                // Question
                Padding(
                  padding: EdgeInsets.all(isMobile ? 14 : 20),
                  child: Row(children: [
                    // Number badge
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.isExpanded ? AppColors.pinkGrad : null,
                        border: widget.isExpanded ? null : Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text('${widget.index + 1}',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                                color: widget.isExpanded ? Colors.white : AppColors.textMuted)),
                      ),
                    ),
                    Expanded(
                      child: Text(widget.faq.question,
                          style: GoogleFonts.inter(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: widget.isExpanded ? Colors.white : Colors.white.withOpacity(0.85))),
                    ),
                    const SizedBox(width: 12),
                    RotationTransition(
                      turns: _rotateAnim,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: widget.isExpanded ? AppColors.pinkGrad : null,
                          border: widget.isExpanded ? null : Border.all(color: AppColors.border),
                        ),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            color: widget.isExpanded ? Colors.white : AppColors.textSecondary, size: 18),
                      ),
                    ),
                  ]),
                ),
                // Answer
                SizeTransition(
                  sizeFactor: _expandAnim,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isMobile ? 14 : 62, 0, isMobile ? 14 : 20, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(height: 1, color: AppColors.pink.withOpacity(0.2),
                          margin: const EdgeInsets.only(bottom: 16)),
                      Text(widget.faq.answer,
                          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.75)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GeoPainter extends CustomPainter {
  final double t;
  _GeoPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    _drawTriangle(canvas, Offset(size.width * 0.85, size.height * 0.15),
        80, t * 2 * pi, const Color(0xFFFF2FBE).withOpacity(0.07));
    _drawTriangle(canvas, Offset(size.width * 0.1, size.height * 0.8),
        60, -t * 2 * pi, const Color(0xFF7B2FFF).withOpacity(0.07));
    _drawHexagon(canvas, Offset(size.width * 0.9, size.height * 0.65),
        50, t * pi, const Color(0xFF2F8FFF).withOpacity(0.06));
    _drawHexagon(canvas, Offset(size.width * 0.15, size.height * 0.2),
        40, -t * pi * 0.7, const Color(0xFFFF2FBE).withOpacity(0.06));
  }

  void _drawTriangle(Canvas canvas, Offset center, double size, double angle, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size * sin(2 * pi / 3), size * cos(2 * pi / 3).abs())
      ..lineTo(-size * sin(2 * pi / 3), size * cos(2 * pi / 3).abs())
      ..close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.restore();
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, double angle, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3;
      if (i == 0) path.moveTo(size * cos(a), size * sin(a));
      else path.lineTo(size * cos(a), size * sin(a));
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GeoPainter old) => old.t != t;
}
