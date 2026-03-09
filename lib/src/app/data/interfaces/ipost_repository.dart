import 'package:post_app/src/app/data/dtos/post/new_post_dto.dart';
import 'package:post_app/src/app/data/dtos/post/update_post_dto.dart';
import 'package:post_app/src/app/domain/entities/post/comment.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class IPostRepository {
  AsyncResult<PostList> getUserPosts(User user);
  AsyncResult<Post> likePost(Post post);
  AsyncResult<Post> createPost(NewPostDto dto);
  AsyncResult<Post> updatePost(UpdatePostDto dto, Post post);
  AsyncResult<Post> getPost(int id);
  AsyncResult<int> deletePost(Post post);
  AsyncResult<List<Comment>> getUserComments(User user);
  AsyncResult<List<Comment>> getPostComments(Post post);
}
