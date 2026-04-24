import 'package:dio/dio.dart';
import 'package:post_app/src/app/data/errors/application_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/strategies/user_list/iuser_list_strategy.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/shared/external/api_parameters.dart';
import 'package:result_dart/result_dart.dart';

class RemoteUserListStrategy implements IUserListStrategy {
  const RemoteUserListStrategy(this._dio, this._localStorage);

  final Dio _dio;
  final ILocalStorageService<User> _localStorage;

  @override
  AsyncResult<UserList> getUsers() async {
    try {
      final result = await _dio.get('${ApiParameters.jsonPlaceholderApiUrl}/users');
      final userMapsList = result.data as List;

      List<User> users = [];

      for (var map in userMapsList) {
        map = map as Map<String, dynamic>;
        User user = User.fromJson(map);
        final mergeResult = await mergeUserData(user);

        mergeResult.fold((mergedUser) {
          users.add(mergedUser);
        }, (_) => null);
      }

      final userList = UserList(users: users);

      return Success(userList);
    } on DioException catch (e) {
      return Failure(UserError(message: e.message ?? 'Erro ao buscar usuários'));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro desconhecido ao realizar requisição http.'));
    }
  }

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
