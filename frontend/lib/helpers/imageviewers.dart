import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/apis/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageViewer extends StatefulWidget {
  final String url;

  const ImageViewer({super.key, required this.url});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  String? _username;
  bool _loading = true;
  bool _deleting = false; // Flag to show deleting overlay

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username') ?? '';
    setState(() {
      _username = storedUsername;
      _loading = false;
    });
  }

  Future<void> _deleteImage() async {
    if (_username == null) return;

    setState(() => _deleting = true);

    try {
      final response = await ApiService().delete_memory(widget.url, _username);

      if (mounted) {
        Navigator.pop(context); // Close viewer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response)),
        );
        debugPrint("Delete image response: $response");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete image: $e")));
      }
      debugPrint("Error deleting image: $e");
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Viewer"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download
              debugPrint("Download image");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Download feature coming soon!")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _username == null || _deleting ? null : _deleteImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      widget.url,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text("Failed to load image"),
                        );
                      },
                    ),
                  ),
                ),
          if (_deleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
