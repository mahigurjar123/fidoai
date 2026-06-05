import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'gradient_button.dart';

class AppNavBar extends StatefulWidget {
  const AppNavBar({super.key});

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> {
  bool _mobileOpen = false;

  static const _items = [
    ('Features', '/features'),
    ('How It Works', '/how-it-works'),
    ('Pricing', '/pricing'),
    ('Testimonials', '/testimonials'),
    ('FAQ', '/faq'),
  ];

  @override
  Widget build(BuildContext context) {
    // Use < 900 so tablets also get a hamburger menu — saves horizontal space
    final isMobile = MediaQuery.of(context).size.width < 900;
    final hPad = R.hp(context);
    final loc = GoRouterState.of(context).matchedLocation;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF060614).withOpacity(0.85),
            border: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 64,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Row(
                    children: [
                      const _Logo(),
                      const Spacer(),
                      if (!isMobile)
                        Row(children: [
                          ..._items.map((e) => _Link(
                                label: e.$1,
                                path: e.$2,
                                active: loc == e.$2,
                                onTap: () => context.go(e.$2),
                              )),
                          const SizedBox(width: 20),
                          GradientButton(
                            label: 'Get Started',
                            icon: Icons.rocket_launch_rounded,
                            onTap: () => context.go('/contact'),
                            fontSize: 13,
                          ),
                        ])
                      else
                        IconButton(
                          tooltip: _mobileOpen ? 'Close menu' : 'Open menu',
                          onPressed: () => setState(() => _mobileOpen = !_mobileOpen),
                          icon: AnimatedSwitcher(
                            duration: 200.ms,
                            child: Icon(
                              _mobileOpen ? Icons.close_rounded : Icons.menu_rounded,
                              key: ValueKey(_mobileOpen),
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Mobile drawer panel
              if (isMobile && _mobileOpen)
                _MobileMenu(
                  items: _items,
                  currentPath: loc,
                  onTap: (path) {
                    context.go(path);
                    setState(() => _mobileOpen = false);
                  },
                ).animate().slideY(begin: -0.2, end: 0, duration: 200.ms).fadeIn(),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: -1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}

class _Logo extends StatefulWidget {
  const _Logo();

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/'),
        child: AnimatedScale(
          scale: _hovered ? 1.06 : 1.0,
          duration: 200.ms,
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppColors.primaryGrad,
                boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.5), blurRadius: 14)],
              ),
              child: const Center(
                child: Text('F',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (b) => AppColors.primaryGrad.createShader(b),
              child: Text(
                'Fido AI',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Link extends StatefulWidget {
  final String label, path;
  final bool active;
  final VoidCallback onTap;
  const _Link({required this.label, required this.path, required this.active, required this.onTap});

  @override
  State<_Link> createState() => _LinkState();
}

class _LinkState extends State<_Link> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: 200.ms,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: (widget.active || _hovered) ? Colors.white : AppColors.textSecondary,
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: 200.ms,
                height: 2,
                width: widget.active ? 24 : (_hovered ? 16 : 0),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGrad,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  final List<(String, String)> items;
  final String currentPath;
  final Function(String) onTap;

  const _MobileMenu({
    required this.items,
    required this.currentPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map((e) {
            final isActive = currentPath == e.$2;
            return GestureDetector(
              onTap: () => onTap(e.$2),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isActive ? AppColors.purple.withOpacity(0.1) : Colors.transparent,
                ),
                child: Text(
                  e.$1,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Get Started Free',
            icon: Icons.rocket_launch_rounded,
            onTap: () => onTap('/contact'),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
