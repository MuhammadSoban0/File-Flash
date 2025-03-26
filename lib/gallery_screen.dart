import 'dart:convert';
import 'dart:io';
import 'package:file_downloader/Gallery/image_view.dart';
import 'package:file_downloader/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'video_player.dart';
import 'home_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool showImages = true;
  List<DownloadItem> _downloadItems = [];
  bool _isLoading = false;

  List<DownloadItem> get filteredItems {
    return _downloadItems.where((item) {
      if (item.status != DownloadStatus.completed || item.filePath == null) {
        return false;
      }
      final path = item.filePath!.toLowerCase();
      if (showImages) {
        return path.endsWith('.jpg') ||
            path.endsWith('.jpeg') ||
            path.endsWith('.png');
      } else {
        return path.endsWith('.mp4') || path.endsWith('.mov');
      }
    }).toList();
  }

  Future<void> _loadSavedDownloads() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadsJson = prefs.getStringList('downloads') ?? [];

      final List<DownloadItem> loadedItems = [];

      for (var itemJson in downloadsJson) {
        final Map<String, dynamic> data = jsonDecode(itemJson);
        loadedItems.add(DownloadItem.fromJson(data));
      }

      setState(() {
        _downloadItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved downloads: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedDownloads();
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showImages ? Icons.image_not_supported : Icons.videocam_off,
            size: 80,
            color: Colors.grey[400],
          ).animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            showImages ? 'No Images Found' : 'No Videos Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ).animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          Text(
            showImages
                ? 'Download some images to see them here'
                : 'Download some videos to see them here',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(showImages ? 'Images' : 'Videos',style:  TextStyle(
            shadows: myShadow,
            color: Colors.white),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                darkMode ? Color(0xFF2E3A87) : Color(0xFF6C7FFF),  // Blue-ish
                darkMode ? Color(0xFF5E2E80) : Color(0xFFB666D2),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showImages = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: showImages ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: showImages
                            ? [BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.image,
                              color: showImages ? Colors.blue : Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Images',
                            style: TextStyle(
                              color: showImages ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showImages = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !showImages ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !showImages
                            ? [BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.camera,
                              color: !showImages ? Colors.blue : Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Videos',
                            style: TextStyle(
                              color: !showImages ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: filteredItems.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                key: ValueKey<bool>(showImages),
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return GestureDetector(
                    onTap: () {
                      if (showImages) {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 600),
                            pageBuilder: (context, animation, secondaryAnimation) =>
                              ImageView(tag: index.toString(),path: item.filePath!,)
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 600),
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  VideoDialog(videoPath: item.filePath!)
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: index.toString(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(item.filePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: !showImages
                            ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 40,
                          ),
                        )
                            : null,
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: Duration(milliseconds: 100 * index))
                      .slideY(begin: 0.2, end: 0);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}