import 'package:post_app/src/app/data/dtos/user/new_address_dto.dart';

class NewUserDto {
  String name;
  String username;
  String email;
  String phone;
  String website;
  String profileImage;
  NewAddressDto address;

  NewUserDto({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.address,
    this.website = 'x',
  });

  factory NewUserDto.empty() => NewUserDto(
    name: '',
    username: '',
    email: '',
    phone: '',
    profileImage: '',
    address: NewAddressDto.empty(),
  );

  void setName(String? newValue) {
    name = newValue ?? '';
  }

  void setUsername(String? newValue) {
    username = newValue ?? '';
  }

  void setEmail(String? newValue) {
    email = newValue ?? '';
  }

  void setPhone(String? newValue) {
    phone = newValue ?? '';
  }

  void setProfileImage(String? newValue) {
    profileImage = newValue ?? '';
  }

  void setWebsite(String? newValue) {
    website = newValue ?? '';
  }

  void setStreet(String? newValue) {
    address.street = newValue ?? '';
  }

  void setSuite(String? newValue) {
    address.suite = newValue ?? '';
  }

  void setCity(String? newValue) {
    address.city = newValue ?? '';
  }
}
