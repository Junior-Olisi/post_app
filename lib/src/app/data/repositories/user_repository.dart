import 'package:dio/dio.dart';
import 'package:post_app/src/app/data/dtos/user/new_user_dto.dart';
import 'package:post_app/src/app/data/errors/application_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/data/strategies/user_list/local_user_list_strategy.dart';
import 'package:post_app/src/app/data/strategies/user_list/remote_user_list_strategy.dart';
import 'package:post_app/src/app/data/strategies/user_list/user_list_context.dart';
import 'package:post_app/src/app/domain/entities/user/address.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/shared/backend/api_parameters.dart';
import 'package:result_dart/result_dart.dart';

class UserRepository implements IUserRepository {
  UserRepository(
    this._dio,
    this._localStorage,
    this._context,
  );

  final Dio _dio;
  final ILocalStorageService<User> _localStorage;
  final UserListContext _context;

  @override
  AsyncResult<UserList> getAllUsers(StrategyType strategyType) async {
    switch (strategyType) {
      case StrategyType.Local:
        _context.setStrategy(LocalUserListStrategy(_localStorage));
        return _context.execute();
      case StrategyType.Remote:
        _context.setStrategy(RemoteUserListStrategy(_dio, _localStorage));
        return _context.execute();
    }
  }

  @override
  AsyncResult<UserList> getRemoteUsers() async {
    _context.setStrategy(RemoteUserListStrategy(_dio, _localStorage));
    return _context.execute();
  }

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
      User selectedUser = usersList.where((user) => user.userType == UserType.selected).first;
      selectedUser = selectedUser.copyWith(userType: UserType.none);
      await _localStorage.updateData(selectedUser.id, selectedUser);

      return Success(primaryUser);
    } on ApplicationError catch (e) {
      return Failure(UserError(message: e.message));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro ao localizar usuário primário.'));
    }
  }

  @override
  AsyncResult<Unit> exitFromApplication() async {
    try {
      await _localStorage.deleteAllData();
      return Success.unit();
    } on ApplicationError catch (e) {
      return Failure(UserError(message: e.message));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro ao finalizar aplicação.'));
    }
  }
}
