import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'service/cloudinary_service.dart';
import 'video_player_screen.dart';
import 'image_viewer_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String folderId;
  final String folderName;

  const GalleryScreen({required this.folderId, required this.folderName});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final CloudinaryService service = CloudinaryService();

  List<Map<String, String>> media = [];
  bool loading = true;
  bool loadingMore = false;
  String? nextPageToken;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMedia();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !loadingMore &&
          nextPageToken != null &&
          nextPageToken!.isNotEmpty) {
        _loadMedia(loadMore: true);
      }
    });
  }

  Future<void> _loadMedia({bool loadMore = false}) async {
    setState(() {
      if (!loadMore)
        loading = true;
      else
        loadingMore = true;
    });

    try {
      var data = await service.listMedia(
        widget.folderId,
        nextCursor: loadMore ? nextPageToken : null,
      );

      setState(() {
        if (loadMore)
          media.addAll(data['items']);
        else
          media = data['items'];
        nextPageToken = data['nextPageToken'];
      });
    } catch (e) {
      print("Error loading media: $e");
    } finally {
      setState(() {
        loading = false;
        loadingMore = false;
      });
    }
  }

  Future<void> _uploadMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickMedia();

    if (file != null) {
      setState(() {
        loading = true;
      });

      bool success = await service.uploadMedia(file.path, widget.folderId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload successful!')),
        );
        nextPageToken = null;
        _loadMedia(); // reload
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed.')),
        );
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folderName)),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : media.isEmpty
              ? Center(child: Text('No media found'))
              : Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: media.length,
                      itemBuilder: (context, index) {
                        final file = media[index];
                        final isVideo = file['mimeType']!.startsWith('video/');

                        // Ensure raw file URL from Cloudinary API
                        final fileUrl = file['url']!;
                        final thumbnailUrl =
                            file['thumbnail'] ?? fileUrl; // fallback

                        return GestureDetector(
                          onTap: () {
                            if (isVideo) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          VideoPlayerScreen(videoUrl: fileUrl),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          ImageViewerScreen(imageUrl: fileUrl),
                                ),
                              );
                            }
                          },
                          child: Card(
                            elevation: 3,
                            child:
                                isVideo
                                    ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          color: Colors.black26,
                                          child: Icon(
                                            Icons.videocam,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                    : CachedNetworkImage(
                                      imageUrl: thumbnailUrl,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) {
                                        print('Failed to load image: $url\nError: $error');
                                        return Icon(Icons.error, color: Colors.red);
                                      },
                                    ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (loadingMore)
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadMedia,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
