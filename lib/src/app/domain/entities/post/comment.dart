import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required int id,
    required int postId,
    required String name,
    required String email,
    required String body,
    @Default('image_placeholder') String userImage,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> map) => _$CommentFromJson(map);
}
