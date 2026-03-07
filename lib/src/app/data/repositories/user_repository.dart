import 'package:dio/dio.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/shared/api/api_parameters.dart';
import 'package:result_dart/result_dart.dart';

class UserRepository implements IuserRepository {
  UserRepository(this._dio);

  final Dio _dio;

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
}
