import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/shared/backend/local_storage.dart';
import 'package:sqflite/sqflite.dart';

class PostLocalStorageService implements IlocalStorageService<Post> {
  late Database _databaseInstance;

  @override
  Future<void> saveData(int key, Post data) async {
    try {
      _databaseInstance = await openDatabase(
        LocalStorage.LocalDb,
        onOpen: (opennedDatabase) async {
          await opennedDatabase.execute(
            '''
              CREATE TABLE IF NOT EXISTS post(
                id INTEGER NOT NULL PRIMARY KEY,
                userId INTEGER NOT NULL,
                title TEXT NOT NULL,
                body TEXT NOT NULL,
                hasUserLike INTEGER NOT NULL DEFAULT 0
              );
            ''',
          );
        },
      );

      await _databaseInstance.transaction(
        (transaction) async {
          final resultRow = await transaction.rawQuery(
            ''' SELECT * FROM post WHERE id = ? ''',
            [key],
          );

          if (resultRow.isEmpty) {
            await transaction.rawInsert(
              '''
                INSERT INTO post(id, userId, title, body, hasUserLike)
                VALUES(?, ?, ?, ?, ?)
              ''',
              [data.id, data.userId, data.title, data.body, data.hasUserLike ? 1 : 0],
            );
          }
        },
      );
    } on Exception catch (e) {
      throw StorageError(message: 'Erro durante inserção de post no banco de dados.\n${e.toString()}');
    } finally {
      if (_databaseInstance.isOpen) {
        await _databaseInstance.close();
      }
    }
  }

  @override
  Future<Post?> getData(int key) async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);

      final tables = await _databaseInstance.rawQuery(''' SELECT name FROM sqlite_master WHERE type='table' AND name='post' ''');
      if (tables.isEmpty) return null;

      final resultRow = await _databaseInstance.rawQuery(
        ''' SELECT * FROM post WHERE id = ? ''',
        [key],
      );

      if (resultRow.isEmpty) {
        return null;
      }

      final row = Map<String, dynamic>.from(resultRow.first as Map<String, dynamic>);
      row['hasUserLike'] = (row['hasUserLike'] as int) == 1;
      final post = Post.fromJson(row);

      return post;
    } on Exception catch (e) {
      throw StorageError(message: 'Erro ao buscar post no banco de dados.\n${e.toString()}');
    } finally {
      if (_databaseInstance.isOpen) {
        await _databaseInstance.close();
      }
    }
  }

  @override
  Future<List<Post>> getAllData() async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);

      final tables = await _databaseInstance.rawQuery(''' SELECT name FROM sqlite_master WHERE type='table' AND name='post' ''');
      if (tables.isEmpty) return [];

      final resultRows = await _databaseInstance.rawQuery(
        ''' SELECT * FROM post ''',
      );

      if (resultRows.isEmpty) {
        return [];
      }

      List<Post> posts = [];

      for (var row in resultRows) {
        final rowData = Map<String, dynamic>.from(row as Map<String, dynamic>);
        rowData['hasUserLike'] = (rowData['hasUserLike'] as int) == 1;
        final post = Post.fromJson(rowData);
        posts.add(post);
      }

      return posts;
    } on Exception catch (e) {
      throw StorageError(message: 'Erro ao buscar posts no banco de dados.\n${e.toString()}');
    } finally {
      if (_databaseInstance.isOpen) {
        await _databaseInstance.close();
      }
    }
  }

  @override
  Future<Post?> updateData(int key, Post data) async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);

      final tables = await _databaseInstance.rawQuery(''' SELECT name FROM sqlite_master WHERE type='table' AND name='post' ''');
      if (tables.isEmpty) {
        throw StorageError(message: 'Tabela de post não existe.');
      }

      final resultRow = await _databaseInstance.rawQuery(
        ''' SELECT * FROM post WHERE id = ? ''',
        [key],
      );

      if (resultRow.isEmpty) {
        throw StorageError(message: 'Post com id $key não encontrado.');
      }

      await _databaseInstance.transaction(
        (transaction) async {
          await transaction.rawUpdate(
            '''
              UPDATE post SET
                userId = ?,
                title = ?,
                body = ?,
                hasUserLike = ?
              WHERE id = ?
            ''',
            [data.userId, data.title, data.body, data.hasUserLike ? 1 : 0, key],
          );
        },
      );

      final updatedPost = await getData(key);
      return updatedPost;
    } on StorageError {
      rethrow;
    } on Exception catch (e) {
      throw StorageError(message: 'Erro ao atualizar post no banco de dados.\n${e.toString()}');
    } finally {
      if (_databaseInstance.isOpen) {
        await _databaseInstance.close();
      }
    }
  }

  @override
  Future<void> deleteData(int key) async {
    try {
      _databaseInstance = await openDatabase(LocalStorage.LocalDb);

      final tables = await _databaseInstance.rawQuery(''' SELECT name FROM sqlite_master WHERE type='table' AND name='post' ''');
      if (tables.isEmpty) {
        throw StorageError(message: 'Tabela de post não existe.');
      }

      final resultRow = await _databaseInstance.rawQuery(
        ''' SELECT * FROM post WHERE id = ? ''',
        [key],
      );

      if (resultRow.isEmpty) {
        throw StorageError(message: 'Post com id $key não encontrado.');
      }

      await _databaseInstance.rawDelete(
        ''' DELETE FROM post WHERE id = ? ''',
        [key],
      );
    } on StorageError {
      rethrow;
    } on Exception catch (e) {
      throw StorageError(message: 'Erro ao deletar post no banco de dados.\n${e.toString()}');
    } finally {
      if (_databaseInstance.isOpen) {
        await _databaseInstance.close();
      }
    }
  }
}
