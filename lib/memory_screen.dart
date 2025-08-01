import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'google_drive_service.dart';
import 'gallery_screen.dart';

class MemoryScreen extends StatefulWidget {
  @override
  _MemoryScreenState createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final GoogleDriveService service = GoogleDriveService(
    'AIzaSyDgHaHgA8C1GPbwsS2UKTL1TVVtbDLwE9U',
  );
  final String rootFolderId = '1kwMYiDomZ7M1ADhYFolw3fAKEkWOJKNE';

  List<Map<String, String>> allFolders = [];
  List<Map<String, String>> visibleFolders = [];
  bool loading = true;
  bool loadingMore = false;
  int batchSize = 5;
  int currentIndex = 0;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchFolders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetch all folder metadata first (fast)
  Future<void> _fetchFolders() async {
    try {
      var data = await service.listSubfolders(rootFolderId);
      allFolders = List<Map<String, String>>.from(data['items']);
      await _loadNextBatch(); // Load first 5 immediately
    } catch (e) {
      print("Error fetching folders: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  /// Load next batch of folders (5 at a time) with thumbnails
  Future<void> _loadNextBatch() async {
    if (currentIndex >= allFolders.length) return;

    setState(() {
      loadingMore = true;
    });

    int endIndex =
        (currentIndex + batchSize < allFolders.length)
            ? currentIndex + batchSize
            : allFolders.length;

    List<Map<String, String>> newBatch = [];

    for (int i = currentIndex; i < endIndex; i++) {
      var folder = allFolders[i];
      try {
        var media = await service.listMedia(folder['id']!);
        folder['thumb'] =
            media['items'].isNotEmpty ? media['items'].first['thumbnail']! : '';
      } catch (e) {
        folder['thumb'] = '';
      }
      newBatch.add(folder);
    }

    setState(() {
      visibleFolders.addAll(newBatch);
      currentIndex = endIndex;
      loadingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !loadingMore &&
        currentIndex < allFolders.length) {
      _loadNextBatch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memories')),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : visibleFolders.isEmpty
              ? Center(child: Text('No folders found'))
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
                      itemCount: visibleFolders.length,
                      itemBuilder: (context, index) {
                        final folder = visibleFolders[index];
                        final thumb = folder['thumb'] ?? '';
                        return GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => GalleryScreen(
                                        folderId: folder['id']!,
                                        folderName: folder['name']!,
                                      ),
                                ),
                              ),
                          child: Card(
                            elevation: 4,
                            child: Column(
                              children: [
                                Expanded(
                                  child:
                                      thumb.isNotEmpty
                                          ? CachedNetworkImage(
                                            imageUrl: thumb,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                  Icons.folder,
                                                  size: 80,
                                                ),
                                          )
                                          : Icon(Icons.folder, size: 80),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    folder['name'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
