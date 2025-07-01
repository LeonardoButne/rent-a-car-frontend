class StoryItem {
  final String id;
  final String userName;
  final String userAvatar;
  final bool isViewed;
  final DateTime createdAt;

  StoryItem({
    required this.id,
    required this.userName,
    required this.userAvatar,
    this.isViewed = false,
    required this.createdAt,
  });
}
