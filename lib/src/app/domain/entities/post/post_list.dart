import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';

part 'post_list.freezed.dart';
part 'post_list.g.dart';

@freezed
abstract class PostList with _$PostList {
  const factory PostList({
    required List<Post> posts,
    @Default(SourceType.external) source,
  }) = _PostList;

  factory PostList.fromJson(Map<String, dynamic> map) => _$PostListFromJson(map);
}
