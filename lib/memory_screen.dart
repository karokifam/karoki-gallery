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

  List<Map<String, String>> folders = [];
  bool loading = true;
  bool loadingMore = false;
  String? nextPageToken;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFolders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !loadingMore &&
          nextPageToken != null &&
          nextPageToken!.isNotEmpty) {
        _loadFolders(loadMore: true);
      }
    });
  }

  Future<void> _loadFolders({bool loadMore = false}) async {
    setState(() {
      if (!loadMore)
        loading = true;
      else
        loadingMore = true;
    });

    try {
      var data = await service.listSubfolders(
        rootFolderId,
        pageToken: loadMore ? nextPageToken : null,
      );

      // Fetch first thumbnail for each folder
      for (var f in data['items']) {
        var media = await service.listMedia(f['id']!);
        f['thumb'] =
            media['items'].isNotEmpty ? media['items'].first['thumbnail']! : '';
      }

      setState(() {
        if (loadMore)
          folders.addAll(data['items']);
        else
          folders = data['items'];
        nextPageToken = data['nextPageToken'];
      });
    } catch (e) {
      print("Error loading folders: $e");
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
      appBar: AppBar(
        title: Text('Memories'),
        centerTitle: true,
        ),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : folders.isEmpty
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
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
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
                                      folder['thumb']!.isNotEmpty
                                          ? CachedNetworkImage(
                                            imageUrl: folder['thumb']!,
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
                                    folder['name']!,
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
