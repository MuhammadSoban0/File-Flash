import 'package:file_downloader/home_screen.dart';
import 'package:file_downloader/splash_screen.dart';
import 'package:file_downloader/theme_mood_selection.dart';
import 'package:file_downloader/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


late SharedPreferences prefs;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeTypeProvider,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeProvider.lightTheme,
        darkTheme: ThemeProvider.darkTheme,
        themeMode: themeTypeProvider.value,
        home: SplashScreen(),
      ),
    );
  }
}