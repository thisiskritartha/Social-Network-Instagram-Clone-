import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/header.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  const Comments({
    super.key,
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
  });

  @override
  State<Comments> createState() => _CommentsState(this);
}

class _CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final Comments comments;
  _CommentsState(this.comments);

  buildComments() {
    return StreamBuilder(
      stream: commentRef
          .doc(comments.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        for (var doc in snapshot.data!.docs) {
          comments.add(Comment.fromDocument(doc));
        }
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentRef.doc(comments.postId).collection('comments').add({
      'username': currentUser!.username,
      'comment': commentController.text,
      'timestamp': dateTime,
      'avatarUrl': currentUser!.photoUrl,
      'userId': currentUser!.id,
    });

    bool isNotPostOwner = widget.postOwnerId != currentUser!.id;
    if (!isNotPostOwner) {
      activityFeedRef.doc(widget.postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': commentController.text,
        'username': currentUser!.username,
        'userId': currentUser!.id,
        'userProfileImg': currentUser!.photoUrl,
        'postId': widget.postId,
        'mediaUrl': widget.postMediaUrl,
        'timestamp': dateTime,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Comments'),
      body: Column(
        children: [
          Expanded(child: buildComments()),
          //Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Write a comment...',
              ),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide.none),
              ),
              child: const Text('Post'),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  const Comment(
      {required this.username,
      required this.userId,
      required this.avatarUrl,
      required this.comment,
      required this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          title: Text(comment),
          subtitle: Text(timeago.format(timestamp.toDate())),
        )
      ],
    );
  }
}
