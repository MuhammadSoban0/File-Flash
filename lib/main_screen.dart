import 'dart:convert';

import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:file_downloader/Settings/appearence_dialoge.dart';
import 'package:file_downloader/gallery_screen.dart';
import 'package:file_downloader/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // List of pages corresponding to each bottom navigation item
  final List<Widget> _pages = [
    FileDownloaderPage(),
    GalleryScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _animatedPage(_currentIndex),
      bottomNavigationBar: _buildFloatingBar(darkMode),
    );
  }
  Widget _animatedPage(int index) {
    return _pages[index]
        .animate(
      key: ValueKey(index), // Ensure the animation re-triggers on index change
    ).fadeIn(duration: 300.ms); // Add slide-from-right animation
  }
  Widget _buildFloatingBar(bool darkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CustomNavigationBar(
        scaleFactor: 0.4,
        iconSize: 25.0,
        selectedColor: darkMode ? Colors.white : Color(0xff0c18fb),
        strokeColor: darkMode ? Colors.white : Color(0x300c18fb),
        unSelectedColor: Colors.grey[600],
        backgroundColor: darkMode ? Colors.grey.shade300.withValues(alpha: 0.3) : Colors.white,
        borderRadius: Radius.circular(20.0),
        items: [
          CustomNavigationBarItem(
            icon: Icon(
                Iconsax.home
            ),
          ),
          CustomNavigationBarItem(
            icon: Icon(
                Iconsax.gallery
            ),
          ),

          CustomNavigationBarItem(
            icon: Icon(
                Iconsax.setting
            ),
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            showFloatingBottomSheet(context,darkMode);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        isFloating: true,
      ),
    );
  }
}
