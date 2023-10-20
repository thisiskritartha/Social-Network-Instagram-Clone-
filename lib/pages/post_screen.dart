import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/header.dart';
import 'package:social_network/widgets/post.dart';
import 'package:social_network/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;
  const PostScreen({super.key, required this.userId, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postRef.doc(userId).collection('userPosts').doc(postId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          Post post =
              Post.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
          return Scaffold(
            appBar: header(context, title: post.description),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          );
        });
  }
}
