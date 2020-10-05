import 'dart:ui';
import 'package:blogging_app/Blog/Blog_templete.dart';
import 'package:flushbar/flushbar.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_register/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blogging App',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.black,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User _user;
  String name = null;
  String email = null;
  var blogArr = [
    'Tech',
    'Non-Tech',
    'Interview',
    'Intership',
    'Food',
    'Travel',
    'Political',
    'Business'
  ];
  var blogExtention = [
    'Blogs',
    'Blogs',
    'Exps',
    'Exps',
    'Blogs',
    'Blogs',
    'Blogs',
    'Blogs'
  ];
  var flushbar;
  void show(String s1) {
    flushbar = Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      icon: Icon(
        Icons.info_outline,
        color: Colors.blue,
      ),
      messageText: Text(
        s1,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
      ),
      backgroundColor: Colors.black87,
    );
  }

  void _singin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Login()));
  }

  Future<void> _signOut() async {
    Navigator.of(context).pop();
    await FirebaseAuth.instance.signOut().then((value) {}).catchError((e) {
      print(e);
    });
    print("User logged out");
    show("You are logged out:)");
    flushbar.show(context);
    _getname();
  }

  Future<void> _getname() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      print("user is null");
    }
    // if (_user != null) {
    //   print("nsak" + _user.emailVerified.toString());
    // }

    if (_user != null && _user.emailVerified) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();
      setState(() {
        name = snapshot.get('name').toString();
        email = _user.email;
      });
    } else {
      setState(() {
        name = null;
        email = null;
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

  Widget _drawer() {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          children: <Widget>[
            name != null
                ? UserAccountsDrawerHeader(
                    accountName: Text(
                      name,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    accountEmail: Text(
                      email,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        name[0],
                        style: TextStyle(fontSize: 40.0),
                      ),
                    ),
                  )
                : Container(),
            Container(
              color: Colors.black,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      name != null ? "Logout" : "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.white,
                    ),
                    onTap: () => name == null ? _singin() : _signOut(),
                  ),
                  Divider(
                    color: Colors.blue,
                    height: 0.0,
                  ),
                  name != null
                      ? ListTile(
                          title: Text(
                            "My Profile",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          onTap: () {},
                        )
                      : Container(),
                  Divider(
                    color: Colors.blue,
                    height: 0.0,
                  ),
                  ListTile(
                    title: Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  var firstColor = Colors.black12, secondColor = Colors.black;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hey Bloggers!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      drawer: _drawer(),
      floatingActionButton: FlatButton(
        color: Colors.blue,
        splashColor: Colors.white,
        minWidth: 100.0,
        height: 40.0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Create New Blog",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 10.0,
            ),
            Icon(
              Icons.create,
              color: Colors.white,
            )
          ],
        ),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => BlogTile()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Container(
        // height: MediaQuery.of(context).size.height,
        // width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(8, (index) {
            return Card(
              elevation: 10.0,
              color: Colors.black,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/background_image.jpg"),
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.7), BlendMode.darken),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //  SizedBox(height: MediaQuery.of(context).size.height/15,),
                    Text(
                      blogArr[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      blogExtention[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
