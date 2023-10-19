import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_network/pages/create_account.dart';
import 'package:social_network/pages/profile.dart';
import 'package:social_network/pages/search.dart';
import 'package:social_network/pages/upload.dart';
import '../models/user.dart';
import 'activity_feed.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef = FirebaseStorage.instance.ref();

final CollectionReference userRef =
    FirebaseFirestore.instance.collection('users');
final CollectionReference postRef =
    FirebaseFirestore.instance.collection('posts');
final CollectionReference commentRef =
    FirebaseFirestore.instance.collection('comments');
final CollectionReference activityFeedRef =
    FirebaseFirestore.instance.collection('feed');
final DateTime dateTime = DateTime.now();
User? currentUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    //Detects user signing in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error Signing in: $err');
    });

    //Re-authenticate the user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account!);
    }).catchError((err) {
      print('Error Signing in: $err');
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      createUserInFirestore(context);
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore(BuildContext context) async {
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.doc(user!.id).get();

    if (!doc.exists) {
      final username = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateAccount(),
          ));

      userRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "displayName": user.displayName,
        "email": user.email,
        "photoUrl": user.photoUrl,
        "bio": "",
        "timestamp": dateTime,
      });
      doc = await userRef.doc(user!.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutSine,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          //Timeline(),
          GestureDetector(
            onTap: logout,
            child: Center(
              child: Text('Logout'),
            ),
          ),
          ActivityFeed(),
          //Upload(currentUser: currentUser!),
          if (currentUser != null) Upload(currentUser: currentUser!),
          const Search(),
          Profile(profileId: currentUser?.id),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.whatshot,
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.notification_add_rounded,
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 40.0,
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
          ),
          BottomNavigationBarItem(
            icon: currentUser != null
                ? CircleAvatar(
                    radius: 16.0,
                    backgroundImage:
                        CachedNetworkImageProvider(currentUser!.photoUrl),
                  )
                : const Icon(
                    Icons.account_circle,
                  ),
          ),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FlutterChat',
              style: TextStyle(
                fontFamily: 'LuxuriousScript',
                fontSize: 100.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.3,
              ),
            ),
            GestureDetector(
              onTap: login(),
              child: Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width * 0.77,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50.0,
                      height: 45.0,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/sign_in_with_google.png',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Center(
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
