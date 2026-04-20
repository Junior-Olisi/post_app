import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:post_app/src/app/data/dtos/user/new_user_dto.dart';
import 'package:post_app/src/app/domain/entities/user/address.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String username,
    required String email,
    required String phone,
    required String website,
    Address? address,
    String? profileImage,
    @Default(UserType.none) UserType userType,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> map) => _$UserFromJson(map);

  factory User.create(NewUserDto dto) {
    return User(
      id: dto.id,
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
  }
}
