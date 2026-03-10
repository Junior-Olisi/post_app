import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/domain/entities/user/address.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/shared/backend/local_storage.dart';
import 'package:sqflite/sqflite.dart';

class UserLocalStorageService implements IlocalStorageService<User> {
  late Database _databaseInstance;

  @override
  Future<void> saveData(int key, User data) async {
    try {
      _databaseInstance = await openDatabase(
        LocalStorage.LocalDb,
        onOpen: (opennedDatabase) async {
          await opennedDatabase.execute(
            '''
              CREATE TABLE IF NOT EXISTS user(
                id INTEGER NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                username TEXT NOT NULL,
                email TEXT NOT NULL,
                phone TEXT NOT NULL,
                website TEXT NOT NULL,
                profileImage TEXT NOT NULL,
                userType TEXT NOT NULL
              );
            ''',
          );

          await opennedDatabase.execute(
            '''
                CREATE TABLE IF NOT EXISTS address(
                    id INTEGER NOT NULL PRIMARY KEY,
                    street TEXT NOT NULL,
                    suite TEXT NOT NULL,
                    city TEXT NOT NULL
                );
            ''',
          );
        },
      );

      await _databaseInstance.transaction(
        (transaction) async {
          final resultRow = await transaction.rawQuery(
            '''
                SELECT * FROM user WHERE id = ?
            ''',
            [
              key,
            ],
          );

          if (resultRow.isNotEmpty) {
            return;
          }

          await transaction.rawInsert(
            '''
                INSERT INTO user(
                    id,
                    name,
                    username,
                    email,
                    phone,
                    website,
                    profileImage,
                    userType
                ) VALUES (?,?,?,?,?,?,?,?)
            ''',
            [
              data.id,
              data.name,
              data.username,
              data.email,
              data.phone,
              data.website,
              data.profileImage,
              data.userType.name,
            ],
          );
        },
      );

      await _databaseInstance.transaction(
        (transaction) async {
          await transaction.rawInsert(
            '''
                INSERT INTO address(
                    id,
                    street,
                    suite,
                    city
                ) VALUES (?,?,?,?)
            ''',
            [
              data.id,
              data.address!.street,
              data.address!.suite,
              data.address!.city,
            ],
          );
        },
      );
    } on DatabaseException catch (_) {
      throw StorageError(message: 'Erro durante inserção no banco de dados.');
    } finally {
      await _databaseInstance.close();
    }
  }

