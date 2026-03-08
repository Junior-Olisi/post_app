import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';

part 'user_list.freezed.dart';

@freezed
abstract class UserList with _$UserList {
  const factory UserList({
    required List<User> users,
    @Default(SourceType.external) source,
  }) = _UserList;
}
