import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/data/repositories/user_repository.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';

import '../../../../mocks/dependency_mocks.dart';
import '../../../../mocks/user_mocks.dart';

void main() {
  late Dio dio;
  late IuserRepository repository;

  setUp(
    () {
      dio = DioMock();
      repository = UserRepository(dio);
    },
  );

  group(
    'getUsers should',
    () {
      test('fail when any http error occurs (returns a failure with UserError object).', () async {
        when(() => dio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: HttpStatus.notFound,
            ),
            message: 'Recurso não encontrado.',
          ),
        );

        final result = await repository.getUsers();

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (userError) => userError.message,
              'Http error message',
              'Recurso não encontrado.',
            ),
          ),
        );
      });

      test('fail when any unknow error occurs (also returns a failure with UserError object).', () async {
        when(() => dio.get(any())).thenThrow(
          Exception('Erro desconhecido ao realizar requisição http.'),
        );

        final result = await repository.getUsers();

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (userError) => userError.message,
              'Exception error message',
              'Erro desconhecido ao realizar requisição http.',
            ),
          ),
        );
      });

      test('fail when any unknow error occurs (also returns a failure with UserError object).', () async {
        when(() => dio.get(any())).thenThrow(
          Exception('Erro desconhecido ao realizar requisição http.'),
        );

        final result = await repository.getUsers();

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (userError) => userError.message,
              'Exception error message',
              'Erro desconhecido ao realizar requisição http.',
            ),
          ),
        );
      });

      test('return a List<User> successfully.', () async {
        when(() => dio.get(any())).thenAnswer(
          (_) async => Response(
            statusCode: HttpStatus.ok,
            data: userMapsList,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.getUsers();

        result.fold(
          (value) {
            expect(value, isA<List<User>>());
            expect(value, isNotEmpty);
          },
          (failure) => expect(failure, isNull),
        );
      });
    },
  );
}
