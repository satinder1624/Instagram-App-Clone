import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_social_network/pages/create_account.dart';
import 'package:flutter_social_network/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
        accentColor: Colors.purple,
      ),
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: Home(),
    );
  }
}
