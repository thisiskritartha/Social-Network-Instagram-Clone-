import 'package:flutter/material.dart';
import 'package:social_network/widgets/custom_image.dart';
import 'package:social_network/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post? post;
  const PostTile({super.key, this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: cachedNetworkImage(post!.mediaUrl),
    );
  }
}
