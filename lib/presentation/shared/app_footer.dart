import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'fido_logo.dart';

class AppFooter extends StatefulWidget {
  const AppFooter({super.key});
  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _entranceCtrl;

  static const _cols = [
    ('PRODUCT', [
      ('Features', '/features'),
      ('How It Works', '/how-it-works'),
      ('Pricing', '/pricing'),
    ]),
    ('COMPANY', [
      ('About', '/contact'),
      ('Blog', '/contact'),
      ('Careers', '/contact'),
    ]),
    ('SUPPORT', [
      ('FAQ', '/faq'),
      ('Contact Us', '/contact'),
      ('Community', '/contact'),
    ]),
  ];

  static const _socials = [
    (Icons.chat_bubble_outline_rounded, 'Discord'),
    (Icons.alternate_email_rounded, 'Twitter / X'),
    (Icons.code_rounded, 'GitHub'),
    (Icons.camera_alt_outlined, 'Instagram'),
  ];

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _entranceCtrl = AnimationController(vsync: this, duration: 700.ms)..forward();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _glowCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = R.hp(context);
    final isMobile = R.mobile(context);

    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF04040E),
          border: Border(
            top: BorderSide(color: AppColors.border.withOpacity(.5), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(.04 + .02 * _glowCtrl.value),
              blurRadius: 50,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: child!,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated wave divider
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => CustomPaint(
                painter: _WavePainter(t: _waveCtrl.value),
                size: const Size(double.infinity, 56),
              ),
            ),
          ),

          // Main footer body
          Padding(
            padding: EdgeInsets.fromLTRB(hp, 16, hp, 0),
            child: isMobile ? _buildMobile(context) : _buildDesktop(context),
          ),

          // Bottom copyright bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: hp),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border.withOpacity(.3))),
            ),
            child: Row(children: [
              Text('© 2025 Fido AI — All rights reserved.',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              Text('Built with Flutter Web ✦',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            ]),
          ),
        ],
      ),
    ).animate(controller: _entranceCtrl).fadeIn(duration: 600.ms);
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 240, child: _buildBrand()),
        const SizedBox(width: 56),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _cols.map((c) => _buildLinkCol(c.$1, c.$2)).toList(),
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(width: 140, child: _buildSocial()),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrand(),
        const SizedBox(height: 32),
        Wrap(
          spacing: 32, runSpacing: 24,
          children: _cols.map((c) => SizedBox(
            width: 110,
            child: _buildLinkCol(c.$1, c.$2),
          )).toList(),
        ),
        const SizedBox(height: 28),
        _buildSocial(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated 3D Logo
        const FidoAILogo(size: 36, showText: true),
        const SizedBox(height: 14),
        Text(
          'Next-generation AI platform for creators, developers, and enterprises worldwide.',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.65),
        ),
        const SizedBox(height: 18),
        // Tech tags
        Wrap(spacing: 7, runSpacing: 7, children: [
          for (final t in ['GPT-4o', 'DALL·E 3', 'Flutter'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
                color: Colors.white.withOpacity(.03),
              ),
              child: Text(t, style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: .6)),
            ),
        ]),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLinkCol(String title, List<(String, String)> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.4)),
        const SizedBox(height: 14),
        ...links.map((l) => _FooterLink(label: l.$1, path: l.$2)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FOLLOW US',
            style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.4)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 9, runSpacing: 9,
          children: _socials.map((s) => _SocialBtn(icon: s.$1)).toList(),
        ),
      ],
    );
  }
}

// ── Footer link with hover effect ─────────────────────────────────────────────
class _FooterLink extends StatefulWidget {
  final String label, path;
  const _FooterLink({required this.label, required this.path});
  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit: (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: () => context.go(widget.path),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: AnimatedDefaultTextStyle(
          duration: 180.ms,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _h ? Colors.white : AppColors.textSecondary,
            fontWeight: _h ? FontWeight.w500 : FontWeight.w400,
          ),
          child: Text(widget.label),
        ),
      ),
    ),
  );
}

// ── Social icon button ─────────────────────────────────────────────────────────
class _SocialBtn extends StatefulWidget {
  final IconData icon;
  const _SocialBtn({required this.icon});
  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit: (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: 200.ms,
      width: 36, height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: _h ? AppColors.primaryGrad : null,
        border: _h ? null : Border.all(color: AppColors.border),
        color: _h ? null : Colors.white.withOpacity(.03),
        boxShadow: _h ? [BoxShadow(color: AppColors.purple.withOpacity(.3), blurRadius: 12)] : [],
      ),
      child: Icon(widget.icon, color: _h ? Colors.white : AppColors.textMuted, size: 15),
    ),
  );
}

// ── Animated wave painter for footer top ──────────────────────────────────────
class _WavePainter extends CustomPainter {
  final double t;
  const _WavePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final path1 = Path();
    final path2 = Path();

    path1.moveTo(0, size.height);
    path2.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y1 = size.height * .5 +
          sin((x / size.width * 2 * pi) + t * 2 * pi) * size.height * .35 +
          sin((x / size.width * 3.5 * pi) + t * pi * 1.2) * size.height * .15;

      final y2 = size.height * .6 +
          sin((x / size.width * 2.5 * pi) + t * 2 * pi + 1.0) * size.height * .28 +
          sin((x / size.width * 4 * pi) + t * pi * 0.8) * size.height * .1;

      path1.lineTo(x, y1);
      path2.lineTo(x, y2);
    }

    path1.lineTo(size.width, size.height);
    path1.close();
    path2.lineTo(size.width, size.height);
    path2.close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawPath(
      path2,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.blue.withOpacity(.06),
            AppColors.cyan.withOpacity(.04),
          ],
        ).createShader(rect),
    );

    canvas.drawPath(
      path1,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.purple.withOpacity(.09),
            AppColors.blue.withOpacity(.06),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_WavePainter o) => o.t != t;
}
