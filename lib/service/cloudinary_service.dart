import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  String get _basicAuth => 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

  /// Fetch subfolders within a specific parent folder
  Future<Map<String, dynamic>> listSubfolders(String parentFolder) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/folders/$parentFolder');

    final response = await http.get(
      url,
      headers: {'Authorization': _basicAuth},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final folders = (json['folders'] as List)
          .map((f) => {'id': f['path'].toString(), 'name': f['name'].toString()})
          .toList();
      return {'items': folders};
    } else if (response.statusCode == 404) {
      return {'items': []};
    } else {
      throw Exception('Failed to load folders: ${response.body}');
    }
  }

  /// Fetch images and videos
  Future<Map<String, dynamic>> listMedia(String folderPath, {String? nextCursor}) async {
    final bodyParameters = {
      "expression": 'folder:"$folderPath" OR folder:"$folderPath/*"',
      "max_results": 20,
    };
    
    if (nextCursor != null && nextCursor.isNotEmpty) {
      bodyParameters["next_cursor"] = nextCursor;
    }

    final body = jsonEncode(bodyParameters);
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/resources/search');

    final response = await http.post(
      url,
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final files = (json['resources'] as List).map((f) {
        String secureUrl = f['secure_url'].toString();
        // Generate a thumbnail by injecting a Cloudinary transformation if the resource is an image or video
        String thumb = secureUrl;
        if (f['resource_type'] == 'video') {
            int lastDot = secureUrl.lastIndexOf('.');
            if (lastDot != -1) {
                thumb = secureUrl.substring(0, lastDot) + '.jpg';
            }
            thumb = thumb.replaceFirst('/upload/', '/upload/w_400,c_limit,q_auto,f_auto/');
        } else {
            thumb = secureUrl.replaceFirst('/upload/', '/upload/w_400,c_limit,q_auto,f_auto/');
        }

        return {
          'id': f['public_id'].toString(),
          'name': f['filename'].toString(),
          'mimeType': f['resource_type'].toString() == 'video' ? 'video/mp4' : 'image/jpeg',
          'thumbnail': thumb,
          'url': secureUrl,
        };
      }).toList();

      return {
        'items': files,
        'nextPageToken': json['next_cursor']?.toString() ?? '',
      };
    } else {
      throw Exception('Failed to load media: ${response.body}');
    }
  }

  /// Upload a file to a specific folder
  Future<bool> uploadMedia(String filePath, String folderPath) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folderPath
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
        return true;
    } else {
        print('Upload failed: ${response.reasonPhrase}');
        return false;
    }
  }
}
