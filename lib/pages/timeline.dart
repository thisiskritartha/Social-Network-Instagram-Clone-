import 'package:flutter/material.dart';
import 'package:social_network/widgets/header.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference? usersRef = FirebaseFirestore.instance.collection("users");

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    //createUser();
    //updateUser();
    //deleteUser();
    super.initState();
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
      body: Text('Timeline'),
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: usersRef!.snapshots(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData) {
      //       return circularProgress();
      //     }
      //     final List<Text> children =
      //         snapshot.data!.docs.map((e) => Text(e['username'])).toList();
      //     return ListView(
      //       children: children,
      //     );
      //   },
      // ),
    );
  }
}
