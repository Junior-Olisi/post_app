import 'package:dio/dio.dart';
import 'package:post_app/src/app/data/dtos/user/new_user_dto.dart';
import 'package:post_app/src/app/data/errors/application_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/domain/entities/user/address.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/shared/backend/api_parameters.dart';
import 'package:result_dart/result_dart.dart';

class UserRepository implements IUserRepository {
  UserRepository(this._dio, this._localStorage);

  final Dio _dio;
  final IlocalStorageService<User> _localStorage;

  @override
  AsyncResult<User> addUser(NewUserDto dto) async {
    try {
      final usersList = await _localStorage.getAllData();
      int userCount = usersList.length + 10;
      final userId = userCount++;
      User newUser = User(
        id: userId,
        name: dto.name,
        username: dto.username,
        email: dto.email,
        phone: dto.phone,
        website: dto.website,
        address: Address(
          street: dto.address.street,
          suite: dto.address.suite,
          city: dto.address.city,
        ),
      );

      final result = await _dio.get('${ApiParameters.randomUserApiUrl}/?seed=$userId&inc=picture&results=1');
      final response = result.data as Map<String, dynamic>;
      final resultsResponseField = response['results'] as List;
      final userPictureMap = resultsResponseField.first['picture'];
      final userImageUrl = userPictureMap['large'];

      newUser = newUser.copyWith(profileImage: userImageUrl);

      await _localStorage.saveData(userId, newUser);

      return Success(newUser);
    } on ApplicationError catch (e) {
      return Failure(UserError(message: e.message));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro desconhecido ao criar usuário.'));
    }
  }

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

  @override
  AsyncResult<User> savePrimaryUser(User user) async {
    try {
      final primaryUser = user.copyWith(userType: UserType.primary);
      await _localStorage.updateData(primaryUser.id, primaryUser);
      return Success(primaryUser);
    } on ApplicationError catch (e) {
      return Failure(UserError(message: e.message));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro ao salvar usuário primário.'));
    }
  }

  @override
  AsyncResult<User> selectSecondaryUserProfile(User user) async {
    try {
      final selectedUser = user.copyWith(userType: UserType.selected);
      await _localStorage.updateData(selectedUser.id, selectedUser);
      return Success(selectedUser);
    } on ApplicationError catch (e) {
      return Failure(UserError(message: e.message));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro ao salvar usuário selecionado.'));
    }
  }

  @override
  AsyncResult<User> exitFromProfileSearch() async {
    try {
      final usersList = await _localStorage.getAllData();
      final primaryUser = usersList.where((user) => user.userType == UserType.primary).first;

      return Success(primaryUser);
    } on ApplicationError catch (e) {
      return Failure(UserError(message: e.message));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro ao localizar usuário primário.'));
    }
  }
}
