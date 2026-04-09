import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/apis/api_service.dart';

class UploadMediaScreen extends StatefulWidget {
  final String binderPath;
  final String Uploader;
  const UploadMediaScreen({
    required this.binderPath,
    required this.Uploader,
    super.key,
  });

  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen> {
  XFile? _selectedFile;
  Uint8List? _imageBytes;
  bool _isUploading = false;
  String? _statusMessage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedFile = picked;
        _imageBytes = bytes;
        _statusMessage = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _statusMessage = null;
    });

    try {
      final uri = Uri.parse(
        '${ApiService.baseUrl}/upload/${widget.binderPath}/${widget.Uploader}',
      );
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        final bytes = await _selectedFile!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: _selectedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedFile!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _statusMessage = '✅ Upload successful!');
        Navigator.pop(context , true);
      } else {
        setState(
          () => _statusMessage = '❌ Upload failed (${response.statusCode})',
        );
      }
    } catch (e) {
      setState(() => _statusMessage = '❌ Error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Take a photo',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Choose from gallery',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _showPickerOptions,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: _selectedFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                            : Image.file(
                                File(_selectedFile!.path),
                                fit: BoxFit.contain,
                              ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap to select an image',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedFile != null)
              TextButton.icon(
                onPressed: _showPickerOptions,
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  'Change image',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),

            const Spacer(),

            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _statusMessage!.startsWith('✅')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),

            ElevatedButton.icon(
              onPressed: (_selectedFile == null || _isUploading)
                  ? null
                  : _uploadImage,
              icon: _isUploading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.cloud_upload_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              label: Text(_isUploading ? 'Uploading...' : 'Upload'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
