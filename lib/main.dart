import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MediaApp());
}

class MediaItem {
  final int id;
  final String fileUrl;
  int likes;
  bool isLiked; // Track whether the item is liked or not

  MediaItem({
    required this.id,
    required this.fileUrl,
    this.likes = 0,
    this.isLiked = false, // Initialize as not liked
  });
}

class MediaApp extends StatefulWidget {
  @override
  _MediaAppState createState() => _MediaAppState();
}

class _MediaAppState extends State<MediaApp> {
  List<MediaItem> media = [];
  final picker = ImagePicker();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchMedia();
  }

  Future<void> fetchMedia() async {
    try {
      final response =
          await http.get(Uri.parse("https://awadly.duckdns.org/api/media"));
      if (response.statusCode == 200) {
        List<dynamic> mediaData = jsonDecode(response.body);
        setState(() {
          media = mediaData.map((item) {
            return MediaItem(
              id: item['id'],
              fileUrl: item['file_url'],
              likes: item['likes'] ?? 0,
              isLiked: false,
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load media');
      }
    } catch (error) {
      print('Error fetching media: $error');
    }
  }

  Future<void> _toggleLike(int id, bool isLiked) async {
    final url = isLiked
        ? 'https://awadly.duckdns.org/api/media/$id/unlike'
        : 'https://awadly.duckdns.org/api/media/$id/like';

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          media = media.map((item) {
            if (item.id == id) {
              item.isLiked = !isLiked; // Toggle liked state
              item.likes += isLiked ? -1 : 1; // Adjust like count
            }
            return item;
          }).toList();
        });
      } else {
        throw Exception('Failed to update like status');
      }
    } catch (error) {
      print('Error toggling like: $error');
    }
  }

  Future<void> _uploadImage() async {
    // Step 1: Pick an image
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return; // If no image is selected, return
    }

    File imageFile = File(pickedFile.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Step 2: Get the MIME type of the selected image file dynamically
    final mimeType = lookupMimeType(imageFile.path);
    if (mimeType == null) {
      return;
    }
    // Step 3: Get pre-signed URL
    try {
      final response = await http.get(
        Uri.parse(
            "https://awadly.duckdns.org/api/media/preSignedURL?fileName=$fileName&fileType=$mimeType"),
        headers: {"Content-Type": "application/json"},
      );

      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final preSignedUrl = jsonDecode(response.body)['uploadURL'];
        final fileURL = jsonDecode(response.body)['fileURL'];
        final uploadResponse = await http.put(
          Uri.parse(preSignedUrl),
          body: imageFile.readAsBytesSync(),
          headers: {
            'Content-Type': mimeType,
          },
        );

        print('Response status code: ${uploadResponse.statusCode}');

        if (uploadResponse.statusCode == 200) {
          final newMedia = {
            "title": "Mobile App",
            "description": "Uploaded from mobile app",
            "file_url": fileURL,
            "type": mimeType.startsWith("image") ? "image" : "video",
          };

          final saveResponse = await http.post(
            Uri.parse("https://awadly.duckdns.org/api/media"),
            body: jsonEncode(newMedia),
            headers: {"Content-Type": "application/json"},
          );

          setState(() {
            media.add(
              MediaItem(
                id: jsonDecode(saveResponse.body)['id'],
                fileUrl: fileURL, // URL to the uploaded image
                likes: 0,
                isLiked: false,
              ),
            );
          });
        } else {
          throw Exception('Failed to upload image');
        }
      } else {
        throw Exception('Failed to get pre-signed URL');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Media App"),
          actions: [
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: _uploadImage, // Open the image picker when clicked
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: media.length,
          itemBuilder: (context, index) {
            final item = media[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Image.network(item.fileUrl, height: 150),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Likes: ${item.likes}"),
                      IconButton(
                        icon: Icon(
                          item.isLiked ? Icons.thumb_down : Icons.thumb_up,
                        ),
                        onPressed: () => _toggleLike(item.id, item.isLiked),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
