import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/translator_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ChakmaTransliteratorApp());
}

class ChakmaTransliteratorApp extends StatelessWidget {
  const ChakmaTransliteratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'চাকমা-বাংলা লিপি রূপান্তর',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TranslatorScreen(),
    );
  }
}
