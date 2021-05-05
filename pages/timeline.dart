import 'package:flutter/material.dart';
import 'package:flutter_social_network/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// final CollectionReference users = FirebaseFirestore.instance.collection('users');


class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(isAppTitle: true),
      body: Text('Timeline'),
    );
  }
}

