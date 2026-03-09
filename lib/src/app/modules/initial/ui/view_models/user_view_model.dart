import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class UserViewModel {
  UserViewModel(this._repository);

  final IUserRepository _repository;

  late List<User> usersList = [];
  late User currentUser;

  late final getAllUsersCommand = Command0(_getAllUsers);
  late final mergeUserDataCommand = Command1(_mergeUserData);
  late final savePrimaryUserCommand = Command1(_savePrimaryUser);
  late final selectSecondaryUserProfileCommand = Command1(_selectSecondaryUserProfile);

  AsyncResult<UserList> _getAllUsers() {
    return _repository.getUsers();
  }

  AsyncResult<User> _mergeUserData(User user) {
    return _repository.mergeUserData(user);
  }

  AsyncResult<User> _savePrimaryUser(User user) {
    return _repository.savePrimaryUser(user);
  }

  AsyncResult<User> _selectSecondaryUserProfile(User user) {
    return _repository.selectSecondaryUserProfile(user);
  }
}
