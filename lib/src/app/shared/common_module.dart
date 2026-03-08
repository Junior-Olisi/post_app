import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/services/post_local_storage_service.dart';
import 'package:post_app/src/app/data/services/user_local_storage_service.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';

class CommonModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addSingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          validateStatus: (status) => status != null && status < 500,
          contentType: 'application/json',
          headers: {
            'User-Agent': 'PostApp/1.0 (Flutter)',
            'Accept': 'application/json',
          },
        ),
      );
      return dio;
    });
    i.add<IlocalStorageService<User>>(UserLocalStorageService.new);
    i.add<IlocalStorageService<Post>>(PostLocalStorageService.new);
  }
}
