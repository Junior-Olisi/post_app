import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/data/dtos/user/new_user_dto.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/data/strategies/user_list/user_list_context.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';

class UserController extends StateNotifier<UserState> {
  UserController(this._repository)
    : super(
        UserState(
          isLoading: false,
          list: const UserList(users: []),
          currentUser: null,
          errorMessage: null,
        ),
      );

  final IUserRepository _repository;

  Future<UserList?> getAllUsers({StrategyType strategyType = StrategyType.Local}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getAllUsers(strategyType);

    result.fold(
      (usersList) {
        final detectedCurrentUser = _findCurrentUser(usersList.users);
        state = state.copyWith(
          isLoading: false,
          list: usersList,
          currentUser: detectedCurrentUser,
          errorMessage: null,
        );
      },
      (failure) {
        final error = failure as UserError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<User?> addUser(NewUserDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.addUser(dto);

    result.fold(
      (newUser) {
        final updatedUsers = [...state.list.users, newUser];
        state = state.copyWith(
          isLoading: false,
          list: state.list.copyWith(users: updatedUsers),
        );
      },
      (failure) {
        final error = failure as UserError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<User?> savePrimaryUser(User user) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.savePrimaryUser(user);

    result.fold(
      (primaryUser) {
        final updatedUsers = _replaceUser(state.list.users, primaryUser);
        state = state.copyWith(
          isLoading: false,
          list: state.list.copyWith(users: updatedUsers),
          currentUser: primaryUser,
        );
      },
      (failure) {
        final error = failure as UserError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<User?> selectSecondaryUserProfile(User user) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.selectSecondaryUserProfile(user);

    result.fold(
      (selectedUser) {
        final updatedUsers = _replaceUser(state.list.users, selectedUser);
        state = state.copyWith(
          isLoading: false,
          list: state.list.copyWith(users: updatedUsers),
          currentUser: selectedUser,
        );
      },
      (failure) {
        final error = failure as UserError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<User?> exitFromProfileSearch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.exitFromProfileSearch();

    result.fold(
      (primaryUser) {
        final updatedUsers = state.list.users
            .map(
              (user) => user.userType == UserType.selected ? user.copyWith(userType: UserType.none) : user,
            )
            .toList();

        state = state.copyWith(
          isLoading: false,
          list: state.list.copyWith(users: updatedUsers),
          currentUser: primaryUser,
        );
      },
      (failure) {
        final error = failure as UserError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.getOrNull();
  }

  Future<bool> exitFromApplication() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.exitFromApplication();

    result.fold(
      (_) {
        state = state.copyWith(
          isLoading: false,
          list: const UserList(users: []),
          currentUser: null,
          errorMessage: null,
        );
      },
      (failure) {
        final error = failure as UserError;
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );

    return result.isSuccess();
  }

  void setCurrentUser(User user) {
    state = state.copyWith(currentUser: user);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  List<User> _replaceUser(List<User> users, User replacement) {
    final index = users.indexWhere((user) => user.id == replacement.id);

    if (index == -1) {
      return [...users, replacement];
    }

    final updatedUsers = [...users];
    updatedUsers[index] = replacement;
    return updatedUsers;
  }

  User? _findCurrentUser(List<User> users) {
    try {
      return users.firstWhere((user) => user.userType == UserType.selected);
    } on StateError {
      try {
        return users.firstWhere((user) => user.userType == UserType.primary);
      } on StateError {
        return null;
      }
    }
  }
}

class UserState {
  final bool isLoading;
  final UserList list;
  final User? currentUser;
  final String? errorMessage;

  const UserState({
    required this.isLoading,
    required this.list,
    required this.currentUser,
    required this.errorMessage,
  });

  UserState copyWith({
    bool? isLoading,
    UserList? list,
    User? currentUser,
    bool clearCurrentUser = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      currentUser: clearCurrentUser ? null : currentUser ?? this.currentUser,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final userStateProvider = StateNotifierProvider<UserController, UserState>(
  (ref) {
    final repository = Modular.get<IUserRepository>();
    return UserController(repository);
  },
);
