import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class IUserListStrategy {
  AsyncResult<UserList> getUsers();
}
