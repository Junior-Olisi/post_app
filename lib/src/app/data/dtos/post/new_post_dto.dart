class NewPostDto {
  int userId;
  String title;
  String body;

  NewPostDto({
    required this.userId,
    required this.title,
    required this.body,
  });

  factory NewPostDto.empty() => NewPostDto(userId: 0, title: '', body: '');

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'body': body,
  };

  void setTitle(String? newTitle) {
    title = newTitle ?? '';
  }

  void setBody(String? newBody) {
    body = newBody ?? '';
  }
}
