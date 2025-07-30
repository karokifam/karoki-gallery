
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'gallery_screen.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  // A map where key is folder path (e.g., "assets/memory_items/Family/")
  // and value is the thumbnail path (e.g., "assets/memory_items/Family/image1.jpg")
  Map<String, String?> _memories = {};

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Get all file paths under memory_items
    final allMemoryFiles = manifestMap.keys
        .where((String key) => key.startsWith('assets/memory_items/'));

    // Group files by their parent directory
    final Map<String, List<String>> folders = {};
    for (var file in allMemoryFiles) {
      // "assets/memory_items/Family/image.jpg" -> "assets/memory_items/Family/"
      var directory = '${file.substring(0, file.lastIndexOf('/'))}/';
      if (!folders.containsKey(directory)) {
        folders[directory] = [];
      }
      folders[directory]!.add(file);
    }
    
    // Find a thumbnail for each folder
    final Map<String, String?> memoriesData = {};
    folders.forEach((path, files) {
        // Find the first image file to use as a thumbnail
        final thumbnail = files.firstWhere(
            (file) => file.endsWith('.jpg') || file.endsWith('.jpeg') || file.endsWith('.png') || file.endsWith('.mp4'),
            orElse: () => '',
        );
        memoriesData[path] = thumbnail;
    });

    if (mounted) {
      setState(() {
        _memories = memoriesData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoryPaths = _memories.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
        centerTitle: true ,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: memoryPaths.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: memoryPaths.length,
              itemBuilder: (context, index) {
                final memoryPath = memoryPaths[index];
                final thumbnailPath = _memories[memoryPath];
                final memoryName = memoryPath.split('/')[2];
                final isVideo = thumbnailPath?.endsWith('.mp4') ?? false;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GalleryScreen(memoryPath: memoryPath),
                      ),
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (thumbnailPath != null)
                                Image.asset(
                                  isVideo ? 'assets/video_placeholder.png' : thumbnailPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              if (isVideo)
                                const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              if (thumbnailPath == null)
                                Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.photo_album,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            memoryName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

