import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/data/dtos/post/new_post_dto.dart';
import 'package:post_app/src/app/data/dtos/post/update_post_dto.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/data/interfaces/ipost_repository.dart';
import 'package:post_app/src/app/domain/entities/post/comment.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';

class PostViewModel extends StateNotifier<PostState> {
  PostViewModel(this._repository)
    : super(
        const PostState(
          isLoading: false,
          userPosts: [],
          preferedPosts: [],
          postComments: [],
          userComments: [],
          errorMessage: null,
          lastSource: null,
        ),
      );

  final IPostRepository _repository;

  Future<PostList?> getUserPosts(User user) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getUserPosts(user);

    result.fold(
      (postList) {
        final postsWithOwner = postList.posts.map((post) => post.copyWith(postOwner: user)).toList();
        state = state.copyWith(
          isLoading: false,
          userPosts: postsWithOwner,
          lastSource: postList.source,
          errorMessage: null,
        );
      },
      (failure) {
        final error = failure as PostError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<Post?> likePost(Post post) async {
    final result = await _repository.likePost(post);

    result.fold(
      (likedPost) {
        final posts = [...state.userPosts];
        final index = posts.indexWhere((item) => item.id == likedPost.id);

        if (index != -1) {
          posts[index] = likedPost;
        } else {
          posts.add(likedPost);
        }

        final preferedPosts = [...state.preferedPosts]..removeWhere((item) => item.id == likedPost.id);

        if (likedPost.hasUserLike) {
          preferedPosts.add(likedPost);
        }

        state = state.copyWith(
          userPosts: posts,
          preferedPosts: preferedPosts,
          errorMessage: null,
        );
      },
      (failure) {
        final error = failure as PostError;
        state = state.copyWith(errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<Post?> createPost(NewPostDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createPost(dto);

    result.fold(
      (createdPost) {
        state = state.copyWith(
          isLoading: false,
          userPosts: [createdPost, ...state.userPosts],
          errorMessage: null,
        );
      },
      (failure) {
        final error = failure as PostError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<Post?> updatePost(UpdatePostDto dto, Post post) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updatePost(dto, post);

    result.fold(
      (updatedPost) {
        final posts = [...state.userPosts];
        final index = posts.indexWhere((item) => item.id == updatedPost.id);

        if (index != -1) {
          posts[index] = updatedPost;
        }

        state = state.copyWith(
          isLoading: false,
          userPosts: posts,
          errorMessage: null,
        );
      },
      (failure) {
        final error = failure as PostError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<int?> deletePost(Post post) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.deletePost(post);

    result.fold(
      (deletedPostId) {
        state = state.copyWith(
          isLoading: false,
          userPosts: state.userPosts.where((item) => item.id != deletedPostId).toList(),
          preferedPosts: state.preferedPosts.where((item) => item.id != deletedPostId).toList(),
          errorMessage: null,
        );
      },
      (failure) {
        final error = failure as PostError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<List<Comment>?> getPostComments(Post post) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getPostComments(post);

    result.fold(
      (comments) {
        state = state.copyWith(isLoading: false, postComments: comments, errorMessage: null);
      },
      (failure) {
        final error = failure as PostError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<List<Comment>?> getUserComments(User user) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getUserComments(user);

    result.fold(
      (comments) {
        state = state.copyWith(isLoading: false, userComments: comments, errorMessage: null);
      },
      (failure) {
        final error = failure as PostError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

class PostState {
  const PostState({
    required this.isLoading,
    required this.userPosts,
    required this.preferedPosts,
    required this.postComments,
    required this.userComments,
    required this.errorMessage,
    required this.lastSource,
  });

  final bool isLoading;
  final List<Post> userPosts;
  final List<Post> preferedPosts;
  final List<Comment> postComments;
  final List<Comment> userComments;
  final String? errorMessage;
  final SourceType? lastSource;

  PostState copyWith({
    bool? isLoading,
    List<Post>? userPosts,
    List<Post>? preferedPosts,
    List<Comment>? postComments,
    List<Comment>? userComments,
    String? errorMessage,
    bool clearErrorMessage = false,
    SourceType? lastSource,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      userPosts: userPosts ?? this.userPosts,
      preferedPosts: preferedPosts ?? this.preferedPosts,
      postComments: postComments ?? this.postComments,
      userComments: userComments ?? this.userComments,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      lastSource: lastSource ?? this.lastSource,
    );
  }
}

final postStateProvider = StateNotifierProvider<PostViewModel, PostState>((ref) {
  final repository = Modular.get<IPostRepository>();
  return PostViewModel(repository);
});
