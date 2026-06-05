import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../shared/glass_card.dart';
import '../shared/gradient_button.dart';
import '../shared/section_badge.dart';
import '../shared/app_footer.dart';
import 'bloc/contact_cubit.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> with SingleTickerProviderStateMixin {
  late AnimationController _orbCtrl;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  static const _socials = [
    (Icons.language, 'Website', 'www.fidoai.com', AppColors.purple),
    (Icons.email_rounded, 'Email', 'hello@fidoai.com', AppColors.blue),
    (Icons.tag, 'Twitter / X', '@FidoAI', AppColors.cyan),
    (Icons.discord, 'Discord', 'discord.gg/fidoai', AppColors.purple),
    (Icons.camera_alt_rounded, 'Instagram', '@fidoai.app', AppColors.pink),
    (Icons.code, 'GitHub', 'github.com/fido-ai', AppColors.textSecondary),
  ];

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = R.mobile(context);
    final hPad = R.hp(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 100, left: hPad, right: hPad, bottom: 80),
            child: Column(
              children: [
                _buildHeader(context).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 60),
                isMobile
                    ? Column(children: [
                        _buildForm(context, true),
                        const SizedBox(height: 40),
                        _buildSocialLinks(isMobile),
                      ])
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 55, child: _buildForm(context, false)),
                        const SizedBox(width: 48),
                        Expanded(flex: 45, child: _buildSocialLinks(false)),
                      ]),
                const SizedBox(height: 80),
                _buildFooter(context),
              ],
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
        const SectionBadge(label: 'GET IN TOUCH', color: AppColors.cyan),
        const SizedBox(height: 20),
        GradientText(
          text: 'Start Your AI Journey',
          gradient: AppColors.cyanGrad,
          style: AppTextStyles.h1(ctx),
        ),
        const SizedBox(height: 12),
        Text('Join 500,000+ creators, developers, and businesses using Fido AI.',
            style: AppTextStyles.body(ctx), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildForm(BuildContext ctx, bool isMobile) {
    return BlocConsumer<ContactCubit, ContactState>(
      listener: (ctx, state) {
        if (state.submitted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('Message sent! We will get back to you soon.',
                  style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: AppColors.purple,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (ctx, state) {
        if (state.submitted) {
          return GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGrad,
                    boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 24)],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                GradientText(
                  text: 'Message Sent!',
                  gradient: AppColors.primaryGrad,
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text("We'll get back to you at ${state.email} within 24 hours.",
                    style: AppTextStyles.body(ctx), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Send Another Message',
                  onTap: () => ctx.read<ContactCubit>().reset(),
                ),
              ],
            ),
          );
        }

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send a Message',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 6),
              Text('We reply within 24 hours.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              _inputField('Your Name', Icons.person_rounded, _nameCtrl,
                  onChanged: (v) => ctx.read<ContactCubit>().updateName(v)),
              const SizedBox(height: 16),
              _inputField('Email Address', Icons.email_rounded, _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => ctx.read<ContactCubit>().updateEmail(v)),
              const SizedBox(height: 16),
              _textArea('Your Message', _msgCtrl,
                  onChanged: (v) => ctx.read<ContactCubit>().updateMessage(v)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Send Message',
                  icon: Icons.send_rounded,
                  onTap: () => ctx.read<ContactCubit>().submit(),
                  width: double.infinity,
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(duration: 700.ms, delay: 200.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _inputField(
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: Colors.white.withOpacity(0.04),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cursorColor: AppColors.purple,
      ),
    );
  }

  Widget _textArea(String hint, TextEditingController ctrl, {Function(String)? onChanged}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: Colors.white.withOpacity(0.04),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: 5,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        cursorColor: AppColors.purple,
      ),
    );
  }

  Widget _buildSocialLinks(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect With Us',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Find us across all platforms.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 28),
        ..._socials.asMap().entries.map((e) => _SocialCard(
              icon: e.value.$1,
              label: e.value.$2,
              value: e.value.$3,
              color: e.value.$4,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 200 + e.key * 70))
                .slideX(begin: 0.1, end: 0)),
      ],
    ).animate().fadeIn(duration: 700.ms, delay: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildFooter(BuildContext ctx) {
    return AnimatedBuilder(
      animation: _orbCtrl,
      builder: (_, __) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 56,
          horizontal: R.mobile(ctx) ? 20 : 32,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF140A2A), Color(0xFF0A142A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.purple.withOpacity(0.3 + 0.2 * _orbCtrl.value),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.15 + 0.1 * _orbCtrl.value),
              blurRadius: 60,
            )
          ],
        ),
        child: Column(
          children: [
            GradientText(
              text: '© 2025 Fido AI',
              gradient: AppColors.primaryGrad,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('All Rights Reserved • www.fidoai.com',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 24),
            Wrap(spacing: 24, runSpacing: 8, children: [
              'Flutter Web App', 'Google Play', 'App Store',
            ].map((t) => Text(t,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted.withOpacity(0.6)))).toList()),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0);
  }
}

class _SocialCard extends StatefulWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _SocialCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  State<_SocialCard> createState() => _SocialCardState();
}

class _SocialCardState extends State<_SocialCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? widget.color.withOpacity(0.6) : AppColors.border,
            ),
            gradient: LinearGradient(colors: _hovered
                ? [widget.color.withOpacity(0.12), widget.color.withOpacity(0.04)]
                : [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.01)]),
            boxShadow: _hovered ? [BoxShadow(color: widget.color.withOpacity(0.15), blurRadius: 16)] : [],
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: 200.ms,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _hovered
                    ? LinearGradient(colors: [widget.color, widget.color.withOpacity(0.6)])
                    : null,
                color: _hovered ? null : widget.color.withOpacity(0.1),
              ),
              child: Icon(widget.icon, color: _hovered ? Colors.white : widget.color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.label,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.textMuted, letterSpacing: 1)),
                Text(widget.value,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
                        color: _hovered ? Colors.white : AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                color: _hovered ? widget.color : AppColors.textMuted, size: 14),
          ]),
        ),
      ),
    );
  }
}
