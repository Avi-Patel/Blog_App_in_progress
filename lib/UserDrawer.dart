import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_register/Login.dart';

class UserDrawer extends StatefulWidget {
  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  String name = null;
  String email = null;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void show(String s1) {
    final snakbar = SnackBar(
      content: Text(s1),
      duration: Duration(
        seconds: 1,
      ),
    );
    scaffoldKey.currentState.showSnackBar(snakbar);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut().then((value) {}).catchError((e) {
      print(e);
    });
    print("User logged out");
    show("You are logged out:)");
    Navigator.of(context).pop();
  }

  Future<void> _getname() async {
    _user = _auth.currentUser;
    if (_user != null) {
      print(_user.emailVerified);
    }

    if (_user != null && _user.emailVerified) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();
      setState(() {
        name = snapshot.get('name').toString();
        email = _user.email;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getname();
    print(name);
    print(email);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("User Drawer"),
      ),
      body: Container(),
    );
  }
}
