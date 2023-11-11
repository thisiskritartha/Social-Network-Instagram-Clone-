import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/pages/profile.dart';
import 'package:social_network/widgets/progress.dart';
import '../models/user.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  Future<QuerySnapshot>? searchResultFuture;
  TextEditingController textEditingController = TextEditingController();

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where("displayName", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultFuture = users;
    });
  }

  clearSearch() {
    textEditingController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: "Search for the user...",
          filled: true,
          prefixIcon: const Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          SvgPicture.asset(
            "assets/images/search.svg",
            height: orientation == Orientation.portrait ? 300 : 190,
            color: Colors.deepPurple,
          ),
          const SizedBox(
            height: 15.0,
          ),
          Text(
            'Find Users',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.deepPurple[300],
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              fontSize: 60,
              letterSpacing: 1.8,
            ),
          )
        ],
      ),
    );
  }

  buildSearchResult() {
    return FutureBuilder(
        future: searchResultFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResults = [];
          for (var doc in snapshot.data!.docs) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(user);
            searchResults.add(searchResult);
          }

          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResultFuture == null ? buildNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  const UserResult(this.user, {super.key});

  showProfile(BuildContext context, {required String profileId}) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Profile(profileId: profileId)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const Divider(
            height: 2.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
