import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/api_service.dart';
import '../widgets/media_card.dart';
import '../utils/theme_toggle.dart';

class MediaAppScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  MediaAppScreen({required this.isDarkMode, required this.onThemeToggle});

  @override
  _MediaAppScreenState createState() => _MediaAppScreenState();
}

class _MediaAppScreenState extends State<MediaAppScreen> {
  List<MediaItem> media = [];

  @override
  void initState() {
    super.initState();
    fetchMedia();
  }

  Future<void> fetchMedia() async {
    final fetchedMedia = await ApiService.fetchMedia();
    setState(() {
      media = fetchedMedia;
    });
  }

  Future<void> _toggleLike(int id, bool isLiked) async {
    final success = await ApiService.toggleLike(id, isLiked);
    if (success) {
      setState(() {
        media = media.map((item) {
          if (item.id == id) {
            item.isLiked = !isLiked;
            item.likes += isLiked ? -1 : 1;
          }
          return item;
        }).toList();
      });
    }
  }

  Future<void> _uploadImage() async {
    final newMedia = await ApiService.uploadImage();
    if (newMedia != null) {
      setState(() {
        media.add(newMedia);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Media App"),
        actions: [
          ThemeToggle(
            isDarkMode: widget.isDarkMode,
            onToggle: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _uploadImage,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: media.length,
        itemBuilder: (context, index) {
          return MediaCard(
            item: media[index],
            onLikeToggle: () =>
                _toggleLike(media[index].id, media[index].isLiked),
          );
        },
      ),
    );
  }
}
