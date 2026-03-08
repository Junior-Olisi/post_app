import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class IPostRepository {
  AsyncResult<PostList> getUserPosts(int id);
  AsyncResult<Post> likePost(Post post);
}
