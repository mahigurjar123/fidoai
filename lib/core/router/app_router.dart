import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/home/home_page.dart';
import '../../presentation/home/bloc/home_cubit.dart';
import '../../presentation/features/features_page.dart';
import '../../presentation/features/bloc/features_cubit.dart';
import '../../presentation/how_it_works/how_it_works_page.dart';
import '../../presentation/pricing/pricing_page.dart';
import '../../presentation/pricing/bloc/pricing_cubit.dart';
import '../../presentation/testimonials/testimonials_page.dart';
import '../../presentation/testimonials/bloc/testimonials_cubit.dart';
import '../../presentation/faq/faq_page.dart';
import '../../presentation/faq/bloc/faq_cubit.dart';
import '../../presentation/contact/contact_page.dart';
import '../../presentation/contact/bloc/contact_cubit.dart';
import '../../presentation/shared/app_navbar.dart';
import '../../presentation/shared/animated_bg.dart';
import '../../presentation/shared/app_footer.dart';

Widget _fade(BuildContext ctx, Animation<double> anim, Animation<double> sec, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
    child: child,
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF060614),
          body: Stack(
            children: [
              // AnimatedBg builds Positioned.fill internally — must be a
              // direct Stack child (no outer RepaintBoundary wrapper).
              const AnimatedBg(),
              // Particles has its own internal RepaintBoundary.
              const Particles(count: 35),
              SafeArea(child: child),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppNavBar(),
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (ctx, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(create: (_) => HomeCubit(), child: const HomePage()),
            transitionsBuilder: _fade,
          ),
        ),
        GoRoute(
          path: '/features',
          pageBuilder: (ctx, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(create: (_) => FeaturesCubit(), child: const FeaturesPage()),
            transitionsBuilder: _fade,
          ),
        ),
        GoRoute(
          path: '/how-it-works',
          pageBuilder: (ctx, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HowItWorksPage(),
            transitionsBuilder: _fade,
          ),
        ),
        GoRoute(
          path: '/pricing',
          pageBuilder: (ctx, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(create: (_) => PricingCubit(), child: const PricingPage()),
            transitionsBuilder: _fade,
          ),
        ),
        GoRoute(
          path: '/testimonials',
          pageBuilder: (ctx, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => TestimonialsCubit(),
              child: const TestimonialsPage(),
            ),
            transitionsBuilder: _fade,
          ),
        ),
        GoRoute(
          path: '/faq',
          pageBuilder: (ctx, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(create: (_) => FAQCubit(), child: const FAQPage()),
            transitionsBuilder: _fade,
          ),
        ),
        GoRoute(
          path: '/contact',
          pageBuilder: (ctx, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(create: (_) => ContactCubit(), child: const ContactPage()),
            transitionsBuilder: _fade,
          ),
        ),
      ],
    ),
  ],
);
