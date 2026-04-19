import 'package:post_app/src/app/data/strategies/user_list/iuser_list_strategy.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:result_dart/result_dart.dart';

class UserListContext {
  late IUserListStrategy strategy;

  void setStrategy(IUserListStrategy selectedUserListStrategy) => strategy = selectedUserListStrategy;

  AsyncResult<UserList> execute() => strategy.getUsers();
}

enum StrategyType { Local, Remote }
