import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'activity_feed.dart';

final CollectionReference users = FirebaseFirestore.instance.collection('users');

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController= TextEditingController();
  Future<QuerySnapshot> searchResultUser;
  handleSearch(String value) {
    Future<QuerySnapshot> querySearchUser = users
        .where('displayName',isGreaterThanOrEqualTo: value)
        .get();

    setState(() {
      searchResultUser = querySearchUser;
      /*
      * Benefits of doing this
      * we can user that globally
      * */
    });
  }

  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search for a user...',
          filled: true,
          prefixIcon: Icon(Icons.account_box),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: (){
              searchController.clear();
            },
          )
        ),
        onFieldSubmitted: handleSearch,  // when we click or enter form will submit and it carry value
      ),
    );
  }

  Container buildNoContent(){
    final Orientation orientation = MediaQuery.of(context).orientation;  // What is rotation of the phone ? Portrait means vertical landscape means horizontal
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset('assets/images/search.svg',height: orientation == Orientation.portrait ? 300.0 : 200.0,),  //
            Text('Find Users',textAlign: TextAlign.center,style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 60.0
            ),)
          ],
        ),
      ),
    );
  }

  buildSearchResults(){
    return FutureBuilder(
        future: searchResultUser,
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          List<UserResult> searchResults = [];
          snapshot.data.docs.forEach((doc){
            Userr user = Userr.fromDocument(doc);
            UserResult searchResult= UserResult(user: user);
            searchResults.add(searchResult);
          });
          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultUser == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final Userr user;

  const UserResult({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.7),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id,currentUserId: a.id,user: a),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                backgroundColor: Colors.grey,
              ),
              title: Text(user.displayName,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              subtitle: Text(user.username,style: TextStyle(color: Colors.white),),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
