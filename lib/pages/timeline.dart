import 'package:flutter/material.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/pages/search.dart';
import 'package:social_network/widgets/header.dart';
import 'package:social_network/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_network/widgets/progress.dart';
import '../models/user.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  const Timeline({super.key, required this.currentUser});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts = [];
  List<dynamic> followingList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser!.id)
        .collection('userFollowing')
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();

    List<Post> posts = snapshot.docs.map((e) => Post.fromDocument(e)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUserToFollow();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  buildUserToFollow() {
    return StreamBuilder(
        stream: usersRef
            .orderBy('timestamp', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> userResults = [];
          for (var doc in snapshot.data!.docs) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser?.id == user.id;
            final bool isFollowingUser = followingList.contains(user.id);

            if (isAuthUser || isFollowingUser) {
              continue;
            } else {
              UserResult userResult = UserResult(user);
              userResults.add(userResult);
            }
          }
          return Container(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        'User to Follow',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: userResults,
                )
              ],
            ),
          );
        });
  }

  //
  // getUserById() async {
  //   final String id = "O5zHKgw8SOfSZeVrnyLU";
  //   // usersRef!.doc(id).get().then((value) {
  //   //   print(value.data());
  //   final DocumentSnapshot docs = await usersRef!.doc(id).get();
  //   print(docs.data());
  //   // });
  // }
  //
  // createUser() {
  //   usersRef!.doc('sdfasdf').set({
  //     "username": "test_data",
  //     'isAdmin': false,
  //     'postsCount': 3,
  //   });
  // }
  //
  // updateUser() async {
  //   final DocumentSnapshot data =
  //       await usersRef!.doc('8iegbyWpIS6iL611cFlK').get();
  //   if (data.exists) {
  //     data.reference.update({
  //       "username": "updated_krit",
  //       'isAdmin': false,
  //       'postsCount': 22,
  //     });
  //   }
  // }
  //
  // deleteUser() async {
  //   final DocumentSnapshot data =
  //       await usersRef!.doc('8iegbyWpIS6iL611cFlK').get();
  //   if (data.exists) {
  //     data.reference.delete();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
