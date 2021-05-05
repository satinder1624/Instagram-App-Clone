import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:flutter_social_network/pages/post_screen2.dart';
import 'package:flutter_social_network/pages/profile.dart';
import 'package:flutter_social_network/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_network/widgets/progress.dart';


class ActivityFeed extends StatefulWidget {
  final Userr currentUser;
  const ActivityFeed({Key key, this.currentUser}) : super(key: key);
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  List<ActivityFeedItem> feedItems;
  getActivityFeed() async{
    feedItems = [];
    QuerySnapshot snapshot = await activityFeedRef.doc(widget.currentUser.id).collection("feedItems").get();
    feedItems.add(ActivityFeedItem.fromDocument(snapshot));
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    a = widget.currentUser;
    return Scaffold(
      appBar: header(text: "Activity Feed"),
      backgroundColor: Colors.white54,
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return circularProgress();
            }
            return ListView(
              children: feedItems,
            );
          },
        ),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;
Userr a;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // like,follow and comment
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final String timeStamp;

  const ActivityFeedItem({Key key, this.username, this.userId, this.type, this.mediaUrl, this.postId, this.userProfileImg, this.commentData, this.timeStamp}) : super(key: key);

  factory ActivityFeedItem.fromDocument(QuerySnapshot snapshot){

    String usernameRewrite = snapshot.docs.map((e) => e.data()['username']).toString();
    usernameRewrite = usernameRewrite.substring(1,usernameRewrite.length-1);
    if(usernameRewrite.contains(",")){
      int index = usernameRewrite.indexOf(',');
      usernameRewrite = usernameRewrite.substring(0,index);
    }
    String userIdRewrite = snapshot.docs.map((e) => e.data()['userId']).toString();
    userIdRewrite = userIdRewrite.substring(1,userIdRewrite.length-1);
    if(userIdRewrite.contains(",")){
      int index = userIdRewrite.indexOf(',');
      userIdRewrite = userIdRewrite.substring(0,index);
    }
    String typeRewrite = snapshot.docs.map((e) => e.data()['type']).toString();
    typeRewrite = typeRewrite.substring(1,typeRewrite.length-1);
    String mediaUrlRewrite = snapshot.docs.map((e) => e.data()['mediaUrl']).toString();
    mediaUrlRewrite = mediaUrlRewrite.substring(1,mediaUrlRewrite.length-1);
    if(mediaUrlRewrite.contains(",")){
      int index = mediaUrlRewrite.indexOf(',');
      mediaUrlRewrite = mediaUrlRewrite.substring(0,index);
    }
    String postIdRewrite = snapshot.docs.map((e) => e.data()['postId']).toString();
    postIdRewrite = postIdRewrite.substring(1,postIdRewrite.length-1);
    if(postIdRewrite.contains(",")){
      int index = postIdRewrite.indexOf(',');
      postIdRewrite = postIdRewrite.substring(0,index);
    }
    String userProfileImgRewrite = snapshot.docs.map((e) => e.data()['userProfileImg']).toString();
    userProfileImgRewrite = userProfileImgRewrite.substring(1,userProfileImgRewrite.length-1);
    if(userProfileImgRewrite.contains(",")){
      int index = userProfileImgRewrite.indexOf(',');
      userProfileImgRewrite = userProfileImgRewrite.substring(0,index);
    }
    if(userProfileImgRewrite.contains(',')){
      int index = userProfileImgRewrite.indexOf(',');
      userProfileImgRewrite = userProfileImgRewrite.substring(0,index);
    }
    String commentDataRewrite = snapshot.docs.map((e) => e.data()['commentData']).toString();
    commentDataRewrite = commentDataRewrite.substring(1,commentDataRewrite.length-1);
    String timeStampRewrite = snapshot.docs.map((e) => e.data()['timestamp']).toString();
    timeStampRewrite = timeStampRewrite.substring(1,timeStampRewrite.length-1);

    return ActivityFeedItem(
        username: usernameRewrite,
        userId: userIdRewrite,
        type: typeRewrite,
        mediaUrl: mediaUrlRewrite,
        postId: postIdRewrite,
        userProfileImg: userProfileImgRewrite,
        commentData: commentDataRewrite,
        timeStamp: timeStampRewrite
    );
  }

  showPosts(context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen2(postId: postId,userId: a.id,currentUser: a)));
  }
  configureMediaPreview(context){
    if(type.contains('like')||type.contains('comment')||type.contains('follow')){
      mediaPreview = GestureDetector(
        onTap: ()=> showPosts(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(mediaUrl)
                  )
              ),
            ),
          ),
        ),
      );
    }else{
      mediaPreview = Text('');
    }

    if(type=='like'){
      activityItemText = 'liked your post';
    }else if(type == 'follow'){
      activityItemText = 'is following you';
    }else if(type=='comment'){
      activityItemText = 'replied: $commentData';
    }else if(type.contains("like") && type.contains("comment")){
      activityItemText = 'like and replied on your post';
    }else if(type.contains("like") && type.contains('comment') && type.contains("follow")){
      activityItemText = 'Follows you and like and replied on your post';
    }else if(type.contains("like") && type.contains("follow")){
      activityItemText = 'Follows you and like your post';
    }
    else if(type.contains('comment') && type.contains("follow")){
      activityItemText = 'Follows you and replied at your post';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.blueGrey,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userProfileImg),
          ),
          title: GestureDetector(
            onTap: ()=> showProfile(context, profileId: userId,currentUserId: a.id,user: a),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14.0,color: Colors.black), // common style
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold), // overwrite
                    ),
                    TextSpan(
                        text: ' $activityItemText' // common style will use here
                    )
                  ]
              ),
            ),
          ),

          //subtitle: Text('About an hour ago'),
          //subtitle: Text(timeAgo.format(DateTime.parse(timeStamp.toDate().toString())).toString()),

          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId,String currentUserId,Userr user}){
  Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(profileId: profileId,currentUserId: currentUserId,currentUseer: user,)));
}
