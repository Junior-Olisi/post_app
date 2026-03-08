import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/data/errors/storage/storage_error.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/ipost_repository.dart';
import 'package:post_app/src/app/data/repositories/post_repository.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';

import '../../../../mocks/dependency_mocks.dart';
import '../../../../mocks/post_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(postMock);
    registerFallbackValue(0);
  });

  late Dio dio;
  late IPostRepository repository;
  late IlocalStorageService<Post> storage;

  setUp(
    () {
      dio = DioMock();
      storage = PostLocalStorageServiceMock();
      when(() => storage.saveData(any(), any())).thenAnswer((_) async {});
      when(() => storage.getAllData()).thenAnswer((_) async => []);
      when(() => storage.getData(any())).thenAnswer((_) async => null);
      when(() => storage.updateData(any(), any())).thenAnswer((_) async => null);
      repository = PostRepository(dio, storage);
    },
  );

  group(
    'getUserPosts should',
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

        final result = await repository.getUserPosts(1);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<PostError>().having(
              (userError) => userError.message,
              'Http error message',
              equals('Recurso não encontrado.'),
            ),
          ),
        );
      });

      test('fail when any unknow error occurs (also returns a failure with UserError object).', () async {
        when(() => dio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: HttpStatus.internalServerError,
            ),
            message: 'Erro desconhecido ao realizar requisição http.',
          ),
        );

        final result = await repository.getUserPosts(1);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<PostError>().having(
              (userError) => userError.message,
              'Http error message',
              equals('Erro desconhecido ao realizar requisição http.'),
            ),
          ),
        );
      });

      test('fail when any unknow error occurs (duplicate scenario).', () async {
        when(() => dio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            message: 'Unknown error',
          ),
        );

        final result = await repository.getUserPosts(1);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<PostError>().having(
              (userError) => userError.message,
              'Http error message',
              equals('Unknown error'),
            ),
          ),
        );
      });

      test('return a PostList successfully.', () async {
        when(() => dio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: HttpStatus.ok,
            data: postMapsList,
          ),
        );

        final result = await repository.getUserPosts(1);

        result.fold(
          (success) => expect(
            success,
            isA<PostList>()
                .having((postList) => postList.posts, 'posts', isNotEmpty)
                .having(
                  (postList) => postList.posts.length,
                  'posts length',
                  equals(3),
                ),
          ),
          (failure) => expect(failure, isNull),
        );
      });
    },
  );

  group(
    'likePost should',
    () {
      test('save post locally with hasUserLike true when post does not exist in storage.', () async {
        when(() => storage.getData(any())).thenAnswer((_) async => null);
        when(() => storage.saveData(any(), any())).thenAnswer((_) async {});

        final result = await repository.likePost(postMock);

        result.fold(
          (success) {
            expect(success, isA<Post>());
            expect(success.hasUserLike, isTrue);
            verify(() => storage.getData(postMock.id)).called(1);
            verify(() => storage.saveData(any(), any())).called(1);
          },
          (failure) => expect(failure, isNull),
        );
      });

      test('update post locally with hasUserLike true when post exists in storage.', () async {
        when(() => storage.getData(any())).thenAnswer((_) async => postMock);
        when(() => storage.updateData(any(), any())).thenAnswer((_) async => null);

        final result = await repository.likePost(postMock);

        result.fold(
          (success) {
            expect(success, isA<Post>());
            expect(success.hasUserLike, isTrue);
            verify(() => storage.getData(postMock.id)).called(1);
            verify(() => storage.updateData(any(), any())).called(1);
          },
          (failure) => expect(failure, isNull),
        );
      });

      test('fail when storage save error occurs (returns a failure with PostError object).', () async {
        when(() => storage.getData(any())).thenAnswer((_) async => null);
        when(() => storage.saveData(any(), any())).thenThrow(StorageError(message: 'Erro ao salvar post localmente.'));

        final result = await repository.likePost(postMock);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<PostError>().having(
              (error) => error.message,
              'Storage error message',
              equals('Erro ao salvar post localmente.'),
            ),
          ),
        );
      });

      test('fail when storage update error occurs (returns a failure with PostError object).', () async {
        when(() => storage.getData(any())).thenAnswer((_) async => postMock);
        when(() => storage.updateData(any(), any())).thenThrow(StorageError(message: 'Erro ao atualizar post.'));

        final result = await repository.likePost(postMock);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<PostError>().having(
              (error) => error.message,
              'Storage error message',
              equals('Erro ao atualizar post.'),
            ),
          ),
        );
      });

      test('fail when unknown error occurs.', () async {
        when(() => storage.getData(any())).thenThrow(Exception('Erro desconhecido'));

        final result = await repository.likePost(postMock);

        result.fold(
          (value) => expect(value, isNull),
          (failure) => expect(
            failure,
            isA<PostError>().having(
              (error) => error.message,
              'Generic error message',
              equals('Erro desconhecido ao curtir o post.'),
            ),
          ),
        );
      });
    },
  );
}
