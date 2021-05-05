import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/activity_feed.dart';
import 'package:flutter_social_network/pages/comments.dart';
import 'package:flutter_social_network/pages/edit_profile.dart';
import 'package:flutter_social_network/widgets/custom_image.dart';
import 'package:flutter_social_network/widgets/header.dart';
import 'package:flutter_social_network/widgets/post_tile.dart';
import 'package:flutter_social_network/widgets/progress.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:flutter/animation.dart';
import 'package:animator/animator.dart';

class Profile extends StatefulWidget {
  final String profileId;
  final String currentUserId;
  final Userr currentUseer;

  const Profile({Key key, this.profileId, this.currentUserId, this.currentUseer}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  String postId;
  String ownerId;
  String location;
  String mediaUrl;
  String description;
  String username;
  int likeCount;
  dynamic likes;
  QuerySnapshot snapshot2;
  RegExp exp = RegExp(r"(true+)");  // Pattern match
  String myList;
  String postOrientation = "grid";
  bool isLiked;
  String userID;
  bool showHeart = false;
  bool _isLiked;

  @override
  void initState() {
    super.initState();
    I();
    getFollowersCount();
    getFollowingCount();
    checkIfFollowing();
  }

  checkIfFollowing() async{
    DocumentSnapshot doc = await followersRef.doc(widget.profileId).collection('userFollowers').doc(widget.currentUserId).get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowersCount() async {
    QuerySnapshot snapshot = await followersRef.doc(widget.profileId).collection('userFollowers').get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowingCount() async {
    QuerySnapshot snapshot = await FollowingRef.doc(widget.profileId).collection('userFollowing').get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  I() async{
    setState(() {
      isLoading = true;
    });
    snapshot2 = await postRef.doc(widget.profileId).collection("userPosts").get();
    //Common Things

    // Extracting Data
    username = snapshot2.docs.map((e) => e.data()['username']).toString();
    username = username.substring(1,username.length-1);
    description = snapshot2.docs.map((e) => e.data()['description']).toString();
    description = description.substring(1,description.length-1);
    ownerId = snapshot2.docs.map((e) => e.data()['ownerId']).toString();
    ownerId = ownerId.substring(1,ownerId.length-1);
    mediaUrl = snapshot2.docs.map((e) => e.data()['mediaUrl']).toString();
    mediaUrl = mediaUrl.substring(1,mediaUrl.length-1);
    location = snapshot2.docs.map((e) => e.data()['location']).toString();
    location = location.substring(1,location.length-1);
    postId = snapshot2.docs.map((e) => e.data()['postId']).toString();
    postId = postId.substring(1,postId.length-1);

    //
    postCount = snapshot2.docs.length;
    setState(() {
     isLoading = false;
     likes = snapshot2.docs.map((e) => e.data()['likes']) as dynamic;
     myList = likes.toString();
     Iterable<RegExpMatch> matches = exp.allMatches(myList);
     likeCount = matches.length;
    });
    userID = widget.currentUserId;
    String a = snapshot2.docs.map((e) => e.data()['likes'][userID]).toString();
    String aa = snapshot2.docs.map((e) => e.data()['likes'][widget.currentUserId]).toString();
    a = a.substring(1,a.length-1);
    aa = aa.substring(1,aa.length-1);
    if(a == 'true' || aa == 'true'){
      setState(() {
        _isLiked = true;
        isLiked = true;
      });
    }else{
      setState(() {
        _isLiked = false;
        isLiked = false;
      });
    }
  }

  Column buildCountColumn(String label,int count){
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count.toString(),style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold)),
          Container(
            margin: EdgeInsets.only(top: 4.0),
            child: Text(label,style: TextStyle(color: Colors.grey,fontSize: 15.0,fontWeight: FontWeight.w400),),
          ),
        ],
      );
  }

