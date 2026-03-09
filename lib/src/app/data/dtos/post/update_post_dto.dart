class UpdatePostDto {
  String title;
  String body;

  UpdatePostDto({
    required this.title,
    required this.body,
  });

  factory UpdatePostDto.empty() => UpdatePostDto(title: '', body: '');

  Map<String, dynamic> toMap() => {
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
