import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/strategies/user_list/iuser_list_strategy.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';
import 'package:result_dart/result_dart.dart';

class LocalUserListStrategy implements IUserListStrategy {
  LocalUserListStrategy(this._localStorage);

  final ILocalStorageService<User> _localStorage;

  @override
  AsyncResult<UserList> getUsers() async {
    try {
      final localUsersList = await _localStorage.getAllData();
      final userList = UserList(users: localUsersList, source: SourceType.cache);
      return Success(userList);
    } on StorageError catch (e) {
      return Failure(UserError(message: e.message));
    } on Exception catch (_) {
      return Failure(UserError(message: 'Erro desconhecido ao tentar obter dados locais.'));
    }
  }
}
