import 'package:post_app/src/app/data/dtos/user/new_user_dto.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class IUserRepository {
  AsyncResult<User> addUser(NewUserDto dto);
  AsyncResult<UserList> getUsers();
  AsyncResult<User> mergeUserData(User user);
  AsyncResult<User> savePrimaryUser(User user);
  AsyncResult<User> selectSecondaryUserProfile(User user);
  AsyncResult<User> exitFromProfileSearch();
}
