import 'package:bitirme_flutter/services/post_services/post_model.dart';
import 'package:firebase_database/firebase_database.dart';



class PostsService {
  final FirebaseDatabase _database;
  late DatabaseReference _postsReference;

  PostsService(FirebaseDatabase database) : _database = database {
    _postsReference = _database.reference().child('posts');
  }

  Future<List<Posts>> getAllPosts() async {
    List<Posts> posts = [];

    final snapshot = await _postsReference.once();

    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> map = Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map<dynamic, dynamic>);

      map.forEach((key, value) {
        final post = Posts.fromMap(value as Map<String, dynamic>);
        post.id = key;
        posts.add(post);
      });
    }

    return posts;
  }

  Future<void> addPost(Posts post) async {
    final newPostReference = _postsReference.push();
    post.id = newPostReference.key;
    await newPostReference.set(post.toMap());
  }

  Future<void> updatePost(Posts post) async {
    await _postsReference.child(post.id!).update(post.toMap());
  }

  Future<void> deletePost(String postId) async {
    await _postsReference.child(postId).remove();
  }
}