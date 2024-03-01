class Posts {
  String? id;
  String? title;
  String? content;
  List<String>? comments;

  Posts({this.id, this.title, this.content, this.comments});

  Posts.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    content = map['content'];
    comments = List<String>.from(map['comments'] as List);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'comments': comments,
    };
  }
}