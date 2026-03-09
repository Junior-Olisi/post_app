import 'package:lucid_validation/lucid_validation.dart';
import 'package:post_app/src/app/data/dtos/user/new_user_dto.dart';
import 'package:post_app/src/app/domain/validators/user/new_address_validator.dart';

class NewUserValidator extends LucidValidator<NewUserDto> {
  NewUserValidator() {
    final newAddressValidator = NewAddressValidator();

    ruleFor((user) => user.name, key: 'name') //
        .notEmpty(message: 'O campo nome não pode ser vazio.');
    ruleFor((user) => user.username, key: 'username') //
        .notEmpty(message: 'O campo apelido não pode ser vazio.');
    ruleFor((user) => user.email, key: 'email') //
        .notEmpty(message: 'O campo email não pode ser vazio.');
    ruleFor((user) => user.phone, key: 'phone') //
        .notEmpty(message: 'O campo telefone não pode ser vazio.');
    ruleFor((user) => user.address, key: 'address') //
        .setValidator(newAddressValidator);
  }
}
