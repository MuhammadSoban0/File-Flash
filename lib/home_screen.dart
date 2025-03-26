import 'dart:convert';
import 'dart:io';
import 'package:file_downloader/gallery_screen.dart';
import 'package:file_downloader/main.dart';
import 'package:file_downloader/splash_screen.dart';
import 'package:file_downloader/theme_mood_selection.dart';
import 'package:file_downloader/video_player.dart';
import 'package:path/path.dart' as path;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileDownloaderPage extends StatefulWidget {
  const FileDownloaderPage({Key? key}) : super(key: key);

  @override
  State<FileDownloaderPage> createState() => _FileDownloaderPageState();
}

class _FileDownloaderPageState extends State<FileDownloaderPage> {
  bool lightSelected = false;
  bool isDarkMode = false;
  bool isSystemDefault = false;
  String selectedTheme = prefs.getString("selectedTheme") ?? "light";
  final TextEditingController _urlController = TextEditingController();
  List<DownloadItem> _downloadItems = [];
  final Dio _dio = Dio();
  bool _isDownloading = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedDownloads();
    _request(Permission.storage);
  }

  Future<bool> _request (Permission permission)async{
  AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;

  if(build.version.sdkInt >= 30){
    var re = await Permission.manageExternalStorage.request();
    if(re.isGranted){
        return true;
    }else{
      return false;
    }
  }else{
    if(await permission.isGranted){
      return true;
    }else{
      var result =  await permission.request();
      if(result.isGranted){
        return true;
      }else{
        return false;
      }
    }
  }
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

  Future<void> _saveDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> downloadsJson = _downloadItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('downloads', downloadsJson);
    } catch (e) {
      print('Error saving downloads: $e');
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.photos.request();
    } else if (Platform.isIOS) {
      await Permission.photos.request();
    }
  }

  void _addLink() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      if (Uri.tryParse(url)?.isAbsolute ?? false) {
        setState(() {
          _downloadItems.add(
            DownloadItem(
              url: url,
              fileName: _getFileNameFromUrl(url),
              status: DownloadStatus.pending,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
          _urlController.clear();
        });
        _saveDownloads();
      } else {
        _showSnackBar('Please enter a valid URL');
      }
    }
  }

  String _getFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  Future<void> _startDownload() async {
    if (_downloadItems.isEmpty) {
      _showSnackBar('Please add links to download');
      return;
    }

    if (_isDownloading) {
      _showSnackBar('Downloads are already in progress');
      return;
    }

    await _requestPermissions();

    setState(() {
      _isDownloading = true;
    });

    final pendingItems = _downloadItems
        .where((item) => item.status != DownloadStatus.completed)
        .toList();


    // Download all files simultaneously using Future.wait
    await Future.wait(
      pendingItems.map((item) => _downloadFile(item)),
    );

    setState(() {
      _isDownloading = false;
    });
  }
  Future<void> _downloadFile(DownloadItem item) async {
    final index = _downloadItems.indexWhere((element) => element.timestamp == item.timestamp);
    if (index == -1) return;

    setState(() {
      _downloadItems[index].status = DownloadStatus.downloading;
      _downloadItems[index].progress = 0;
    });

    await _saveDownloads();

    try {
      // Request permission to access external storage
      await _requestStoragePermission();

      // Clean the filename by removing query parameters
      final String originalFileName = item.fileName;
      String cleanedFileName = originalFileName.split('?').first;

      // If filename has no extension, determine it using HTTP headers
      if (path.extension(cleanedFileName).isEmpty) {
        final response = await Dio().head(item.url); // Fetch headers
        final contentType = response.headers.value('content-type');

        if (contentType != null) {
          if (contentType.startsWith('image/')) {
            cleanedFileName += '.${contentType.split('/')[1]}'; // Use correct image format
          } else if (contentType.startsWith('video/')) {
            cleanedFileName += '.mp4'; // Default to MP4 for videos
          }
        }
      }

      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$cleanedFileName';

      print('Downloading to: $tempFilePath');

      await _dio.download(
        item.url,
        tempFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadItems[index].progress = received / total;
            });
          }
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0',
            'Accept': '*/*',
          },
        ),
    );

      // Verify the file was downloaded successfully
      final File downloadedFile = File(tempFilePath);
      if (!await downloadedFile.exists()) {
        throw Exception('Downloaded file does not exist');
      }

      final fileSize = await downloadedFile.length();
      if (fileSize == 0) {
        throw Exception('Downloaded file is empty');
      }

      print('Successfully downloaded file: $cleanedFileName (${fileSize} bytes)');

      _downloadItems[index].filePath = tempFilePath;

      // Define file type extensions
      final List<String> imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.heic'];
      final List<String> videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.webm', '.m4v', '.3gp'];

      // Get the file extension
      final String fileExtension = path.extension(cleanedFileName).toLowerCase();

      // Check if it's an image or video
      final bool isImage = imageExtensions.contains(fileExtension);
      final bool isVideo = videoExtensions.contains(fileExtension);

      print('File type detection: $cleanedFileName (isImage=$isImage, isVideo=$isVideo)');

      // Save to gallery if it's a media file
      if (isImage) {
        try {
          final String guaranteedFilePath = '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await downloadedFile.copy(guaranteedFilePath);

          await Gal.putImage(guaranteedFilePath, album: album);
          print('Image saved to gallery successfully');

          setState(() {
            _downloadItems[index].savedToGallery = true;
          });

          await File(guaranteedFilePath).delete();
        } catch (e) {
          print('Failed to save image to gallery: $e');
          setState(() {
            _downloadItems[index].savedToGallery = false;
          });
        }
      } else if (isVideo) {
        try {
          final String guaranteedFilePath = '${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          await downloadedFile.copy(guaranteedFilePath);

          await Gal.putVideo(guaranteedFilePath, album: album);
          print('Video saved to gallery successfully');

          setState(() {
            _downloadItems[index].savedToGallery = true;
          });

          await File(guaranteedFilePath).delete();
        } catch (e) {
          print('Failed to save video to gallery: $e');
          setState(() {
            _downloadItems[index].savedToGallery = false;
          });
        }
      } else {
        print("Not a media file: $cleanedFileName");

        final downloadsDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        final finalFilePath = '${downloadsDir.path}/$cleanedFileName';

        await downloadedFile.copy(finalFilePath);
        setState(() {
          _downloadItems[index].filePath = finalFilePath;
          _downloadItems[index].savedToGallery = false;
        });
      }

      setState(() {
        _downloadItems[index].status = DownloadStatus.completed;
        _downloadItems[index].completedTimestamp = DateTime.now().millisecondsSinceEpoch;
      });

      await _saveDownloads();
    } catch (e) {
      print('Download error: $e');
      setState(() {
        _downloadItems[index].status = DownloadStatus.failed;
        _downloadItems[index].error = e.toString();
      });

      await _saveDownloads();
    } finally {
      final allFinished = _downloadItems.every((item) =>
      item.status == DownloadStatus.completed || item.status == DownloadStatus.failed);

      if (allFinished) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

// Request storage permissions
  Future<void> _requestStoragePermission() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }
  }
  void _retryDownload(DownloadItem item) {
    _downloadFile(item);
  }

  void _removeItem(DownloadItem item) {
    setState(() {
      _downloadItems.removeWhere((element) => element.timestamp == item.timestamp);
    });
    _saveDownloads();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  bool toAlbum = false;
  String? get album => toAlbum ? 'Flutter' : null;


  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title:  Text('File Flash',style: TextStyle(
            shadows: myShadow,
            color: Colors.white),)
            .animate()
            .fadeIn(duration: 600.ms)
            .then()
            .shimmer(duration: 1.seconds),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                darkMode ? Color(0xFF2E3A87) : Color(0xFF6C7FFF),  // Blue-ish
                darkMode ? Color(0xFF5E2E80) : Color(0xFFB666D2),  // Purple-ish
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
                  slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.grey[100],
                    elevation: 5, // Shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 12),
                      child: Column(
                        spacing: 5,
                        children: [
                        TextField(
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.black,
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: 'Paste link to download..',
                          hintStyle: TextStyle(color: Colors.black45),
                          filled: true,
                          fillColor: Colors.grey[300], // Light grey background
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none, // Remove default border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white), // Blue-ish border when focused
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                          const SizedBox(height: 10),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addLink,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero, // Remove default padding
                        backgroundColor: Colors.transparent, // Make background transparent
                        shadowColor: Colors.transparent, // Remove default shadow
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFA9A9A9),  // Dark Grey
                              Color(0xFFD3D3D3),// Dark Green
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: double.infinity,
                            minHeight: 50,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Add Link',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startDownload,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero, // Remove default padding
                        backgroundColor: Colors.transparent, // Make background transparent
                        shadowColor: Colors.transparent, // Remove default shadow
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF6FCF97),  // Light Green
                              Color(0xFF27AE60),  // Dark Green
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: double.infinity,
                            minHeight: 50,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Download',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
                  ),

                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: AnimatedOpacity(
                opacity: _downloadItems.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: _downloadItems.isNotEmpty
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloads (${_downloadItems.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      borderRadius: BorderRadius.circular(12),
                      style: TextStyle(color: Colors.black),
                      dropdownColor: Colors.white,
                      value: null,
                      hint: const Text('Filter'),
                      underline: Container(),
                      icon: const Icon(Icons.filter_list),
                      onChanged: (value) {
                        // Filter implementation
                        if (value == 'completed') {
                          setState(() {
                            _downloadItems.sort((a, b) =>
                            a.status == DownloadStatus.completed ? -1 : 1);
                          });
                        } else if (value == 'failed') {
                          setState(() {
                            _downloadItems.sort((a, b) =>
                            a.status == DownloadStatus.failed ? -1 : 1);
                          });
                        } else if (value == 'newest') {
                          setState(() {
                            _downloadItems.sort((a, b) =>
                                b.timestamp.compareTo(a.timestamp));
                          });
                        } else if (value == 'oldest') {
                          setState(() {
                            _downloadItems.sort((a, b) =>
                                a.timestamp.compareTo(b.timestamp));
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed First'),
                        ),
                        DropdownMenuItem(
                          value: 'failed',
                          child: Text('Failed First'),
                        ),
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Newest First'),
                        ),
                        DropdownMenuItem(
                          value: 'oldest',
                          child: Text('Oldest First'),
                        ),
                      ],
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final item = _downloadItems[index];
                return GestureDetector(
                  onTap: (){
                    _showMedia(context, item.filePath!);
                  },
                  child: DownloadItemTile(
                    item: item,
                    onRetry: () => _retryDownload(item),
                    onRemove: () => _removeItem(item),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                      .slideX(begin: 0.2, end: 0),
                );
              },
              childCount: _downloadItems.length,
            ),
          ),
          SliverToBoxAdapter(
            child: _downloadItems.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.download_rounded, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No downloads yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add URLs and start downloading files',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
                : const SizedBox(height: 80),
          ),
                  ],
                ),
    );
  }
  // void _showMedia(BuildContext context, String path) {
  //   if (path.endsWith('.mp4') || path.endsWith('.mov')) {
  //     // Show video player
  //     showDialog(
  //       context: context,
  //       builder: (context) => VideoDialog(videoPath: path),
  //     );
  //   } else if (path.endsWith('.jpg') || path.endsWith('.png')) {
  //     // Show image
  //     showDialog(
  //       context: context,
  //       builder: (context) => Dialog(
  //         child: Image.file(File(path)),
  //       ),
  //     );
  //   }
  // }
  void _showMedia(BuildContext context, String path) {
    if (path.endsWith('.mp4') || path.endsWith('.mov')) {
      // Show video player in full screen
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text("Video"),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Center(
              child: VideoDialog(videoPath: path),
            ),
          ),
        ),
      );
    } else if (path.endsWith('.jpg') || path.endsWith('.png')) {
      // Show image in full screen
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}



