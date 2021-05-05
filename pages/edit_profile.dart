import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_network/widgets/progress.dart';
import 'package:google_sign_in/google_sign_in.dart';

class EditProfile extends StatefulWidget {
  final String currentUserID;

  const EditProfile({Key key, this.currentUserID}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  TextEditingController displayNameController= TextEditingController();
  TextEditingController bioController= TextEditingController();
  bool isLoading = false;
  bool _bioValid = true;
  bool _displayValid = true;
  Userr user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async{
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await users.doc(widget.currentUserID).get();
    user = Userr.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    Column buildDisplayNameField(){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text('Display Name',style: TextStyle(color: Colors.grey),)
          ),
          TextField(
            controller: displayNameController,
            decoration: InputDecoration(
                hintText: 'Update Display Name',
                errorText: _displayValid ? null : 'Display name too short'
            ),
          ),
        ],
      );
    }

    Column buildBioField(){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text('Bio',style: TextStyle(color: Colors.grey),)
          ),
          TextField(
            controller: bioController,
            decoration: InputDecoration(
                hintText: 'Update Bio',
                errorText: _bioValid ? null : 'Bio is too long'
            ),
          ),
        ],
      );
    }

    updateUser(){
      setState(() {
        displayNameController.text.trim().length < 3 || displayNameController.text.isEmpty ? _displayValid = false : _displayValid = true;
        bioController.text.trim().length > 100 ? _bioValid = false : _bioValid = true;
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if(_displayValid && _bioValid){
          users.doc(widget.currentUserID).update(({
            'displayName': displayNameController.text,
            'bio': bioController.text
          })).whenComplete(() {
            final snackBar = SnackBar(duration: Duration(seconds: 2),content: Text('Profile updated!',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: Colors.blueAccent,);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);});
            Navigator.pop(context);
        }
      });
    }

    logout() async{
      await googleSignIn.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Edit Profile",style: TextStyle(color: Colors.black),),
        actions: [
          IconButton(
              icon: Icon(Icons.done,size: 30,color: Colors.greenAccent,),
              onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: isLoading ? circularProgress() : ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16.0,bottom: 8.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildDisplayNameField(),
                      buildBioField()
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: () => updateUser(),
                  child: Text('Update Profile',style: TextStyle(color: Theme.of(context).accentColor,fontSize: 20.0,fontWeight: FontWeight.bold)),
                ),
                Padding(
                   padding: EdgeInsets.all(16.0),
                  child: FlatButton.icon(
                      onPressed: ()=> logout(),
                      icon: Icon(Icons.cancel,color: Colors.red,),
                      label: Text('Logout',style: TextStyle(color: Colors.red,fontSize: 20.0),)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
