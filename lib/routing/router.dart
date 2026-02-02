import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/tabs/tab_shell.dart';
import '../features/home/home_screen.dart';
import '../features/alphabet/english_alphabet_screen.dart';
import '../features/alphabet/bangla_alphabet_screen.dart';
import '../features/alphabet/letter_detail_screen.dart';
import '../features/math/math_setup_screen.dart';
import '../features/draw/draw_screen.dart';
import '../features/story/story_screen.dart';
import '../features/speak/speak_screen.dart';
import '../features/games/games_screen.dart';
import '../features/games/memory_game_screen.dart';
import '../features/games/counting_game_screen.dart';
import '../features/games/shape_game_screen.dart';
import '../features/games/color_game_screen.dart';
import '../features/games/puzzle_game_screen.dart';
import '../features/games/spelling_bee_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
              child: const MathSetupScreen(),
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
      
      GoRoute(
        path: '/games',
        name: 'games',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const GamesScreen(),
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
        path: '/games/memory',
        name: 'memory-game',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MemoryGameScreen(),
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
        path: '/games/counting',
        name: 'counting-game',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CountingGameScreen(),
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
        path: '/games/shapes',
        name: 'shape-game',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShapeGameScreen(),
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
        path: '/games/colors',
        name: 'color-game',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ColorGameScreen(),
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
        path: '/games/puzzle',
        name: 'puzzle-game',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PuzzleGameScreen(),
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
        path: '/games/spelling',
        name: 'spelling-bee',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SpellingBeeScreen(),
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
    ],
  );
});
