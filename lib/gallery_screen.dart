import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'google_drive_service.dart';
import 'video_player_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String folderId;
  final String folderName;

  const GalleryScreen({required this.folderId, required this.folderName});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final GoogleDriveService service = GoogleDriveService(
    'AIzaSyDgHaHgA8C1GPbwsS2UKTL1TVVtbDLwE9U',
  );

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
        pageToken: loadMore ? nextPageToken : null,
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: media.length,
                      itemBuilder: (context, index) {
                        final file = media[index];
                        final isVideo = file['mimeType']!.startsWith('video/');
                        return GestureDetector(
                          onTap: () {
                            if (isVideo) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => VideoPlayerScreen(
                                        videoUrl: file['url']!,
                                      ),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => Dialog(
                                      child: CachedNetworkImage(
                                        imageUrl: file['url']!,
                                        fit: BoxFit.contain,
                                        placeholder:
                                            (context, url) => Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                      ),
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
                                      imageUrl: file['thumbnail']!,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                              Icon(Icons.image),
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
    );
  }
}
