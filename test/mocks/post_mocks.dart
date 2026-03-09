import 'package:post_app/src/app/data/dtos/post/new_post_dto.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';

final postMapsList = <Map<String, dynamic>>[
  {
    'userId': 1,
    'id': 1,
    'title': 'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
    'body':
        'quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut et quasi\ncivitatem nulla quos voluptatum modi\neveniet voluptas vel quasi expedita et\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut et quasi\ncivitatem nulla quos voluptatum modi\neveniet voluptas vel quasi expedita et',
  },
  {
    'userId': 1,
    'id': 2,
    'title': 'qui est esse',
    'body':
        'est rerum tempore vitae\nsequi sint nihil reprehenderit dolor\nbeatae ea sequi ne quis delectus ut sed\nquia et suscipit\nsuscipit recusandae consequuntur expedita et cum',
  },
  {
    'userId': 2,
    'id': 3,
    'title': 'ea molestias quasi exercitationem repellat qui ipsa sit aut',
    'body': 'et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nV',
  },
];

final postMock = Post(
  userId: 1,
  id: 1,
  title: 'Test Post',
  body: 'This is a test post body',
);

final newPostMock = NewPostDto.empty();

final postMockWithId2 = Post(
  userId: 1,
  id: 2,
  title: 'Test Post 2',
  body: 'This is another test post body',
);
