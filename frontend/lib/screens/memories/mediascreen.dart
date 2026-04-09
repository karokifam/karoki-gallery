import 'package:flutter/material.dart';
import 'package:frontend/apis/api_service.dart';
import 'package:frontend/helpers/imageviewers.dart';
import 'package:frontend/helpers/videoplayers.dart';
import 'package:frontend/screens/upload/uploadscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:frontend/themes/theme_controller.dart'; // Removed

class MediaScreen extends StatefulWidget {
  final String binderName;

  const MediaScreen({super.key, required this.binderName});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  List<dynamic> media = [];
  bool isLoading = true;
  String? _username; // Nullable until loaded

  @override
  void initState() {
    super.initState();
    loadMedia();
    _loadUsername();
  }

  // Async function to load username
  void _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username') ?? '';
    setState(() {
      _username = storedUsername;
    });
  }

  Future<void> loadMedia() async {
    try {
      final data = await ApiService.getMedia(widget.binderName);

      setState(() {
        media = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.binderName),
        backgroundColor: Theme.of(
          context,
        ).appBarTheme.backgroundColor, // Refactored
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: media.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final item = media[index];

                return GestureDetector(
                  onTap: () {
                    if (item['type'] == "image") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageViewer(url: item['url']),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(url: item['url']),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          item['url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Theme.of(context).colorScheme.error
                                    .withOpacity(
                                      0.2,
                                    ), // Themed error background
                                child: Icon(
                                  Icons.broken_image,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error, // Themed error icon
                                ),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Theme.of(
                                context,
                              ).cardColor, // Themed loading background
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.secondary,
                                  ), // Themed progress indicator
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (item['type'] == "video")
                        Center(
                          child: Icon(
                            Icons.play_circle,
                            size: 40,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary, // Themed play icon
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadMediaScreen(
                binderPath: widget.binderName,
                Uploader: _username ?? 'user',
              ),
            ),
          );

          if (result == true) {
            await loadMedia(); // 🔥 reload grid after upload
          }
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ), // Icon color
        backgroundColor: Theme.of(context).colorScheme.primary, // Refactored
        elevation: 75.0,
      ),
    );
  }
}
