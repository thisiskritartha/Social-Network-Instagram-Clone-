import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/widgets/custom_image.dart';
import 'package:social_network/widgets/progress.dart';
import '../models/user.dart';
import '../pages/home.dart';

class Post extends StatefulWidget {
  final String currentUserId = currentUser!.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount = 0;
  final dynamic likes;
  late bool isLiked;

  Post({
    super.key,
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
    required this.likes,
  });

  factory Post.fromFactory(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'] as Map<String, dynamic>,
    );
  }

  int getLikeCount() {
    if (likes == null) return 0;
    int count = 0;
    likes.forEach((String key, dynamic val) {
      if (val == true) count += 1;
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(this);
}

class _PostState extends State<Post> {
  final Post post;
  _PostState(this.post);

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.doc(post.ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data!);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () {
              // Handle username tap.
            },
            child: Text(
              user.username,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            post.location,
          ),
          trailing: IconButton(
            onPressed: () {
              // Handle more options tap.
            },
            icon: const Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  handleLikePost() {
    bool _isLiked = widget.likes[widget.currentUserId] == true;

    if (_isLiked) {
      postRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .update({'likes.${widget.currentUserId}': false});
      setState(() {
        widget.likeCount -= 1;
        widget.isLiked = false;
        widget.likes[widget.currentUserId] = false;
      });
    } else {
      postRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .update({'likes.${widget.currentUserId}': true});
      setState(() {
        widget.likeCount += 1;
        widget.isLiked = true;
        widget.likes[widget.currentUserId] = true;
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(widget.mediaUrl),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () {
                // Handle comment tap.
              },
              child: Icon(
                Icons.chat_bubble_outline_sharp,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                '${post.getLikeCount()} likes',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                post.username,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(post.description)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.isLiked = (widget.likes[widget.currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
