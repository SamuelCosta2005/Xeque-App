import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/home_shell.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const XequeApp());
}

class XequeApp extends StatelessWidget {
  const XequeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.themeIsDark,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Xeque',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.current,
          home: HomeShell(),
        );
      },
    );
  }
}
