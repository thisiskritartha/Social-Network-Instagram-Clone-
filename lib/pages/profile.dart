import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/post_tile.dart';
import 'package:social_network/widgets/progress.dart';
import '../widgets/header.dart';
import 'package:social_network/models/user.dart';
import '../widgets/post.dart';
import 'edit_profile.dart';

class Profile extends StatefulWidget {
  final String? profileId;
  const Profile({super.key, required this.profileId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser!.id;
  String postOrientation = 'grid';
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts =
          snapshot.docs.map((element) => Post.fromFactory(element)).toList();
    });
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }

  buildButton({required String text, required Function function}) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: () {
          function();
        },
        child: Container(
          width: 250.0,
          height: 30.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(currentUserId: currentUserId),
      ),
    );
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: 'Edit this profile', function: editProfile);
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: userRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data!);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildCountColumn('Posts', postCount),
                              buildCountColumn('Followers', 0),
                              buildCountColumn('Following', 0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildProfileButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Text(
                    user.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.bio,
                  ),
                ),
              ],
            ),
          );
        });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else {
      if (posts.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            const Text(
              'No Posts',
              style: TextStyle(
                fontSize: 40.0,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      } else if (postOrientation == 'grid') {
        List<GridTile> gridTile = [];
        for (var post in posts) {
          gridTile.add(GridTile(
            child: PostTile(post: post),
          ));
        }
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: gridTile,
        );
      } else if (postOrientation == 'list') {
        return Column(
          children: posts,
        );
      }
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePositionOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setPostOrientation('grid'),
          icon: Icon(
            Icons.grid_on,
            color: postOrientation == 'grid'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ),
        IconButton(
          onPressed: () => setPostOrientation('list'),
          icon: Icon(
            Icons.list,
            size: 26.0,
            color: postOrientation == 'list'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Profile'),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(),
          buildTogglePositionOrientation(),
          const Divider(height: 0.0),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
