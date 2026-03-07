import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
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
}
