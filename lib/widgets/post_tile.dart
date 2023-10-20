import 'package:flutter/material.dart';
import 'package:social_network/widgets/custom_image.dart';
import 'package:social_network/widgets/post.dart';

import '../pages/post_screen.dart';

class PostTile extends StatelessWidget {
  final Post? post;
  const PostTile({super.key, this.post});

  showPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostScreen(userId: post!.ownerId, postId: post!.postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post!.mediaUrl),
    );
  }
}
