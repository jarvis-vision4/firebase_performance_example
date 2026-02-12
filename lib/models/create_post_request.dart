class CreatePostRequest {
  final String title;
  final String body;
  final int userId;
  CreatePostRequest({
    required this.title,
    required this.body,
    required this.userId,
  });
  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'userId': userId,
  };
}