import 'package:flutter/material.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:flutter_social_network/pages/profile.dart';
import 'package:flutter_social_network/widgets/custom_image.dart';
import 'package:flutter_social_network/widgets/header.dart';
import 'package:flutter_social_network/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  const PostScreen({Key key, this.userId, this.postId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Profile a = Profile();

    return FutureBuilder(
      future: postRef.doc(userId).collection("userPosts").doc(postId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        return Center(
          child: Scaffold(
            appBar: header(text: snapshot.data['description'].toString()),
            body: ListView(
              children: [
                  a.createState().buildPostHeader(snapshot.data['ownerId'].toString(),snapshot.data['location'].toString()),
                  a.createState().buildPostImage(mediaUrl: snapshot.data['mediaUrl'].toString()),
                  //a.createState().buildPostFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
