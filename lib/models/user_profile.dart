import 'user.dart';
import 'post.dart';
class UserProfile {
  final User user;
  final List<Post> posts;
  final int albumCount;
  UserProfile({
    required this.user,
    required this.posts,
    required this.albumCount,
  });
}