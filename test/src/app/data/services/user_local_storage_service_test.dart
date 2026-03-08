import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/services/user_local_storage_service.dart';
import 'package:post_app/src/app/domain/entities/user/address.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/shared/backend/local_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late UserLocalStorageService storage;

  setUp(
    () {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      storage = UserLocalStorageService();
    },
  );

  tearDown(() async {
    Future.delayed(const Duration(milliseconds: 100));

    await databaseFactory.deleteDatabase(LocalStorage.LocalDb);
  });

  final userId = 2;

  test('saveData should save user locally.', () async {
    await storage.saveData(
      userId,
      User(
        id: userId,
        name: 'Júnior Olisi',
        username: 'junior_olisi',
        email: 'jr@email.com',
        phone: '5599999995544',
        website: 'mywebsite.com',
        profileImage: 'https://user.img.com',
        address: Address(
          street: 'Rua dos Alfeneiros',
          suite: '410',
          city: 'Little Whinging',
        ),
      ),
    );

    final database = await openDatabase(LocalStorage.LocalDb);

    final userResult = await database.rawQuery('''SELECT * FROM user WHERE id = ?''', [userId]);
    final addressResult = await database.rawQuery('''SELECT * FROM address WHERE id = ?''', [userId]);

    expect(userResult, isA<List>());
    expect(userResult.isNotEmpty, isTrue);
    expect(userResult.first, isA<Map>());

    expect(addressResult, isA<List>());
    expect(addressResult.isNotEmpty, isTrue);
    expect(addressResult.first, isA<Map>());
  });

  test('saveData should save user locally.', () async {
    await storage.saveData(
      userId,
      User(
        id: userId,
        name: 'Júnior Olisi',
        username: 'junior_olisi',
        email: 'jr@email.com',
        phone: '5599999995544',
        website: 'mywebsite.com',
        profileImage: 'https://user.img.com',
        address: Address(
          street: 'Rua dos Alfeneiros',
          suite: '410',
          city: 'Little Whinging',
        ),
      ),
    );

    final database = await openDatabase(LocalStorage.LocalDb);

    final userResult = await database.rawQuery('''SELECT * FROM user WHERE id = ?''', [userId]);
    final addressResult = await database.rawQuery('''SELECT * FROM address WHERE id = ?''', [userId]);

    expect(userResult, isA<List>());
    expect(userResult.isNotEmpty, isTrue);
    expect(userResult.first, isA<Map>());

    expect(addressResult, isA<List>());
    expect(addressResult.isNotEmpty, isTrue);
    expect(addressResult.first, isA<Map>());
  });

  group(
    'getData should',
    () {
      test('return null when no user is found.', () async {
        final noSavedUserId = Random(5).nextDouble().toInt();

        final result = await storage.getData(noSavedUserId);

        expect(result, isNull);
      });

      test('return an User bject when user is found.', () async {
        await storage.saveData(
          userId,
          User(
            id: userId,
            name: 'Júnior Olisi',
            username: 'junior_olisi',
            email: 'jr@email.com',
            phone: '5599999995544',
            website: 'mywebsite.com',
            profileImage: 'https://user.img.com',
            address: Address(
              street: 'Rua dos Alfeneiros',
              suite: '410',
              city: 'Little Whinging',
            ),
          ),
        );

        final result = await storage.getData(userId);

        expect(
          result,
          isA<User>()
              .having(
                (user) => user.id,
                'User id',
                2,
              )
              .having(
                (user) => user.profileImage,
                'User profile image',
                'https://user.img.com',
              ),
        );
      });
    },
  );

  group(
    'updateData should',
    () {
      test('throw StorageError when user id does not exist.', () async {
        final invalidId = Random(5).nextDouble().toInt();

        expect(
          () => storage.updateData(
            invalidId,
            User(
              id: invalidId,
              name: 'Updated Name',
              username: 'updated_username',
              email: 'updated@email.com',
              phone: '5599999995544',
              website: 'mywebsite.com',
              profileImage: 'https://updated.img.com',
              address: Address(
                street: 'New Street',
                suite: '200',
                city: 'New City',
              ),
            ),
          ),
          throwsA(isA<StorageError>()),
        );
      });

      group(
        'getAllData should',
        () {
          test('return empty list when no users are saved.', () async {
            final result = await storage.getAllData();

            expect(result, isA<List<User>>());
            expect(result, isEmpty);
          });

          test('return a list of all saved users.', () async {
            final user1Id = 1;
            final user2Id = 2;

            await storage.saveData(
              user1Id,
              User(
                id: user1Id,
                name: 'Júnior Olisi',
                username: 'junior_olisi',
                email: 'jr@email.com',
                phone: '5599999995544',
                website: 'mywebsite.com',
                profileImage: 'https://user.img.com',
                address: Address(
                  street: 'Rua dos Alfeneiros',
                  suite: '410',
                  city: 'Little Whinging',
                ),
              ),
            );

            await storage.saveData(
              user2Id,
              User(
                id: user2Id,
                name: 'Harry Potter',
                username: 'harry_potter',
                email: 'hp@email.com',
                phone: '5599999995545',
                website: 'harrywebsite.com',
                profileImage: 'https://hp.img.com',
                address: Address(
                  street: 'Privet Drive',
                  suite: '4',
                  city: 'Little Whinging',
                ),
              ),
            );

            final result = await storage.getAllData();

            expect(result, isA<List<User>>());
            expect(result, isNotEmpty);
            expect(result.length, equals(2));
            expect(
              result,
              containsAll([
                isA<User>().having((user) => user.id, 'User id', user1Id),
                isA<User>().having((user) => user.id, 'User id', user2Id),
              ]),
            );
          });
        },
      );

      test('update user data when valid id is provided.', () async {
        await storage.saveData(
          userId,
          User(
            id: userId,
            name: 'Júnior Olisi',
            username: 'junior_olisi',
            email: 'jr@email.com',
            phone: '5599999995544',
            website: 'mywebsite.com',
            profileImage: 'https://user.img.com',
            address: Address(
              street: 'Rua dos Alfeneiros',
              suite: '410',
              city: 'Little Whinging',
            ),
          ),
        );

        await storage.updateData(
          userId,
          User(
            id: userId,
            name: 'Updated Name',
            username: 'updated_username',
            email: 'updated@email.com',
            phone: '5599999995544',
            website: 'mywebsite.com',
            profileImage: 'https://updated.img.com',
            address: Address(
              street: 'New Street',
              suite: '200',
              city: 'New City',
            ),
          ),
        );

        final result = await storage.getData(userId);

        expect(
          result,
          isA<User>()
              .having(
                (user) => user.id,
                'User id',
                2,
              )
              .having(
                (user) => user.name,
                'User name',
                'Updated Name',
              )
              .having(
                (user) => user.profileImage,
                'User profile image',
                'https://updated.img.com',
              )
              .having(
                (user) => user.address?.street,
                'User address street',
                'New Street',
              ),
        );
      });
    },
  );

  group(
    'deleteData should',
    () {
      test('throw StorageError when user id does not exist.', () async {
        final invalidId = Random(5).nextDouble().toInt();

        expect(
          () => storage.deleteData(invalidId),
          throwsA(isA<StorageError>()),
        );
      });

      test('delete user data when valid id is provided.', () async {
        await storage.saveData(
          userId,
          User(
            id: userId,
            name: 'Júnior Olisi',
            username: 'junior_olisi',
            email: 'jr@email.com',
            phone: '5599999995544',
            website: 'mywebsite.com',
            profileImage: 'https://user.img.com',
            address: Address(
              street: 'Rua dos Alfeneiros',
              suite: '410',
              city: 'Little Whinging',
            ),
          ),
        );

        await storage.deleteData(userId);

        final result = await storage.getData(userId);

        expect(result, isNull);
      });
    },
  );
}
