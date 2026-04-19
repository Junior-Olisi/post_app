import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/strategies/user_list/remote_user_list_strategy.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';

import '../../../../../mocks/dependency_mocks.dart';
import '../../../../../mocks/user_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(userMock);
    registerFallbackValue(0);
  });

  late Dio dio;
  late ILocalStorageService<User> storage;
  late RemoteUserListStrategy strategy;

  setUp(() {
    dio = DioMock();
    storage = UserLocalStorageServiceMock();
    strategy = RemoteUserListStrategy(dio, storage);
  });

  group(
    'getUsers should',
    () {
      test('return a UserList successfully when API calls succeed.', () async {
        var callCount = 0;
        when(() => dio.get(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return Response(
              statusCode: HttpStatus.ok,
              data: userMapsList,
              requestOptions: RequestOptions(),
            );
          } else {
            return Response(
              statusCode: HttpStatus.ok,
              data: randoUserMap,
              requestOptions: RequestOptions(),
            );
          }
        });

        when(() => storage.saveData(any(), any())).thenAnswer((_) async => Future.value());

        final result = await strategy.getUsers();

        result.fold(
          (value) {
            expect(value, isA<UserList>());
            expect(value.users, isNotEmpty);
          },
          (failure) => expect(failure, isNull),
        );
      });

      test('fail when a DioException occurs.', () async {
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

        final result = await strategy.getUsers();

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (e) => e.message,
              'Error message',
              'Recurso não encontrado.',
            ),
          ),
        );
      });

      test('fail when an unknown Exception occurs.', () async {
        when(() => dio.get(any())).thenThrow(
          Exception('Erro desconhecido ao realizar requisição http.'),
        );

        final result = await strategy.getUsers();

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (e) => e.message,
              'Error message',
              'Erro desconhecido ao realizar requisição http.',
            ),
          ),
        );
      });
    },
  );

  group(
    'mergeUserData should',
    () {
      test('return a User with profileImage after successful merge.', () async {
        when(() => dio.get(any())).thenAnswer(
          (_) async => Response(
            statusCode: HttpStatus.ok,
            data: randoUserMap,
            requestOptions: RequestOptions(),
          ),
        );

        when(() => storage.saveData(any(), any())).thenAnswer((_) async => Future.value());

        final result = await strategy.mergeUserData(userMock);

        result.fold(
          (value) {
            expect(value, isA<User>());
            expect(value.id, userMock.id);
            expect(value.profileImage, isNotNull);
          },
          (failure) => expect(failure, isNull),
        );

        verify(() => storage.saveData(userMock.id, any())).called(1);
      });

      test('fail when a DioException occurs.', () async {
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

        final result = await strategy.mergeUserData(userMock);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (e) => e.message,
              'Error message',
              'Requisição não finalizada.',
            ),
          ),
        );
      });

      test('fail when a StorageError occurs.', () async {
        when(() => dio.get(any())).thenAnswer(
          (_) async => Response(
            statusCode: HttpStatus.ok,
            data: randoUserMap,
            requestOptions: RequestOptions(),
          ),
        );

        when(() => storage.saveData(any(), any())).thenThrow(
          StorageError(message: 'Erro durante inserção no banco de dados.'),
        );

        final result = await strategy.mergeUserData(userMock);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (e) => e.message,
              'Error message',
              'Erro durante inserção no banco de dados.',
            ),
          ),
        );
      });

      test('fail when an unknown Exception occurs.', () async {
        when(() => dio.get(any())).thenThrow(
          Exception('Erro desconhecido ao realizar operação com dados do usuário.'),
        );

        final result = await strategy.mergeUserData(userMock);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (e) => e.message,
              'Error message',
              'Erro desconhecido ao realizar operação com dados do usuário.',
            ),
          ),
        );
      });
    },
  );
}
