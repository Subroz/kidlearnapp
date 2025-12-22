import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/tabs/tab_shell.dart';
import '../features/home/home_screen.dart';
import '../features/alphabet/english_alphabet_screen.dart';
import '../features/alphabet/bangla_alphabet_screen.dart';
import '../features/alphabet/letter_detail_screen.dart';
import '../features/math/math_screen.dart';
import '../features/draw/draw_screen.dart';
import '../features/story/story_screen.dart';
import '../features/speak/speak_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      
      // Main Tab Shell
      ShellRoute(
        builder: (context, state, child) => TabShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/math',
            name: 'math',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MathScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/draw',
            name: 'draw',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DrawScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/story',
            name: 'story',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const StoryScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/speak',
            name: 'speak',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SpeakScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      
      // Alphabet Routes
      GoRoute(
        path: '/alphabet/english',
        name: 'english-alphabet',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EnglishAlphabetScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/alphabet/bangla',
        name: 'bangla-alphabet',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BanglaAlphabetScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/alphabet/letter/:lang/:id',
        name: 'letter-detail',
        pageBuilder: (context, state) {
          final lang = state.pathParameters['lang']!;
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: LetterDetailScreen(language: lang, letterId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
    ],
  );
});
