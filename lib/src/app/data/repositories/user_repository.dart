import 'package:dio/dio.dart';
import 'package:post_app/src/app/data/errors/application_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';
import 'package:post_app/src/app/shared/backend/api_parameters.dart';
import 'package:result_dart/result_dart.dart';

class UserRepository implements IUserRepository {
  UserRepository(this._dio, this._localStorage);

  final Dio _dio;
  final IlocalStorageService<User> _localStorage;

  @override
  AsyncResult<UserList> getUsers() async {
    try {
      final localUsersList = await _localStorage.getAllData();

      if (localUsersList.isNotEmpty) {
        final userList = UserList(users: localUsersList, source: SourceType.cache);
        return Success(userList);
      }

      final result = await _dio.get('${ApiParameters.jsonPlaceholderApiUrl}/users');
      final userMapsList = result.data as List;

      List<User> users = [];

      for (var map in userMapsList) {
        map = map as Map<String, dynamic>;

        users.add(User.fromJson(map));
      }

      final userList = UserList(users: users);

      return Success(userList);
    } on DioException catch (e) {
      return Failure(UserError(message: e.message ?? 'Erro ao buscar usuários'));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro desconhecido ao realizar requisição http.'));
    }
  }

  @override
  AsyncResult<User> mergeUserData(User user) async {
    try {
      final result = await _dio.get('${ApiParameters.randomUserApiUrl}/?seed=${user.id}&inc=picture&results=1');

      final response = result.data as Map<String, dynamic>;
      final resultsResponseField = response['results'] as List;
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
