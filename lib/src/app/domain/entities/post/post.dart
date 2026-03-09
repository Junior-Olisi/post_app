import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required int userId,
    required int id,
    required String title,
    required String body,
    @Default(false) bool markAsExcluded,
    User? postOwner,
    @Default(false) bool hasUserLike,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> map) => _$PostFromJson(map);
}
