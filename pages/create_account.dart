import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_network/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  String username;


  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(text: 'Set up your profile'),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
              Padding(
                padding: EdgeInsets.only(top:25.0),
                child: Center(
                    child: Text('Create a username',style: TextStyle(fontSize: 17.0),),
                   ),
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        validator: (val){
                          if(val.trim().length <3 || val.isEmpty){
                            return 'username too short';
                          }else if(val.trim().length > 12){
                            return 'username is too long';
                          }else{
                            return null;
                          }
                        },
                        onChanged: (val){
                          setState(() {
                            username = val;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must be at least 3 chars"
                          ),
                       ),
                    ),
                  ),
                ),

                RaisedButton(
                    color: Colors.pink[400],
                    child: Text('Register',style: TextStyle(color: Colors.white),),
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        final snackBar = SnackBar(content: Text('Welcome ${username}!'),);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        // It will show sacfold for 2 second at the same screen then pop
                        Timer(Duration(seconds: 2),(){
                          Navigator.pop(context,username);
                        });
                        Navigator.pop(context,username);
                      }
                      // print(username);
                      // print("Username here");
                    }),

                // GestureDetector(
                //   onTap: submitRequest(),
                //   child: Container(
                //     height: 60.0,
                //     width: 300.0,
                //     decoration: BoxDecoration(
                //       color: Colors.blue,
                //       borderRadius: BorderRadiusDirectional.circular(7.0)
                //     ),
                //     child: Center(child: Text('Submit',style: TextStyle(color: Colors.white,fontSize: 15.0,fontWeight: FontWeight.bold),)),
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
      // body: ListView(
      //   children: [
      //     Container(
      //       child: Column(
      //         children: [
      //           Padding(
      //               padding: EdgeInsets.only(top:25.0),
      //               child: Center(
      //                 child: Text('Create a username',style: TextStyle(fontSize: 25.0),),
      //               ),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.all(16.0),
      //             child: Container(
      //               child: Form(
      //                 key: _formKey,
      //                 child: TextFormField(
      //                   onChanged: (val) => username = val,
      //                   decoration: InputDecoration(
      //                     border: OutlineInputBorder(),
      //                     labelText: "Username",
      //                     labelStyle: TextStyle(fontSize: 15.0),
      //                     hintText: "Must be at least 3 chars"
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //           GestureDetector(
      //             onTap: submit(),
      //             child: Container(
      //               decoration: BoxDecoration(
      //                 color: Colors.blue,
      //                 borderRadius: BorderRadiusDirectional.circular(7.0)
      //               ),
      //               child: Text('Submit',style: TextStyle(color: Colors.white,fontSize: 15.0,fontWeight: FontWeight.bold),),
      //             ),
      //           ),
      //         ],
      //       ),
      //     )
      //   ],
      // ),
    );
  }



}
