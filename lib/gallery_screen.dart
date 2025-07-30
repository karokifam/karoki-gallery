
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'video_player_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String memoryPath;

  const GalleryScreen({super.key, required this.memoryPath});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> _mediaPaths = [];
  int _currentMediaCount = 0;
  final int _mediaPerLoad = 10;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final mediaPaths = manifestMap.keys
        .where((String key) => key.startsWith(widget.memoryPath))
        .where((String key) => !key.endsWith('/'))
        .toList();

    setState(() {
      _mediaPaths = mediaPaths;
      _currentMediaCount = _mediaPerLoad;
    });
  }

  void _loadMoreMedia() {
    setState(() {
      _currentMediaCount += _mediaPerLoad;
      if (_currentMediaCount > _mediaPaths.length) {
        _currentMediaCount = _mediaPaths.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memoryPath.split('/')[2]),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _currentMediaCount > _mediaPaths.length
                  ? _mediaPaths.length
                  : _currentMediaCount,
              itemBuilder: (context, index) {
                final mediaPath = _mediaPaths[index];
                final isVideo = mediaPath.endsWith('.mp4');

                return GestureDetector(
                  onTap: () {
                    if (isVideo) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoPlayerScreen(videoPath: mediaPath),
                        ),
                      );
                    }
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            isVideo ? 'assets/video_placeholder.png' : mediaPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (isVideo)
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_currentMediaCount < _mediaPaths.length)
            ElevatedButton(
              onPressed: _loadMoreMedia,
              child: const Text('Load More'),
            ),
        ],
      ),
    );
  }
}

