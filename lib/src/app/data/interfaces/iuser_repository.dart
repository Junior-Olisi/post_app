import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class IUserRepository {
  AsyncResult<List<User>> getUsers();
  AsyncResult<User> mergeUserData(User user);
}
