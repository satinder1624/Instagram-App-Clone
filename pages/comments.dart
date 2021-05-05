import 'package:flutter/material.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:flutter_social_network/widgets/header.dart';
import 'package:flutter_social_network/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String mediaUrl;
  final Userr currentUser;

  const Comments({Key key, this.postId, this.postOwnerId, this.mediaUrl, this.currentUser}) : super(key: key);


  @override
  CommentsState createState() => CommentsState(
      postId : this.postId,
      postOwnerId: this.postOwnerId,
      mediaUrl : this.mediaUrl,
      currentUser : this.currentUser
  );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String mediaUrl;
  final Userr currentUser;

  CommentsState({this.postId, this.postOwnerId, this.mediaUrl,this.currentUser});

  buildComments(){
    return StreamBuilder(
        stream: commentsRef.doc(postId).collection("comments").orderBy("timeStamp",descending: true).snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          List<Comment> comment = [];
          snapshot.data.docs.forEach((doc){
            comment.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comment,
          );
    });
  }
  
  addComment(){
    commentsRef.doc(postId).collection("comments").add({
      'username' : currentUser.username,
      'comment': commentController.text,
      'timeStamp': timeStamp,
      'avatarUrl': currentUser.photoUrl,
      "userId": currentUser.id
    });
    bool isNotPostOwner = postOwnerId != currentUser.id;
    if(isNotPostOwner){
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData' : commentController.text,
        'timestamp' : timeStamp,
        'postId' : postId,
        'userId' : currentUser.id,
        'username' : currentUser.username,
        'userProfileImg' : currentUser.photoUrl,
        'mediaUrl':mediaUrl,
      });
    }
    commentController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(text: "comments",backDirection: true),
      body: Column(
        children: [
          Expanded(
              child: buildComments()
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: "Write a comment....",
              ),
            ),
            trailing: OutlinedButton(
              child: Text("Post"),
              onPressed: ()=>addComment(),
            ),
          ),
        ],
      ),
    );
  }
}



class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timeStamp;

  const Comment({Key key, this.username, this.userId, this.avatarUrl, this.comment, this.timeStamp}) : super(key: key);

  factory Comment.fromDocument(doc) => Comment(username: doc['username'],userId: doc['userId'],comment: doc['comment'],timeStamp: doc['timeStamp'],avatarUrl: doc['avatarUrl'],);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          subtitle: Text(timeAgo.format(DateTime.tryParse(timeStamp.toDate().toString())).toString()),
        ),
        Divider()
      ],
    );
  }
}
