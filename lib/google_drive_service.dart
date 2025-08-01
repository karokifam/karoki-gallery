import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  final String apiKey;
  GoogleDriveService(this.apiKey);

  /// Fetch subfolders
  Future<Map<String, dynamic>> listSubfolders(
    String folderId, {
    String? pageToken,
  }) async {
    final url = Uri.parse(
      'https://www.googleapis.com/drive/v3/files?q=\'$folderId\'+in+parents+and+mimeType+=+\'application/vnd.google-apps.folder\'+and+trashed=false&fields=nextPageToken,files(id,name)&pageSize=20&pageToken=${pageToken ?? ''}&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final files =
          (json['files'] as List)
              .map(
                (f) => {'id': f['id'].toString(), 'name': f['name'].toString()},
              )
              .toList();

      return {
        'items': files,
        'nextPageToken': (json['nextPageToken'] ?? '').toString(),
      };
    } else {
      throw Exception('Failed to load folders: ${response.body}');
    }
  }

  /// Fetch images and videos with thumbnails and HD URLs
  Future<Map<String, dynamic>> listMedia(
    String folderId, {
    String? pageToken,
  }) async {
    final url = Uri.parse(
      'https://www.googleapis.com/drive/v3/files?q=\'$folderId\'+in+parents+and+(mimeType+contains+\'image/\'+or+mimeType+contains+\'video/\')+and+trashed=false&fields=nextPageToken,files(id,name,mimeType,thumbnailLink)&pageSize=20&pageToken=${pageToken ?? ''}&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final files =
          (json['files'] as List).map((f) {
            String thumb = f['thumbnailLink'] ?? '';
            if (thumb.isNotEmpty) {
              thumb = thumb.replaceAll(RegExp(r'=s\d+$'), '=s1000'); // Make HD
            }
            return {
              'id': f['id'].toString(),
              'name': f['name'].toString(),
              'mimeType': f['mimeType'].toString(),
              'thumbnail':
                  thumb.isNotEmpty
                      ? thumb
                      : 'https://www.googleapis.com/drive/v3/files/${f['id']}?alt=media&key=$apiKey',
              'url':
                  'https://www.googleapis.com/drive/v3/files/${f['id']}?alt=media&key=$apiKey',
            };
          }).toList();

      return {
        'items': files,
        'nextPageToken': (json['nextPageToken'] ?? '').toString(),
      };
    } else {
      throw Exception('Failed to load media: ${response.body}');
    }
  }
}
