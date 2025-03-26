import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';



// final themeProvider = ChangeNotifierProvider<ThemeProvider>(
//         (ref) => ThemeProvider());

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    loadFromPrefs();
  }

  bool isDarkMode = false;
  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      dividerTheme: DividerThemeData(color: Colors.white),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStatePropertyAll(Colors.grey[200]),
        thumbColor: WidgetStatePropertyAll(Colors.black),
      ),
      fontFamily: "SSPro",
      canvasColor: Colors.transparent,
      primaryColor: Colors.black38,
      scaffoldBackgroundColor: Colors.black54,
      shadowColor: Colors.black,
      hoverColor: Color(0xff3F8CFF),
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actionsIconTheme: IconThemeData(
          color: Color(0xffffffff),
        ),
        color: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xffffffff), size: 24),
        toolbarTextStyle: darkAppBarTextTheme.bodyMedium,
        titleTextStyle: darkAppBarTextTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black.withOpacity(0.02),
        ),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: Colors.black,
      ),
      cardTheme: CardTheme(
        color: Colors.grey.shade300.withValues(alpha: 0.1),
        // shadowColor: Color(0xff000000),
        shadowColor: Colors.white,
        elevation: 1,
        margin: EdgeInsets.all(0),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      textTheme: darkTextTheme,
      indicatorColor: Colors.white,
      disabledColor: Color(0xffa3a3a3),
      highlightColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(),
      dividerColor: Color(0xffd1d1d1),
      cardColor: Color(0xff282a2b),
      splashColor: Colors.white.withOpacity(0.3),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xff3d63ff),
          splashColor: Colors.white.withOpacity(0.3),
          highlightElevation: 8,
          elevation: 4,
          focusColor: Color(0xff3d63ff),
          hoverColor: Color(0xff3d63ff),
          foregroundColor: Colors.white),
      popupMenuTheme: PopupMenuThemeData(
        color: Color(0xff37404a),
        textStyle: lightTextTheme.bodyMedium?.merge(TextStyle(color: Color(0xffffffff))),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: Color(0xff3d63ff),
        inactiveTrackColor: Color(0xff3d63ff).withAlpha(100),
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbColor: Color(0xff3d63ff),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
        tickMarkShape: RoundSliderTickMarkShape(),
        inactiveTickMarkColor: Colors.red[100],
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(),
      colorScheme: ColorScheme.dark(
        primary: Color(0xff3d63ff),
        secondary: Color(0xff00cc77),
        background: Color(0xff343a40),
        onPrimary: Colors.white,
        onBackground: Colors.white,
        onSecondary: Colors.white,
        surface: Color(0xff585e63),
      )
          .copyWith(secondary: Color(0xff3d63ff))
          .copyWith(background: Color(0xff0F1733))
          .copyWith(error: Colors.orange)
  );

  static ThemeData get lightTheme => ThemeData(
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStatePropertyAll(Colors.white12),
      trackColor: WidgetStatePropertyAll(Colors.white),
      thumbColor: WidgetStatePropertyAll(Colors.white),
    ),
    useMaterial3: true,
    fontFamily: "SSPro",
    brightness: Brightness.light,
    primaryColor: Colors.white,
    canvasColor: Colors.transparent,
    scaffoldBackgroundColor: Colors.white,
    shadowColor: Colors.black.withOpacity(0.25),
    hoverColor: Color(0xff1e319d),
    dividerTheme: DividerThemeData(color: Colors.black26),
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      actionsIconTheme: IconThemeData(
        color: Color(0xff495057),
      ),
      color: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xff495057), size: 24),
      toolbarTextStyle: lightAppBarTextTheme.bodyMedium,
      titleTextStyle: lightAppBarTextTheme.titleLarge,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white.withOpacity(0.02),
        systemNavigationBarColor: Colors.white.withOpacity(0.02),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
        selectedIconTheme: IconThemeData(color: Color(0xff3d63ff), opacity: 1, size: 24),
        unselectedIconTheme: IconThemeData(color: Color(0xff495057), opacity: 1, size: 24),
        backgroundColor: Color(0xffffffff),
        elevation: 3,
        selectedLabelTextStyle: TextStyle(color: Color(0xff3d63ff)),
        unselectedLabelTextStyle: TextStyle(color: Color(0xff495057))),
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.25),
      elevation: 1,
      margin: EdgeInsets.all(0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(fontSize: 15, color: Color(0xaa495057)),
    ),
    splashColor: Colors.grey.withOpacity(0.3),
    iconTheme: IconThemeData(
      color: Color(0xff495057),
    ),
    textTheme: lightTextTheme,
    indicatorColor: Colors.white,
    disabledColor: Color(0xffdcc7ff),
    highlightColor: Colors.white,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xff3d63ff),
        splashColor: Colors.grey.withOpacity(0.3),
        highlightElevation: 8,
        elevation: 4,
        focusColor: Color(0xff3d63ff),
        hoverColor: Color(0xff3d63ff),
        foregroundColor: Colors.white),
    dividerColor: Color(0xffd1d1d1),
    cardColor: Colors.white,
    popupMenuTheme: PopupMenuThemeData(
      color: Color(0xffffffff),
      textStyle: lightTextTheme.bodyMedium?.merge(TextStyle(color: Color(0xff495057))),
    ),
    bottomAppBarTheme: BottomAppBarTheme(color: Color(0xffffffff), elevation: 2),
    tabBarTheme: TabBarTheme(
      unselectedLabelColor: Color(0xff495057),
      labelColor: Color(0xff3d63ff),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Color(0xff3d63ff), width: 2.0),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Color(0xff3d63ff),
      inactiveTrackColor: Color(0xff3d63ff).withAlpha(140),
      trackShape: RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      thumbColor: Color(0xff3d63ff),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      inactiveTickMarkColor: Colors.red[100],
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.light(
        primary: Color(0xff3d63ff),
        onPrimary: Colors.white,
        secondary: Color(0xff495057),
        onSecondary: Colors.white,
        surface: Color(0xffe2e7f1),
        background: Color(0xfff3f4f7),
        onBackground: Color(0xff495057))
        .copyWith(secondary: Color(0xff3d63ff))
        .copyWith(background: Colors.white)
        .copyWith(error: Color(0xfff0323c)),
  );

  Future toggleTheme() async {
    isDarkMode = !isDarkMode;
    await saveToPrefs();
    notifyListeners();
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDarkMode);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    isDarkMode = prefs.getBool('isDark') ?? false;
  }


  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 102, color: Color(0xff4a4c4f)),
    displayMedium: TextStyle(fontSize: 64, color: Color(0xff4a4c4f)),
    displaySmall: TextStyle(fontSize: 51, color: Color(0xff4a4c4f)),
    headlineMedium: TextStyle(fontSize: 36, color: Color(0xff4a4c4f)),
    headlineSmall: TextStyle(fontSize: 25, color: Color(0xff4a4c4f)),
    titleLarge: TextStyle(fontSize: 18, color: Color(0xff4a4c4f)),
    titleMedium: TextStyle(fontSize: 17, color: Color(0xff4a4c4f)),
    titleSmall: TextStyle(fontSize: 15, color: Color(0xff4a4c4f)),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xff4a4c4f)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xff4a4c4f)),
    labelLarge: TextStyle(fontSize: 15, color: Color(0xff4a4c4f)),
    bodySmall: TextStyle(fontSize: 13, color: Color(0xff4a4c4f)),
    labelSmall: TextStyle(fontSize: 11, color: Color(0xff4a4c4f)),
  );
  static final TextTheme lightAppBarTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 102, color: Color(0xff495057)),
    displayMedium: TextStyle(fontSize: 64, color: Color(0xff495057)),
    displaySmall: TextStyle(fontSize: 51, color: Color(0xff495057)),
    headlineMedium: TextStyle(fontSize: 36, color: Color(0xff495057)),
    headlineSmall: TextStyle(fontSize: 25, color: Color(0xff495057)),
    titleLarge: TextStyle(fontSize: 18, color: Color(0xff495057)),
    titleMedium: TextStyle(fontSize: 17, color: Color(0xff495057)),
    titleSmall: TextStyle(fontSize: 15, color: Color(0xff495057)),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xff495057)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xff495057)),
    labelLarge: TextStyle(fontSize: 15, color: Color(0xff495057)),
    bodySmall: TextStyle(fontSize: 13, color: Color(0xff495057)),
    labelSmall: TextStyle(fontSize: 11, color: Color(0xff495057)),
  );
  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 102, color: Colors.white),
    displayMedium: TextStyle(fontSize: 64, color: Colors.white),
    displaySmall: TextStyle(fontSize: 51, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 36, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 25, color: Colors.white),
    titleLarge: TextStyle(fontSize: 18, color: Colors.white),
    titleMedium: TextStyle(fontSize: 17, color: Colors.white),
    titleSmall: TextStyle(fontSize: 15, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
    labelLarge: TextStyle(fontSize: 15, color: Colors.white),
    bodySmall: TextStyle(fontSize: 13, color: Colors.white),
    labelSmall: TextStyle(fontSize: 11, color: Colors.white),
  );
  static final TextTheme darkAppBarTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 102, color: Color(0xffffffff)),
    displayMedium: TextStyle(fontSize: 64, color: Color(0xffffffff)),
    displaySmall: TextStyle(fontSize: 51, color: Color(0xffffffff)),
    headlineMedium: TextStyle(fontSize: 36, color: Color(0xffffffff)),
    headlineSmall: TextStyle(fontSize: 25, color: Color(0xffffffff)),
    titleLarge: TextStyle(fontSize: 20, color: Color(0xffffffff)),
    titleMedium: TextStyle(fontSize: 17, color: Color(0xffffffff)),
    titleSmall: TextStyle(fontSize: 15, color: Color(0xffffffff)),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xffffffff)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xffffffff)),
    labelLarge: TextStyle(fontSize: 15, color: Color(0xffffffff)),
    bodySmall: TextStyle(fontSize: 13, color: Color(0xffffffff)),
    labelSmall: TextStyle(fontSize: 11, color: Color(0xffffffff)),
  );
}