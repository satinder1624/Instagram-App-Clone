import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/activity_feed.dart';
import 'package:flutter_social_network/pages/create_account.dart';
import 'package:flutter_social_network/pages/profile.dart';
import 'package:flutter_social_network/pages/search.dart';
import 'package:flutter_social_network/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

final CollectionReference users = FirebaseFirestore.instance.collection('users');
final CollectionReference postRef = FirebaseFirestore.instance.collection('posts');
final CollectionReference commentsRef = FirebaseFirestore.instance.collection('comments');
final CollectionReference activityFeedRef = FirebaseFirestore.instance.collection('feed');
final CollectionReference followersRef = FirebaseFirestore.instance.collection('followers ');
final CollectionReference FollowingRef = FirebaseFirestore.instance.collection('following');
final DateTime timeStamp = DateTime.now();
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool authState  = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  PageController pageController;
  int index = 0;
  Userr currentUser;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      // initialPage: 2, this is when we want a specific page index to display first
    );
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account){
      handleSignIn(account);
    }, onError: (err){
      print("Any errors $err");
      }
    );  // if any errors

    // Re-authenticate when app re-opened automatically
    googleSignIn.signInSilently(suppressErrors: false)
        .then((account) => handleSignIn(account))
        .catchError((onError)=>print("Errors $onError"));
  }

  handleSignIn(GoogleSignInAccount account){
    if(account!=null){
      createUserFirebase();
      setState(() {
        authState = true;
      });
    }else{
      setState(() {
        authState = false;
      });
    }
  }

  createUserFirebase() async{
    // 1)=> check if user exits in users collection in database according to their id
    final GoogleSignInAccount userId = googleSignIn.currentUser;
    // Making a request from firebase to check that kind of user with that id exits?
    DocumentSnapshot documents = await users.doc(userId.id).get();
    // 2)=> if user not exits then take them to account page (set up their profile)
    if(!documents.exists){
      final username = await Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => CreateAccount()));

    // 3)=> get username from create account, use it to make new user document in users collection
    users.doc(userId.id).set({
      'id' :  userId.id,
      'username' : username,
      "photoUrl" : userId.photoUrl,
      "email" : userId.email,
      "displayName" : userId.displayName,
      "bio" : "",
      "timeStamp" : timeStamp
    });
      documents = await users.doc(userId.id).get();  // If user exits then update it after passing into model
    }
    currentUser = Userr.fromDocument(documents);
  }

  login() {
    googleSignIn.signIn();
  }

  logout(){
    googleSignIn.signOut();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int index){
    setState(() {
      this.index = index;
    });
  }

  onTap(int index){
    pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Scaffold authenticate(){
    return Scaffold(
      body: PageView(
        children: [
          // Timeline(),
          RaisedButton(onPressed: ()=>logout(),child: Text('Logout'),),
          ActivityFeed(currentUser : currentUser),
          Upload(currentUser : currentUser),
          Search(),
          Profile(profileId : currentUser?.id, currentUserId : currentUser?.id,currentUseer : currentUser),
        ],
        controller: pageController, // helps to jump from one page to another
        onPageChanged: onPageChanged,  // Grab the index of each page even after switching
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: index,
        activeColor: Colors.pinkAccent,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 35.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),

    );
    //return RaisedButton(onPressed: ()=>logout(),child: Text('Logout'),);
  }

  Scaffold unAuthenticate(){
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.teal,
                Colors.purple,
                Colors.pinkAccent,
              ]
            )
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Flutter Share',style: TextStyle(color: Colors.white,fontSize: 60.0,fontFamily: 'Signatra'),),
              SizedBox(height: 20.0,),
              GestureDetector(
                onTap: () => login(),
                child: Container(
                  width: 260.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/google_signin_button.png'),
                      fit: BoxFit.cover,
                    )
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return authState ? authenticate() :  unAuthenticate();
  }
}
