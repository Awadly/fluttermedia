import 'package:flutter/material.dart';
import '../models/media_item.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onLikeToggle;

  const MediaCard({
    required this.item,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                icon: Icon(item.isLiked ? Icons.thumb_down : Icons.thumb_up),
                onPressed: onLikeToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
