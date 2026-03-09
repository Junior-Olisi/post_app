import 'dart:math';

import 'package:dio/dio.dart';
import 'package:post_app/src/app/data/dtos/post/new_post_dto.dart';
import 'package:post_app/src/app/data/dtos/post/update_post_dto.dart';
import 'package:post_app/src/app/data/errors/application_error.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/ipost_repository.dart';
import 'package:post_app/src/app/domain/entities/post/comment.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/shared/backend/api_parameters.dart';
import 'package:result_dart/result_dart.dart';

class PostRepository implements IPostRepository {
  PostRepository(this._dio, this._localStorage);

  final Dio _dio;
  final IlocalStorageService<Post> _localStorage;

  @override
  AsyncResult<PostList> getUserPosts(User user) async {
    try {
      if (user.userType == UserType.primary) {
        final localPostsList = await _localStorage.getAllData();

        if (localPostsList.isNotEmpty) {
          final userPosts = localPostsList.where((post) => !post.markAsExcluded).toList();
          final postList = PostList(posts: userPosts, source: SourceType.cache);
          return Success(postList);
        }

        return Failure(PostError(message: 'Erro ao buscar posts de usuário'));
      }

      final result = await _dio.get('${ApiParameters.jsonPlaceholderApiUrl}/users/${user.id}/posts');
      final postMapsList = result.data as List;

      List<Post> posts = [];

      for (var map in postMapsList) {
        map = map as Map<String, dynamic>;
        final post = Post.fromJson(map);
        posts.add(post);

        await _localStorage.saveData(post.id, post);
      }

      final postList = PostList(posts: posts);

      return Success(postList);
    } on DioException catch (e) {
      return Failure(PostError(message: e.message ?? 'Erro ao buscar posts'));
    } on Exception catch (_) {
      return Failure(PostError(message: 'Erro desconhecido ao realizar requisição http.'));
    }
  }

  @override
  AsyncResult<Post> likePost(Post post) async {
    try {
      Post? likedPost = await _localStorage.getData(post.id);

      if (likedPost == null) {
        likedPost = post.copyWith(hasUserLike: !post.hasUserLike);
        await _localStorage.saveData(likedPost.id, likedPost);
        return Success(likedPost);
      } else {
        final updatedPost = likedPost.copyWith(hasUserLike: !post.hasUserLike);
        await _localStorage.updateData(updatedPost.id, updatedPost);
        return Success(updatedPost);
      }
    } on ApplicationError catch (e) {
      return Failure(PostError(message: e.message));
    } on Exception catch (_) {
      return Failure(PostError(message: 'Erro desconhecido ao curtir o post.'));
    }
  }

  @override
  AsyncResult<Post> createPost(NewPostDto dto) async {
    try {
      await _dio.post(
        '${ApiParameters.jsonPlaceholderApiUrl}/posts',
        data: dto.toMap(),
      );

      int newPostId = Random().nextInt(500) + 110;

      final newPost = Post(
        userId: dto.userId,
        id: newPostId,
        title: dto.title,
        body: dto.body,
      );

      await _localStorage.saveData(newPost.id, newPost);
      final createdPost = await _localStorage.getData(newPostId);

      return Success(createdPost!);
    } on DioException catch (e) {
      return Failure(PostError(message: e.message ?? 'Erro ao salvar post.'));
    } on ApplicationError catch (e) {
      return Failure(PostError(message: e.message));
    } on Exception catch (_) {
      return Failure(PostError(message: 'Erro desconhecido ao criar novo post.'));
    }
  }

  @override
  AsyncResult<Post> updatePost(UpdatePostDto dto, Post post) async {
    try {
      await _dio.put(
        '${ApiParameters.jsonPlaceholderApiUrl}/posts/${post.id}',
        data: dto.toMap(),
      );

      post = post.copyWith(title: dto.title, body: dto.body);

      await _localStorage.updateData(post.id, post);

      return Success(post);
    } on DioException catch (e) {
      return Failure(PostError(message: e.message ?? 'Erro ao salvar post.'));
    } on ApplicationError catch (e) {
      return Failure(PostError(message: e.message));
    } on Exception catch (_) {
      return Failure(PostError(message: 'Erro desconhecido ao atualizar novo post.'));
    }
  }

  @override
  AsyncResult<Post> getPost(int id) async {
    try {
      final result = await _dio.get('${ApiParameters.jsonPlaceholderApiUrl}/posts/$id/comments');

      final postMap = result.data as Map<String, dynamic>;
      final post = Post.fromJson(postMap);
      return Success(post);
    } on DioException catch (e) {
      return Failure(PostError(message: e.message ?? 'Erro ao buscar post.'));
    } on Exception catch (_) {
      return Failure(PostError(message: 'Erro desconhecido ao buscar post.'));
    }
  }

  @override
  AsyncResult<int> deletePost(Post post) async {
    try {
      await _dio.delete('${ApiParameters.jsonPlaceholderApiUrl}/posts/${post.id}');

      post = post.copyWith(markAsExcluded: !post.markAsExcluded);

      await _localStorage.updateData(post.id, post);

      return Success(post.id);
    } on DioException catch (e) {
      return Failure(PostError(message: e.message ?? 'Erro ao remover post.'));
    } on ApplicationError catch (e) {
      return Failure(PostError(message: e.message));
    } on Exception catch (_) {
      return Failure(PostError(message: 'Erro desconhecido ao removernovo post.'));
    }
  }

  @override
  AsyncResult<List<Comment>> getPostComments(Post post) async {
    try {
      final response = await _dio.get('${ApiParameters.jsonPlaceholderApiUrl}/posts/${post.id}/comments');
      final commentMapsList = response.data as List;
      List<Comment> comments = [];

      for (var map in commentMapsList) {
        final comment = Comment.fromJson(map);

        comments.add(comment);
      }

      return Success(comments);
    } on DioException catch (e) {
      return Failure(PostError(message: e.message ?? 'Erro ao buscar comentários.'));
    } on Exception catch (_) {
      return Failure(PostError(message: 'Erro desconhecido ao buscar comentários.'));
    }
  }

  @override
  AsyncResult<List<Comment>> getUserComments(int userId) async {
    try {
      final response = await _dio.get('${ApiParameters.jsonPlaceholderApiUrl}/users/$userId/comments');
      final commentMapsList = response.data as List;
      List<Comment> comments = [];

      for (var map in commentMapsList) {
        final comment = Comment.fromJson(map);

        comments.add(comment);
      }

      return Success(comments);
    } on DioException catch (e) {
      return Failure(PostError(message: e.message ?? 'Erro ao buscar comentários.'));
    } on Exception catch (_) {
      return Failure(PostError(message: 'Erro desconhecido ao buscar comentários.'));
    }
  }
}
