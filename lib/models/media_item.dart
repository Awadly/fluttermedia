class MediaItem {
  final int id;
  final String fileUrl;
  int likes;
  bool isLiked;

  MediaItem({
    required this.id,
    required this.fileUrl,
    this.likes = 0,
    this.isLiked = false,
  });
}
