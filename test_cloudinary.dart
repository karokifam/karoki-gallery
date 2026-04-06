import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/service/cloudinary_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final service = CloudinaryService();
  print('Fetching media from Cloudinary...');
  
  try {
    // Assuming you have 'karoki-gallery' or similar. We'll use listSubfolders first to find a valid folder
    final rootFolders = await service.listSubfolders('');
    print('Folders found: $rootFolders');
    
    // Attempt to search
    // We will just search everything to see what urls look like
    final data = await service.listMedia('Family Photos'); // Guessing folder name based on previous task
    print('Items found in Family Photos: ${data['items'].length}');
    
    if (data['items'].isEmpty) {
       final data2 = await service.listMedia('Uploads');
       print('Items found in Uploads: ${data2['items'].length}');
    }

    final items = data['items'].isNotEmpty ? data['items'] : [];
    
    if (items.isNotEmpty) {
      for(int i=0; i < items.length && i < 3; i++) {
        print('Item: ${items[i]['name']}');
        print('  Raw URL: ${items[i]['url']}');
        print('  Thumb URL: ${items[i]['thumbnail']}');
        
        // Test HTTP GET on thumb URL
        var request = await HttpClient().getUrl(Uri.parse(items[i]['thumbnail']));
        var response = await request.close();
        print('  Thumb HTTP Status: ${response.statusCode}');
      }
    } else {
      print('No media to test.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
