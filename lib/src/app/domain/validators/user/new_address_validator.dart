import 'package:lucid_validation/lucid_validation.dart';
import 'package:post_app/src/app/data/dtos/user/new_address_dto.dart';

class NewAddressValidator extends LucidValidator<NewAddressDto> {
  NewAddressValidator() {
    ruleFor((address) => address.street, key: 'street') //
        .notEmpty(message: 'O campo rua não pode ser vazio');
    ruleFor((address) => address.suite, key: 'suite') //
        .notEmpty(message: 'N° inválido');
    ruleFor((address) => address.city, key: 'city') //
        .notEmpty(message: 'O campo cidade não pode ser vazio');
  }
}
