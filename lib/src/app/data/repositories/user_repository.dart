import 'package:dio/dio.dart';
import 'package:post_app/src/app/data/errors/application_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/shared/backend/api_parameters.dart';
import 'package:result_dart/result_dart.dart';

class UserRepository implements IUserRepository {
  UserRepository(this._dio, this._localStorage);

  final Dio _dio;
  final IlocalStorageService<User> _localStorage;

  @override
  AsyncResult<List<User>> getUsers() async {
    try {
      final result = await _dio.get('${ApiParameters.jsonPlaceholderApiUrl}/users');
      final userMapsList = result.data as List<Map<String, dynamic>>;
      final users = userMapsList.map(User.fromJson).toList();
      return Success(users);
    } on DioException catch (e) {
      return Failure(UserError(message: e.message ?? ''));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro desconhecido ao realizar requisição http.'));
    }
  }

  @override
  AsyncResult<User> mergeUserData(User user) async {
    try {
      final result = await _dio.get('${ApiParameters.randomUserApiUrl}/?seed=${user.id}&inc=picture&results=1');

      final response = result.data as Map<String, dynamic>;
      final resultsResponseField = response['results'] as List<Map<String, dynamic>>;
      final userPictureMap = resultsResponseField.first['picture'];
      final userImageUrl = userPictureMap['large'];

      user = user.copyWith(profileImage: userImageUrl);
      await _localStorage.saveData(user.id, user);

      return Success(user);
    } on DioException catch (e) {
      return Failure(UserError(message: e.message ?? ''));
    } on ApplicationError catch (e) {
      return Failure(UserError(message: e.message));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro desconhecido ao realizar operação com dados do usuário.'));
    }
  }
}
