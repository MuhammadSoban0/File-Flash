import 'dart:ui';

import 'package:file_downloader/theme_mood_selection.dart';
import 'package:flutter/material.dart';

import '../main.dart';

void showFloatingBottomSheet(BuildContext context, bool darkMode) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 30),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: darkMode ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'APPEARANCE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          themeTypeProvider.setTheme(ThemeMode.light);
                          await prefs.setString("selectedTheme", "light");
                          setState(() {
                            darkMode = false;
                          });
                        },
                        child: Container(
                          width: 100,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: darkMode ? Colors.grey.shade300.withOpacity(0.6) : Colors.blue,
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: AssetImage('assets/images/light.jpeg'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(3, 3),
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                              BoxShadow(
                                offset: Offset(-3, -3),
                                color: Colors.white30,
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(14),
                                    bottomLeft: Radius.circular(14))),
                            width: double.infinity,
                            height: 30,
                            padding: const EdgeInsets.all(4),
                            child: Center(
                              child: Text(
                                "Light",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          themeTypeProvider.setTheme(ThemeMode.dark);
                          await prefs.setString("selectedTheme", "dark");
                          setState(() {
                            darkMode = true;
                          });
                        },
                        child: Container(
                          width: 100,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: darkMode ? Colors.blue : Colors.grey.shade300.withOpacity(0.6),
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: AssetImage('assets/images/dark.jpeg'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(3, 3),
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                              BoxShadow(
                                offset: Offset(-3, -3),
                                color: Colors.white30,
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(14),
                                    bottomLeft: Radius.circular(14))),
                            width: double.infinity,
                            height: 30,
                            padding: const EdgeInsets.all(4),
                            child: Center(
                              child: Text(
                                "Dark",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}