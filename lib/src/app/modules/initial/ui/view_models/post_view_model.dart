import 'package:flutter/widgets.dart';
import 'package:post_app/src/app/data/interfaces/ipost_repository.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class PostViewModel {
  PostViewModel(this._repository);

  final IPostRepository _repository;

  late ValueNotifier<List<Post>> userPostsList = ValueNotifier([]);
  late ValueNotifier<List<Post>> preferedPostsList = ValueNotifier([]);

  late final getUserPostsCommand = Command1(_getUserPosts);
  late final likePostCommand = Command1(_likePost);

  AsyncResult<PostList> _getUserPosts(int id) {
    return _repository.getUserPosts(id);
  }

  AsyncResult<Post> _likePost(Post post) {
    return _repository.likePost(post);
  }
}
