import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/router.dart';
import 'core/theme/app_theme.dart';
import 'core/i18n/language_controller.dart';

class KidLearnApp extends ConsumerWidget {
  const KidLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final language = ref.watch(languageProvider);
    
    return MaterialApp.router(
      title: language == AppLanguage.bangla ? 'কিডলার্ন' : 'KIDLEARN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
