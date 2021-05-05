import 'package:flutter/material.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/post_screen2.dart';
import 'package:flutter_social_network/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final String mediaUrl;
  final String postId;
  final String userId;
  final Userr a;

  const PostTile({Key key, this.mediaUrl, this.postId, this.userId, this.a}) : super(key: key);
  
  showPosts(context){
    print("PostID: $postId");
    print("UserID: $userId");
    Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen2(postId: postId,userId: userId,currentUser: a)));
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> showPosts(context),
      child: cachedNetworkImage(mediaUrl.substring(1,mediaUrl.length-1)),
    );
  }
}