  editProfile(){
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          EditProfile(currentUserID: widget.currentUserId)));
    });
  }

  Container buildButton({String text,Function function}){
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
          onPressed: function,
          child: Container(
            width: 250.0,
            height: 27.0,
            alignment: Alignment.center,
            child: Text(text,style: TextStyle(color: isFollowing ? Colors.black : Colors.white),),
            decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border: Border.all(
                color: isFollowing ? Colors.grey : Colors.blue
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
      )
    );
  }

  buildProfileButton(){
  //  viewing your iwn profile - should show edit profile button
  bool isProfileOwner = widget.currentUserId == widget.profileId;
    if(isProfileOwner){
    return buildButton(text: "Edit Profile",function: editProfile);
    }else if(isFollowing){
      return buildButton(text: "UnFollow",function: handleUnFollowUser);
    }else if(!isFollowing){
      return buildButton(text: "Follow",function: handleFollowUser);
    }
  }

  handleUnFollowUser(){
    setState(() {
      isFollowing = false;
    });
    // remove Follower
    followersRef.doc(widget.profileId).collection("userFollowers").doc(widget.currentUserId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    // Remove Following
    FollowingRef.doc(widget.currentUserId).collection('userFollowing').doc(widget.profileId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    // Delete activity feed for them
    activityFeedRef.doc(widget.profileId).collection('feedItems').doc(widget.currentUserId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }

  handleFollowUser(){
    setState(() {
      isFollowing = true;
    });
    // Make auth user followers of that user (Update their followers collection)
    followersRef.doc(widget.profileId).collection("userFollowers").doc(widget.currentUserId).set({});

    // Put that user on your following collection (update your following collection)
    FollowingRef.doc(widget.currentUserId).collection('userFollowing').doc(widget.profileId).set({});

    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef.doc(widget.profileId).collection('feedItems').doc(widget.currentUserId).set({
      'type': 'follow',
      'ownerId' : widget.profileId,
      'username' : widget.currentUseer.username,
      'userId' : widget.currentUseer.id,
      'userProfileImg' : widget.currentUseer.photoUrl,
      'timestamp' : timeStamp
    });
  }
  buildPostHeader(String ownerId,String location){
    return FutureBuilder(
        future: users.doc(ownerId).get(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          Userr user = Userr.fromDocument(snapshot.data);
          return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl)
              ),
              title: GestureDetector(
                onTap: () => showProfile(context,profileId: user.id,currentUserId: user.id,user: user),
                child: Text(user.username,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
              ),
              subtitle: Text(location),
              //right side of listTile
              trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () => print('Delete'),)
          );
        }
    );
  }

  buildProfilePost2() {
    if(isLoading){
      return circularProgress();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(ownerId,location),
      ],
    );
  }

  handleLikePost(){
    if(isLoading){
      return circularProgress();
    }

    if(_isLiked){
      postRef.doc(ownerId).collection("userPosts").doc(postId).update({'likes.$userID':false});
      removeLikeFromActivityFeed();
      likeCount--;
      setState(() {
         isLiked = false;
        _isLiked = false;
      });
    }

    else if(!_isLiked){
      postRef.doc(ownerId).collection("userPosts").doc(postId).update({'likes.$userID':true});
      addLikeToActivityFeed();
      likeCount++;
      setState(() {
        isLiked = true;
        _isLiked = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500),(){
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  removeLikeFromActivityFeed(){
    bool isNotPostOwner = widget.currentUserId != ownerId;
    if(isNotPostOwner){
      activityFeedRef.doc(ownerId).collection('feedItems').doc(postId).get().then((doc){ // We check here that we have docs or not then call then function
        if(doc.exists){
          doc.reference.delete();
        }
      });
    }
  }

  addLikeToActivityFeed(){
    // add a notification to the postOwner's activity feed only if comment made by other user (to avoid getting notification for our own like)
    bool isNotPostOwner = widget.currentUserId != ownerId;
    if(isNotPostOwner){
      activityFeedRef.doc(ownerId).collection('feedItems').doc(postId).set({
        'type': 'like',
        'username' : widget.currentUseer.username,
        'userId' : widget.currentUseer.id,
        'userProfileImg' : widget.currentUseer.photoUrl,
        'postId' : postId,
        'mediaUrl':mediaUrl,
        'timestamp' : timeStamp
      });
    }
  }

  buildPostImage({String mediaUrl}){
    if(mediaUrl == null){
      mediaUrl = this.mediaUrl;
    }
    if(isLoading){
      return circularProgress();
    }
    return Container(
      height: 550.0,
      child: GestureDetector(
        onDoubleTap: handleLikePost,
        child: Stack(
          alignment: Alignment.center,
          children: [
            cachedNetworkImage(mediaUrl),

            showHeart ? Animator(
                tween: Tween(begin: 0.8,end: 1.4),
                duration: Duration(milliseconds: 300),
                curve: Curves.elasticInOut,
                cycles: 0,
                builder: (context, animatorState, child ) => Transform.scale(scale: animatorState.value,child: Icon(Icons.favorite,size: 80.0,color: Colors.red,),)
            ) : Text ('')
          ],
        ),
      ),
    );
  }

  buildPostFooter(){
    if(isLoading){
      return circularProgress();
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40.0,left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: ()=> showComments(
                context,
                postId : postId,
                ownerId : ownerId,
                mediaUrl : mediaUrl,
                currentUser : widget.currentUseer
              ),
              child: Icon(Icons.chat,size: 28.0,color: Colors.blue[900],),
            ),
          ],
        ),

        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text('$likeCount likes',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold ),),
            ),
          ],
        ),

        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text('$username  ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold ),),
            ),
            Expanded(
              child: Text(description),
            )
          ],
        ),
      ],
    );
  }

  buildProfileHeader(){
    return FutureBuilder(
        future: users.doc(widget.profileId).get(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          Userr user = Userr.fromDocument(snapshot.data);
          return Padding(
              padding:EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildCountColumn('posts',postCount),
                                  buildCountColumn('followers',followerCount),
                                  buildCountColumn('following',followingCount)
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildProfileButton()
                                ],
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(user.username,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0),),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(user.displayName,style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 2.0),
                      child: Text(user.bio,style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
          );
        }
    );
  }

  setPost(String value){
    setState(() {
      postOrientation = value;
    });
  }

  GridViewTile() {
    if(isLoading){
      return circularProgress();
    }
    else if(snapshot2.size == 0){
      if(isLoading){
        return circularProgress();
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/no_content.svg',height: 260.0),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text('No Posts',style: TextStyle(color: Colors.redAccent,fontSize: 40.0,fontWeight: FontWeight.bold),),
            ),
        ],
      );
    }
    else if(postOrientation == "grid"){
      if(isLoading){
        return circularProgress();
      }
      List<GridTile> grid = [];
      for(int i=0; i<1; i++){
        grid.add(GridTile(child: PostTile(mediaUrl: snapshot2.docs.map((e) => e.data()['mediaUrl']).toString(),postId: postId,userId: ownerId,a: widget.currentUseer)));
      }
      return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: grid
      );
    }
    else if(postOrientation == "list"){
      if(isLoading){
        return circularProgress();
      }
      return Column(
        children: [
          buildProfilePost2(),
          buildPostImage(),
          buildPostFooter(),
        ],
      );
    }
  }

  buildTogglePostView(){
    if(isLoading){
      return circularProgress();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            icon: Icon(Icons.grid_on),
            onPressed: ()=> setPost("grid"),
            color: postOrientation == "grid" ? Theme.of(context).accentColor : Colors.grey,
        ),
        IconButton(
            icon: Icon(Icons.list),
            onPressed: ()=> setPost("list"),
            color: postOrientation == "list" ? Theme.of(context).accentColor : Colors.grey
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return circularProgress();
    }

    return Scaffold(
      appBar: header(text: 'Profile'),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(),
          buildTogglePostView(),
          Divider(
            height: 1.0,
          ),
          GridViewTile()
        ],
      ),
    );
  }
}

showComments(BuildContext context,{String postId,String ownerId,String mediaUrl,Userr currentUser}){
  Navigator.push(context, MaterialPageRoute(builder: (context){
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
        mediaUrl: mediaUrl,
        currentUser : currentUser
    );
  }));
}
