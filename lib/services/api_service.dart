import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/media_item.dart';
import 'package:mime/mime.dart';

class ApiService {
  static final picker = ImagePicker();

  static Future<List<MediaItem>> fetchMedia() async {
    try {
      final response =
          await http.get(Uri.parse("https://awadly.duckdns.org/api/media"));
      if (response.statusCode == 200) {
        List<dynamic> mediaData = jsonDecode(response.body);
        return mediaData.map((item) {
          return MediaItem(
            id: item['id'],
            fileUrl: item['file_url'],
            likes: item['likes'] ?? 0,
          );
        }).toList();
      }
      throw Exception('Failed to load media');
    } catch (error) {
      print('Error fetching media: $error');
      return [];
    }
  }

  static Future<bool> toggleLike(int id, bool isLiked) async {
    final url = isLiked
        ? 'https://awadly.duckdns.org/api/media/$id/unlike'
        : 'https://awadly.duckdns.org/api/media/$id/like';

    try {
      final response = await http.post(Uri.parse(url));
      return response.statusCode == 200;
    } catch (error) {
      print('Error toggling like: $error');
      return false;
    }
  }

  static Future<MediaItem?> uploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    File imageFile = File(pickedFile.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final mimeType = lookupMimeType(imageFile.path);

    if (mimeType == null) return null;

    try {
      final response = await http.get(Uri.parse(
          "https://awadly.duckdns.org/api/media/preSignedURL?fileName=$fileName&fileType=$mimeType"));

      if (response.statusCode == 200) {
        final preSignedUrl = jsonDecode(response.body)['uploadURL'];
        final fileURL = jsonDecode(response.body)['fileURL'];

        final uploadResponse = await http.put(
          Uri.parse(preSignedUrl),
          body: imageFile.readAsBytesSync(),
          headers: {'Content-Type': mimeType},
        );

        if (uploadResponse.statusCode == 200) {
          final saveResponse = await http.post(
            Uri.parse("https://awadly.duckdns.org/api/media"),
            body: jsonEncode({
              "title": "Mobile App",
              "description": "Uploaded from mobile app",
              "file_url": fileURL,
              "type": mimeType.startsWith("image") ? "image" : "video",
            }),
            headers: {"Content-Type": "application/json"},
          );

          return MediaItem(
            id: jsonDecode(saveResponse.body)['id'],
            fileUrl: fileURL,
          );
        }
      }
      throw Exception('Failed to upload image');
    } catch (error) {
      print('Error uploading image: $error');
      return null;
    }
  }
}
