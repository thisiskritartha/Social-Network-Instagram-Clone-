import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  late final String id;
  late final String bio;
  late final String email;
  late final String photoUrl;
  late final String username;
  late final String displayName;

  User({
    required this.id,
    required this.bio,
    required this.email,
    required this.photoUrl,
    required this.username,
    required this.displayName,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      bio: doc['bio'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      username: doc['username'],
      displayName: doc['displayName'],
    );
  }
}