  @override
  Future<User?> getData(int key) async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);
      final tables = await _databaseInstance.rawQuery(''' SELECT name FROM sqlite_master WHERE type='table' AND name='user' ''');
      if (tables.isEmpty) return null;

      final userQuery = await _databaseInstance.rawQuery(''' SELECT * FROM user WHERE id = ? ''', [key]);

      if (userQuery.isEmpty) {
        return null;
      }

      final addressQuery = await _databaseInstance.rawQuery(''' SELECT * FROM address WHERE id = ? ''', [key]);

      final userMap = userQuery.first as Map<String, dynamic>;
      final addressMap = addressQuery.first as Map<String, dynamic>;
      final address = Address.fromJson(addressMap);
      User user = User.fromJson(userMap);
      user = user.copyWith(address: address);

      return user;
    } on DatabaseException catch (_) {
      throw StorageError(message: 'Erro durante consulta no banco de dados.');
    } finally {
      await _databaseInstance.close();
    }
  }

  @override
  Future<List<User>> getAllData() async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);

      final tables = await _databaseInstance.rawQuery(''' SELECT name FROM sqlite_master WHERE type='table' AND name='user' ''');
      if (tables.isEmpty) return [];

      final userQuery = await _databaseInstance.rawQuery(''' SELECT * FROM user ''');

      if (userQuery.isEmpty) {
        return [];
      }

      final addressQuery = await _databaseInstance.rawQuery(''' SELECT * FROM address ''');

      final users = <User>[];

      for (final userMap in userQuery) {
        final userId = userMap['id'] as int;
        final addressMap = addressQuery.firstWhere(
          (address) => address['id'] == userId,
          orElse: () => {},
        );

        final address = addressMap.isNotEmpty ? Address.fromJson(addressMap as Map<String, dynamic>) : null;
        User user = User.fromJson(userMap as Map<String, dynamic>);
        user = user.copyWith(address: address);
        users.add(user);
      }

      return users;
    } on DatabaseException catch (_) {
      throw StorageError(message: 'Erro durante consulta de todos os usuários no banco de dados.');
    } finally {
      await _databaseInstance.close();
    }
  }

  @override
  Future<User?> updateData(int key, User data) async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);

      final tables = await _databaseInstance.rawQuery(''' SELECT name FROM sqlite_master WHERE type='table' AND name='user' ''');
      if (tables.isEmpty) {
        throw StorageError(message: 'Tabela de usuário não existe.');
      }

      final userQuery = await _databaseInstance.rawQuery(''' SELECT * FROM user WHERE id = ? ''', [key]);

      if (userQuery.isEmpty) {
        throw StorageError(message: 'Usuário com id $key não encontrado.');
      }

      await _databaseInstance.transaction(
        (transaction) async {
          await transaction.rawUpdate(
            '''
              UPDATE user SET
                name = ?,
                username = ?,
                email = ?,
                phone = ?,
                website = ?,
                profileImage = ?,
                userType = ?
              WHERE id = ?
            ''',
            [
              data.name,
              data.username,
              data.email,
              data.phone,
              data.website,
              data.profileImage,
              data.userType.name,
              key,
            ],
          );
        },
      );

      await _databaseInstance.transaction(
        (transaction) async {
          await transaction.rawUpdate(
            '''
              UPDATE address SET
                street = ?,
                suite = ?,
                city = ?
              WHERE id = ?
            ''',
            [
              data.address?.street ?? 'default value for street',
              data.address?.suite ?? 'default value for suite',
              data.address?.city ?? 'default value for city',
              key,
            ],
          );
        },
      );

      final updatedUser = await getData(key);
      return updatedUser;
    } on DatabaseException catch (_) {
      throw StorageError(message: 'Erro durante atualização no banco de dados.');
    } finally {
      await _databaseInstance.close();
    }
  }

  @override
  Future<void> deleteData(int key) async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);

      final tables = await _databaseInstance.rawQuery(''' SELECT name FROM sqlite_master WHERE type='table' AND name='user' ''');
      if (tables.isEmpty) {
        throw StorageError(message: 'Tabela de usuário não existe.');
      }

      final userQuery = await _databaseInstance.rawQuery(''' SELECT * FROM user WHERE id = ? ''', [key]);

      if (userQuery.isEmpty) {
        throw StorageError(message: 'Usuário com id $key não encontrado.');
      }

      await _databaseInstance.transaction(
        (transaction) async {
          await transaction.rawDelete(
            '''DELETE FROM user WHERE id = ?''',
            [key],
          );
        },
      );

      await _databaseInstance.transaction(
        (transaction) async {
          await transaction.rawDelete(
            '''DELETE FROM address WHERE id = ?''',
            [key],
          );
        },
      );
    } on DatabaseException catch (_) {
      throw StorageError(message: 'Erro durante exclusão no banco de dados.');
    } finally {
      await _databaseInstance.close();
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);

      await _databaseInstance.rawQuery('DROP TABLE user');
      await _databaseInstance.rawQuery('DROP TABLE address');
      await _databaseInstance.rawQuery('DROP TABLE post');
    } on StorageError {
      rethrow;
    } on Exception catch (e) {
      throw StorageError(message: 'Erro ao remover banco de dados.\n${e.toString()}');
    } finally {
      if (_databaseInstance.isOpen) {
        await _databaseInstance.close();
      }
    }
  }
}
