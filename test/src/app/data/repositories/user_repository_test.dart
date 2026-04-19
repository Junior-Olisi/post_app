import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/data/repositories/user_repository.dart';
import 'package:post_app/src/app/data/strategies/user_list/user_list_context.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../mocks/dependency_mocks.dart';
import '../../../../mocks/user_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(userMock);
    registerFallbackValue(0);
    registerFallbackValue(UserListStrategyMock());
  });

  late Dio dio;
  late IUserRepository repository;
  late ILocalStorageService<User> storage;
  late UserListContextMock context;

  setUp(
    () {
      dio = DioMock();
      storage = UserLocalStorageServiceMock();
      context = UserListContextMock();
      repository = UserRepository(dio, storage, context);

      when(() => storage.getAllData()).thenAnswer((_) async => []);
      when(() => storage.updateData(any(), any())).thenAnswer((_) async => userMock);
    },
  );

  group(
    'getAllUsers should',
    () {
      test('set LocalUserListStrategy and return result when strategyType is Local.', () async {
        when(() => context.setStrategy(any())).thenReturn(null);
        when(() => context.execute()).thenAnswer(
          (_) async => Success(UserList(users: [userMock], source: SourceType.cache)),
        );

        final result = await repository.getAllUsers(StrategyType.Local);

        verify(() => context.setStrategy(any())).called(1);
        verify(() => context.execute()).called(1);

        result.fold(
          (value) {
            expect(value, isA<UserList>());
            expect(value.users, isNotEmpty);
            expect(value.source, SourceType.cache);
          },
          (failure) => expect(failure, isNull),
        );
      });

      test('set RemoteUserListStrategy and return result when strategyType is Remote.', () async {
        when(() => context.setStrategy(any())).thenReturn(null);
        when(() => context.execute()).thenAnswer(
          (_) async => Success(UserList(users: [userMock])),
        );

        final result = await repository.getAllUsers(StrategyType.Remote);

        verify(() => context.setStrategy(any())).called(1);
        verify(() => context.execute()).called(1);

        result.fold(
          (value) {
            expect(value, isA<UserList>());
            expect(value.users, isNotEmpty);
          },
          (failure) => expect(failure, isNull),
        );
      });

      test('return failure when strategy execution fails.', () async {
        when(() => context.setStrategy(any())).thenReturn(null);
        when(() => context.execute()).thenAnswer(
          (_) async => Failure(UserError(message: 'Erro ao buscar usuários')),
        );

        final result = await repository.getAllUsers(StrategyType.Remote);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (error) => error.message,
              'Error message',
              'Erro ao buscar usuários',
            ),
          ),
        );
      });
    },
  );

  group(
    'savePrimaryUser should',
    () {
      test(
        'save user locally with userType set to primary',
        () async {
          when(() => storage.updateData(any(), any())).thenAnswer((_) async => userMock);

          final result = await repository.savePrimaryUser(userMock);

          result.fold(
            (value) {
              expect(
                value,
                isA<User>()
                    .having(
                      (user) => user.id,
                      'User id',
                      userMock.id,
                    )
                    .having(
                      (user) => user.userType.name,
                      'User type',
                      'primary',
                    ),
              );
            },
            (failure) => expect(failure, isNull),
          );
        },
      );

      test(
        'fail when storage error occurs (returns a failure with UserError object)',
        () async {
          when(() => storage.updateData(any(), any())).thenThrow(
            StorageError(
              message: 'Erro ao atualizar usuário no banco de dados.',
            ),
          );

          final result = await repository.savePrimaryUser(userMock);

          result.fold(
            (value) => expect(value, isNull),
            (failure) => expect(
              failure,
              isA<UserError>().having(
                (userError) => userError.message,
                'Storage error message',
                'Erro ao atualizar usuário no banco de dados.',
              ),
            ),
          );
        },
      );

      test(
        'fail when unknown error occurs (returns a failure with UserError object)',
        () async {
          when(() => storage.updateData(any(), any())).thenThrow(
            Exception('Erro desconhecido'),
          );

          final result = await repository.savePrimaryUser(userMock);

          result.fold(
            (value) => expect(value, isNull),
            (failure) => expect(
              failure,
              isA<UserError>().having(
                (userError) => userError.message,
                'Exception error message',
                'Erro ao salvar usuário primário.',
              ),
            ),
          );
        },
      );

      test(
        'call storage.updateData with correct parameters',
        () async {
          when(() => storage.updateData(any(), any())).thenAnswer((_) async => userMock);

          await repository.savePrimaryUser(userMock);

          verify(() => storage.updateData(userMock.id, any())).called(1);
        },
      );
    },
  );
}
