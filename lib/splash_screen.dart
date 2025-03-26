import 'package:file_downloader/home_screen.dart';
import 'package:file_downloader/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

final myShadow = <Shadow>[
  Shadow(
    offset: Offset(02.0, 02.0),
    blurRadius: 2.0,
    color: Colors.black38,
  ),
  Shadow(
    offset: Offset(02.0, 02.0),
    blurRadius: 2.0,
    color: Colors.black38,
  ),
];


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              darkMode ? Color(0xFF2E3A87) : Color(0xFF6C7FFF),  // Blue-ish
              darkMode ? Color(0xFF5E2E80) : Color(0xFFB666D2),  // Purple-ish
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
              Container(
              decoration: BoxDecoration(
              boxShadow: [
                  BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
            ],
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_downward_rounded,
              size: 40,
              color: Color(0xFF6C7FFF),
            ),
          ),
        ).animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms),
                  const SizedBox(height: 80),

                  Text(
                    'Welcome to FileFlash\nFile Saver',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      shadows: myShadow,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .moveY(begin: 20, duration: 600.ms),

                  const SizedBox(height: 80),

                  Text(
                    'A convenient tool to save videos or files.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .moveY(begin: 20, duration: 600.ms),

                  const SizedBox(height: 150),

                  ElevatedButton(
                    onPressed: () {
                      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FileDownloaderPage(),), (route) => false,);
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen(),), (route) => false,);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Color(0xFF6C7FFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .moveY(begin: 20, duration: 600.ms),

                  const SizedBox(height: 30),

                  Text(
                    'By tapping "Continue" you confirm that you\nagree with our privacy policy',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 900.ms),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}