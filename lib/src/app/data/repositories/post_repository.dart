import 'package:dio/dio.dart';
import 'package:post_app/src/app/data/errors/application_error.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/ipost_repository.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';
import 'package:post_app/src/app/shared/backend/api_parameters.dart';
import 'package:result_dart/result_dart.dart';

class PostRepository implements IPostRepository {
  PostRepository(this._dio, this._localStorage);

  final Dio _dio;
  final IlocalStorageService<Post> _localStorage;

  @override
  AsyncResult<PostList> getUserPosts(int id) async {
    try {
      final localPostsList = await _localStorage.getAllData();

      if (localPostsList.isNotEmpty) {
        final postList = PostList(posts: localPostsList, source: SourceType.cache);
        return Success(postList);
      }

      final result = await _dio.get('${ApiParameters.jsonPlaceholderApiUrl}/users/$id/posts');
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
}