class DownloadItemTile extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  const DownloadItemTile({
    Key? key,
    required this.item,
    required this.onRetry,
    required this.onRemove,
  }) : super(key: key);

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        if (item.filePath != null && item.status == DownloadStatus.completed) {
          if (item.filePath!.endsWith('.mp4') || item.filePath!.endsWith('.mov')) {
            showDialog(
              context: context,
              builder: (context) => VideoDialog(videoPath: item.filePath!),
            );
          } else if (item.filePath!.endsWith('.jpg') || 
                     item.filePath!.endsWith('.jpeg') || 
                     item.filePath!.endsWith('.png')) {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: Image.file(File(item.filePath!)),
              ),
            );
          }
        }
      },
      child: Card(
        color: darkMode ? Colors.white : Colors.grey[100],
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.fileName,
                      style:  TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusIcon(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20,color: Colors.black,),
                    onPressed: onRemove,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Added: ${_formatDate(item.timestamp)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.url,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (item.status == DownloadStatus.downloading)
                LinearProgressIndicator(
                  value: item.progress,
                )
                    .animate()
                    .shimmer(duration: 2.seconds, color: Colors.white12),
              if (item.status == DownloadStatus.failed)
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Download failed',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('RETRY'),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .then()
                        .shake(duration: 1.seconds, curve: Curves.easeInOut),
                  ],
                ),
              if (item.status == DownloadStatus.completed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.savedToGallery
                                ? 'Saved to gallery'
                                : 'Download completed',
                            style: TextStyle(color: Colors.green[700], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    if (item.completedTimestamp != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Completed: ${_formatDate(item.completedTimestamp!)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ),
                ],
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatusIcon() {
    switch (item.status) {
      case DownloadStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
      case DownloadStatus.downloading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
      case DownloadStatus.completed:
        return Icon(
            item.savedToGallery ? Icons.photo_library : Icons.check_circle,
            color: Colors.green[700]
        )
            .animate()
            .scale(duration: 300.ms);
      case DownloadStatus.failed:
        return Icon(Icons.error, color: Colors.red[700])
            .animate()
            .shake(duration: 300.ms);
    }
  }
}

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
}

class DownloadItem {
  final String url;
  final String fileName;
  DownloadStatus status;
  double progress;
  String? error;
  String? filePath;
  bool savedToGallery;
  final int timestamp;  // When the item was added
  int? completedTimestamp;  // When the download completed

  DownloadItem({
    required this.url,
    required this.fileName,
    required this.status,
    required this.timestamp,
    this.progress = 0.0,
    this.error,
    this.filePath,
    this.savedToGallery = false,
    this.completedTimestamp,
  });

  // Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fileName': fileName,
      'status': status.index,
      'progress': progress,
      'error': error,
      'filePath': filePath,
      'savedToGallery': savedToGallery,
      'timestamp': timestamp,
      'completedTimestamp': completedTimestamp,
    };
  }

  // Create from JSON for persistence
  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      status: DownloadStatus.values[json['status'] as int],
      progress: json['progress'] as double,
      error: json['error'] as String?,
      filePath: json['filePath'] as String?,
      savedToGallery: json['savedToGallery'] as bool,
      timestamp: json['timestamp'] as int,
      completedTimestamp: json['completedTimestamp'] as int?,
    );
  }
}
