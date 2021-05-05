import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_network/model/user.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:flutter_social_network/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

final CollectionReference users = FirebaseFirestore.instance.collection('users');


FirebaseStorage storage = FirebaseStorage.instance;
Reference storageRef = storage.ref();

TextEditingController captionController = TextEditingController();
TextEditingController locationController = TextEditingController();

class Upload extends StatefulWidget {

  final Userr currentUser;
  const Upload({Key key, this.currentUser}) : super(key: key);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  bool isUploading = false;
  String postId =Uuid().v4();

  handleChooseFromGallery() async {
    Navigator.pop(context);
    PickedFile file = await ImagePicker().getImage(source: ImageSource.gallery);
    File selected = File(file.path);
    setState(() {
      this.file = selected;
    });
  }

  handleTakePhoto() async{
    Navigator.pop(context);
    PickedFile file = await ImagePicker().getImage(source: ImageSource.camera);
    File selected = File(file.path);
    setState(() {
      this.file = selected;
    });
  }

  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Create a post'),
            children: [
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text('Image from Gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
          return null;
        }
        );
  }

  Container buildSplashScreen(){
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/upload.svg',height: 260.0),
          Padding(
              padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
              ),
              child: Text('Upload Image',style: TextStyle(
                color: Colors.white,
                fontSize: 22.0
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  clearImage(){
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile,quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async{
    UploadTask uploadTask = storageRef.child("post_$postId.jpg").putFile(imageFile);
    String url;
    await uploadTask.whenComplete(() async {
      url = await uploadTask.snapshot.ref.getDownloadURL();
    });
    return url;
  }

  createPostInFirestore({String mediaUrl,String location,String description}){
    postRef.doc(widget.currentUser.id).collection("userPosts").doc(postId).set({ //nested
      'postId' : postId,
      'ownerId' : widget.currentUser.id,
      "username" : widget.currentUser.username,
      "mediaUrl" : mediaUrl,
      "description" : description,
      "location" : location,
      "timestamp": timeStamp,
      "likes" : {}
    });
  }
  handleSubmit() async{
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text
    );
    locationController.clear();
    captionController.clear();

    setState(() {
      file = null;
      isUploading = false;
    });
  }

  Scaffold buildUplaodForm(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: clearImage,
        ),
        title: Center(child: Text('Create a post',style: TextStyle(color: Colors.black),)),
        actions: [
          FlatButton(
              onPressed: isUploading ? null : () => handleSubmit(), // we have to call this by () => in order to don't call imediatately
              child: Text('Post',style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold,fontSize: 20.0),))
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(''),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,// 800
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9, // Dimension
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    )
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop,color: Colors.orange,size: 35.0,),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(Icons.my_location,color: Colors.white,),
                label: Text('Use Current Location',style: TextStyle(color:Colors.white),),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
                ),
                color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  getUserLocation() async{
    //Geoposition().coords.latitude
    Position position = await Geolocator.getLastKnownPosition();
    List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placeMark = placeMarks[0];
    String completeAddress = '${placeMark.subThoroughfare} ${placeMark.thoroughfare} ${placeMark.subLocality} ${placeMark.locality} ${placeMark.subAdministrativeArea}'
        '${placeMark.administrativeArea} ${placeMark.postalCode} ${placeMark.country}';
    print(completeAddress);
    String formattedAddress = "${placeMark.locality}, ${placeMark.country}";
    locationController.text = formattedAddress;


    // Location location = new Location();
    // location.getLocation();
    // bool _serviceEnabled;
    // PermissionStatus _permissionGranted;
    // LocationData _locationData;
    //
    // _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    //   if (!_serviceEnabled) {
    //     return;
    //   }
    // }
    //
    // _permissionGranted = await location.hasPermission();
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     return;
    //   }
    // }
    //
    // _locationData = await location.getLocation();
    // print(_locationData);
  }
  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUplaodForm();
  }
}
