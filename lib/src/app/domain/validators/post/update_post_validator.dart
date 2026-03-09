import 'package:lucid_validation/lucid_validation.dart';
import 'package:post_app/src/app/data/dtos/post/update_post_dto.dart';

class UpdatePostValidator extends LucidValidator<UpdatePostDto> {
  UpdatePostValidator() {
    ruleFor((newPost) => newPost.title, key: 'title') //
        .notEmpty(message: 'O campo título não pode ser vazio')
        .maxLength(50, message: 'O título deve ter no máximo 50 caracteres');

    ruleFor((newPost) => newPost.body, key: 'body') //
        .notEmpty(message: 'O campo conteúdo não pode ser vazio')
        .maxLength(1000, message: 'O conteúdo deve ter no máximo 1000 caracteres');
  }
}
