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
}
