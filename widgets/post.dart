import 'package:flutter/material.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:flutter_social_network/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  const Post({Key key, this.postId, this.ownerId, this.username, this.location, this.description, this.mediaUrl, this.likes}) : super(key: key);

  factory Post.fromDocument(doc) {
    return Post(postId: doc['postId'],ownerId: doc['ownerId'],username: doc['username'],location: doc['location'],description: doc['description'], mediaUrl: doc['mediaUrl'],likes: doc['likes']);
  }


    int getCount(likes){
      // if no likes return 0
      if(likes ==null){
        return 0;
      }
      int count = 0;
      // likes have key and value
      likes.value.forEach((val){
        if(val == true){
          count++;
        }
      });
      return count;
    }

    @override
    _PostState createState() => _PostState(
        this.postId, this.ownerId, this.username, this.location, this.description, this.mediaUrl, this.likes, getCount(this.likes)
    );
  }


class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;

  _PostState(this.postId, this.ownerId, this.username, this.location, this.description, this.mediaUrl, this.likes, this.likeCount);

  buildPostHeader(){
    print('run');
    return FutureBuilder(
        future: users.doc(ownerId).get(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          Userr user = Userr.fromDocument(snapshot.data);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl),
              radius: 50.0,
            ),
            title: GestureDetector(
              onTap: () => print('Tapped'),
              child: Text(user.username,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ),
            subtitle: Text(location),
            //right side of listTile
            trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () => print('Delete'),)
          );
        }
    );
  }

  buildPostImage(){
    print('run');
    return GestureDetector(
      onDoubleTap: () => print('Liking Image'),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(mediaUrl),
        ],
      ),
    );
  }

  buildPostFooter(){
    print('run');
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40.0,left: 20.0)),
            GestureDetector(
              onTap: () => print('liking posting'),
              child: Icon(Icons.favorite_border,size: 28.0,color: Colors.pink,),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => print('showing comments'),
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
              child: Text('$username',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold ),),
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
    print('run 1');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
