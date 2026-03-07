import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/data/repositories/user_repository.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';

import '../../../../mocks/dependency_mocks.dart';
import '../../../../mocks/user_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(userMock);
    registerFallbackValue(0);
  });

  late Dio dio;
  late IUserRepository repository;
  late IlocalStorageService<User> storage;

  setUp(
    () {
      dio = DioMock();
      storage = UserLocalStorageServiceMock();
      when(() => storage.saveData(any(), any())).thenAnswer((_) async {});
      repository = UserRepository(dio, storage);
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

  group(
    'mergeUserData should',
    () {
      test(
        'fail when any http error occurs (returns a failure with UserError object).',
        () async {
          when(() => dio.get(any())).thenThrow(
            DioException(
              requestOptions: RequestOptions(),
              response: Response(
                requestOptions: RequestOptions(),
                statusCode: HttpStatus.badRequest,
              ),
              message: 'Requisição não finalizada.',
            ),
          );

          final result = await repository.mergeUserData(userMock);

          result.fold(
            (value) => expect(value, isNull),
            (failure) => expect(
              failure,
              isA<UserError>().having(
                (userError) => userError.message,
                'Http error message',
                'Requisição não finalizada.',
              ),
            ),
          );
        },
      );
      test(
        'fail when any unknow error occurs (also returns a failure with UserError object).',
        () async {
          when(() => dio.get(any())).thenAnswer(
            (_) async => Response(
              statusCode: HttpStatus.ok,
              data: randoUserMap,
              requestOptions: RequestOptions(),
            ),
          );

          when(() => storage.saveData(any(), any())).thenThrow(
            StorageError(
              message: 'Erro durante inserção no banco de dados.',
            ),
          );

          final result = await repository.mergeUserData(userMock);

          result.fold(
            (value) => expect(value, isNull),
            (failure) => expect(
              failure,
              isA<UserError>().having(
                (userError) => userError.message,
                'Storage error message',
                'Erro durante inserção no banco de dados.',
              ),
            ),
          );
        },
      );
      test(
        'fail when a storage erro occurs (returns a failure with UserError object as well).',
        () async {
          when(() => dio.get(any())).thenThrow(
            Exception('Erro desconhecido ao realizar operação com dados do usuário.'),
          );

          final result = await repository.mergeUserData(userMock);

          result.fold(
            (value) => expect(value, isNull),
            (failure) => expect(
              failure,
              isA<UserError>().having(
                (userError) => userError.message,
                'Exception error message',
                'Erro desconhecido ao realizar operação com dados do usuário.',
              ),
            ),
          );
        },
      );
      test(
        'return an user object successfully after http request and local storage operation succeeds',
        () async {
          when(() => dio.get(any())).thenAnswer(
            (_) async => Response(
              statusCode: HttpStatus.ok,
              data: randoUserMap,
              requestOptions: RequestOptions(),
            ),
          );

          when(() => storage.saveData(any(), any())).thenAnswer((_) async => Future.value());

          final result = await repository.mergeUserData(userMock);

          result.fold(
            (value) {
              expect(
                value,
                isA<User>().having(
                  (user) => user.id,
                  'User id',
                  6,
                ),
              );
            },
            (failure) => expect(failure, isNull),
          );
        },
      );
    },
  );
}
