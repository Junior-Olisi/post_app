import 'package:flutter/widgets.dart';
import 'package:post_app/src/app/data/dtos/post/new_post_dto.dart';
import 'package:post_app/src/app/data/dtos/post/update_post_dto.dart';
import 'package:post_app/src/app/data/interfaces/ipost_repository.dart';
import 'package:post_app/src/app/domain/entities/post/comment.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class PostViewModel {
  PostViewModel(this._repository);

  final IPostRepository _repository;

  late ValueNotifier<List<Post>> userPostsList = ValueNotifier([]);
  late ValueNotifier<List<Post>> preferedPostsList = ValueNotifier([]);
  late ValueNotifier<List<Comment>> postCommentsList = ValueNotifier([]);

  late final getUserPostsCommand = Command1(_getUserPosts);
  late final likePostCommand = Command1(_likePost);
  late final createPostCommand = Command1(_createPost);
  late final updatePostCommand = Command2(_updatePost);
  late final deletePostCommand = Command1(_deletePost);
  late final getPostCommentsCommand = Command1(_getPostComments);

  AsyncResult<PostList> _getUserPosts(int id) {
    return _repository.getUserPosts(id);
  }

  AsyncResult<Post> _likePost(Post post) {
    return _repository.likePost(post);
  }

  AsyncResult<Post> _createPost(NewPostDto post) {
    return _repository.createPost(post);
  }

  AsyncResult<Post> _updatePost(UpdatePostDto dto, Post post) {
    return _repository.updatePost(dto, post);
  }

  AsyncResult<int> _deletePost(Post post) {
    return _repository.deletePost(post);
  }

  AsyncResult<List<Comment>> _getPostComments(Post post) {
    return _repository.getPostComments(post);
  }
}
