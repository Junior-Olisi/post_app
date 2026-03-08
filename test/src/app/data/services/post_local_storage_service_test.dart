import 'package:flutter_test/flutter_test.dart';
import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/services/post_local_storage_service.dart';
import 'package:post_app/src/app/shared/backend/local_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../mocks/post_mocks.dart';

void main() {
  late PostLocalStorageService service;

  setUp(
    () {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      service = PostLocalStorageService();
    },
  );

  tearDown(() async {
    await Future.delayed(const Duration(milliseconds: 100));

    await databaseFactory.deleteDatabase(LocalStorage.LocalDb);
  });

  group(
    'PostLocalStorageService saveData should',
    () {
      test('save post data successfully when valid post is provided.', () async {
        expect(
          () => service.saveData(1, postMock),
          returnsNormally,
        );
      });

      test('not throw exception when saving post with valid data.', () async {
        expect(
          () => service.saveData(1, postMock),
          returnsNormally,
        );
      });
    },
  );

  group(
    'PostLocalStorageService getData should',
    () {
      test('return a Post object when valid id is provided.', () async {
        await service.saveData(1, postMock);

        final result = await service.getData(1);

        expect(result, isNotNull);
        expect(result?.id, equals(postMock.id));
        expect(result?.userId, equals(postMock.userId));
        expect(result?.title, equals(postMock.title));
        expect(result?.body, equals(postMock.body));
      });

      test('return null when post with id does not exist.', () async {
        final result = await service.getData(999);

        expect(result, isNull);
      });
    },
  );

  group(
    'PostLocalStorageService updateData should',
    () {
      test('update post data successfully when valid id and post are provided.', () async {
        await service.saveData(2, postMockWithId2);

        final updatedPost = postMockWithId2.copyWith(title: 'Updated Title');

        final result = await service.updateData(2, updatedPost);

        expect(result, isNotNull);
        expect(result?.title, equals('Updated Title'));
      });

      test('throw StorageError when post with id does not exist.', () async {
        expect(
          () => service.updateData(999, postMock),
          throwsA(isA<StorageError>()),
        );
      });
    },
  );

  group(
    'PostLocalStorageService deleteData should',
    () {
      test('delete post data when valid id is provided.', () async {
        await service.saveData(1, postMock);

        await service.deleteData(1);

        final result = await service.getData(1);

        expect(result, isNull);
      });

      test('throw StorageError when post with id does not exist.', () async {
        expect(
          () => service.deleteData(999),
          throwsA(isA<StorageError>()),
        );
      });
    },
  );

  group(
    'PostLocalStorageService getAllData should',
    () {
      test('return a List<Post> of all saved posts.', () async {
        await service.saveData(1, postMock);
        await service.saveData(2, postMockWithId2);

        final result = await service.getAllData();

        expect(result, isNotEmpty);
        expect(result.length, equals(2));
      });

      test('return an empty list when no posts are saved.', () async {
        final result = await service.getAllData();

        expect(result, isEmpty);
      });
    },
  );
}
