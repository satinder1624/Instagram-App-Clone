import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:flutter_social_network/pages/profile.dart';
import 'package:flutter_social_network/widgets/custom_image.dart';
import 'package:flutter_social_network/widgets/header.dart';
import 'package:flutter_social_network/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:animator/animator.dart';

import 'comments.dart';


class PostScreen2 extends StatefulWidget {
  final String userId;
  final String postId;
  final Userr currentUser;

  const PostScreen2({Key key, this.userId, this.postId, this.currentUser}) : super(key: key);


  @override
  _PostScreen2State createState() => _PostScreen2State();
}

class _PostScreen2State extends State<PostScreen2> {
  int likeCount;
  bool isLoading = false;
  bool showHeart = false;
  bool _isLiked;
  bool isLiked;
  QuerySnapshot snapshot2;
  Profile a = Profile();
  String OId;
  String mediaURL;
  dynamic likes;
  String myList;
  RegExp exp = RegExp(r"(true+)");  // Pattern match

  @override
  void initState(){
    super.initState();
    I();
  }
  I() async{
    setState(() {
      isLoading = true;
    });
    snapshot2 = await postRef.doc(widget.userId).collection("userPosts").get();
    OId = snapshot2.docs.map((e) => e.data()['ownerId']).toString();
    OId = OId.substring(1,OId.length-1);
    mediaURL = snapshot2.docs.map((e) => e.data()['mediaUrl']).toString();
    mediaURL = mediaURL.substring(1,mediaURL.length-1);
    String a = snapshot2.docs.map((e) => e.data()['likes'][widget.userId]).toString();
    a = a.substring(1,a.length-1);
    setState(() {
      likes = snapshot2.docs.map((e) => e.data()['likes']) as dynamic;
      myList = likes.toString();
      Iterable<RegExpMatch> matches = exp.allMatches(myList);
      likeCount = matches.length;
    });
    if(a == 'true'){
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
    setState(() {
      isLoading = false;
    });
  }
  handleLikePost(){
    if(isLoading){
      return circularProgress();
    }

    if(_isLiked){
      postRef.doc(OId).collection("userPosts").doc(widget.postId).update({'likes.${widget.userId}':false});
      // removeLikeFromActivityFeed();
      likeCount--;
      setState(() {
        isLiked = false;
        _isLiked = false;
      });
    }

    else if(!_isLiked){
      postRef.doc(OId).collection("userPosts").doc(widget.postId).update({'likes.${widget.userId}':true});
      //addLikeToActivityFeed();
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

  buildPostImage({String mediaUrl}){
    if(isLoading){
      return circularProgress();
    }
    return Container(
      height: 550.0,
      child: GestureDetector(
        onDoubleTap: ()=>handleLikePost(),
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

  buildPostFooter({String username,String mediaUrl,String description}){
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
                  postId : widget.postId,
                  ownerId : widget.userId,
                  mediaUrl : mediaUrl,
                  currentUser : widget.currentUser
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef.doc(widget.userId).collection("userPosts").doc(widget.postId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        String mediaUrl = snapshot.data['mediaUrl'].toString();
        String description = snapshot.data['description'].toString();
        return Center(
          child: Scaffold(
            appBar: header(text: description,backDirection: true),
            body: ListView(
              children: [
                a.createState().buildPostHeader(snapshot.data['ownerId'].toString(),snapshot.data['location'].toString()),
                buildPostImage(mediaUrl: mediaUrl),
                buildPostFooter(username: snapshot.data['username'].toString(),mediaUrl: mediaUrl,description: description),
                //a.createState().buildPostImage(mediaUrl: snapshot.data['mediaUrl'].toString()),
                //a.createState().buildPostFooter(),
              ],
            ),
          ),
        );
      },
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

