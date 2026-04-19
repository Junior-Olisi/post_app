import 'package:dio/io.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';

class DioMock extends Mock implements DioForNative {}

class UserLocalStorageServiceMock extends Mock implements ILocalStorageService<User> {}

class PostLocalStorageServiceMock extends Mock implements ILocalStorageService<Post> {}
