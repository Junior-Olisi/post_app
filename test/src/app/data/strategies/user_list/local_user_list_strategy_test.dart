import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/strategies/user_list/local_user_list_strategy.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/source_type.dart';

import '../../../../../mocks/dependency_mocks.dart';
import '../../../../../mocks/user_mocks.dart';

void main() {
  late ILocalStorageService<User> storage;
  late LocalUserListStrategy strategy;

  setUp(() {
    storage = UserLocalStorageServiceMock();
    strategy = LocalUserListStrategy(storage);
  });

  group(
    'getUsers should',
    () {
      test('return a UserList with SourceType.cache when local data exists.', () async {
        when(() => storage.getAllData()).thenAnswer((_) async => [userMock]);

        final result = await strategy.getUsers();

        result.fold(
          (value) {
            expect(value, isA<UserList>());
            expect(value.users, hasLength(1));
            expect(value.source, SourceType.cache);
          },
          (failure) => expect(failure, isNull),
        );
      });

      test('return an empty UserList with SourceType.cache when no local data exists.', () async {
        when(() => storage.getAllData()).thenAnswer((_) async => []);

        final result = await strategy.getUsers();

        result.fold(
          (value) {
            expect(value, isA<UserList>());
            expect(value.users, isEmpty);
            expect(value.source, SourceType.cache);
          },
          (failure) => expect(failure, isNull),
        );
      });

      test('fail when a StorageError occurs.', () async {
        when(() => storage.getAllData()).thenThrow(
          StorageError(message: 'Erro ao acessar banco de dados.'),
        );

        final result = await strategy.getUsers();

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (e) => e.message,
              'Error message',
              'Erro ao acessar banco de dados.',
            ),
          ),
        );
      });

      test('fail when an unknown Exception occurs.', () async {
        when(() => storage.getAllData()).thenThrow(
          Exception('unexpected'),
        );

        final result = await strategy.getUsers();

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<UserError>().having(
              (e) => e.message,
              'Error message',
              'Erro desconhecido ao tentar obter dados locais.',
            ),
          ),
        );
      });
    },
  );
}
