import 'dart:ui';
import 'package:blogging_app/Blog/Blog_templete.dart';
import 'package:blogging_app/Blog/Show_blogs.dart';
import 'package:blogging_app/Profile/user_profile.dart';
import 'package:blogging_app/helper_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_register/Login.dart';
import 'image_urls.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  GestureBinding.instance.resamplingEnabled=true;
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
      title: 'Bloggenix',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.black,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: "Lato"
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

  Helper _helper=Helper();
  String _name;
  String _email;
  String _uid;
  User _user;
  String _url="https://png.pngitem.com/pimgs/s/506-5067022_sweet-shap-profile-placeholder-hd-png-download.png";
  Urls _urls=Urls();
  var blogArr = [
    'Tech',
    'Non-Tech',
    'Interview',
    'Internship',
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
  

  void _singin() {
    Navigator.of(context).pop();
    Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => Login()))
      .then((value){
        if(value!=null)
        {
          if(mounted)
            setState(() {
              _user=FirebaseAuth.instance.currentUser;
            });
            _getDetails().then((_){
              _profileUrl();
            });
            _helper.show(value);
            _helper.flushbar.show(context);
        }
      });
  }

  Future<void> _signOut() async {
    Navigator.of(context).pop();
    await FirebaseAuth.instance
      .signOut()
      .then((value) {
        print("User logged out");
        _helper.show("You are logged out:)");
        _helper.flushbar.show(context);
        setState(() {
          _user=null;
        });
        _getDetails().then((_){
          _profileUrl();
        });
      })
      .catchError((e){
      print(e);
    });
  }

  Future<void> _getDetails() async {
    if (_user != null && _user.emailVerified) {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get()
        .then((value) {
          setState(() {
            _name = value.data()['name'];
            _email = _user.email;
            _uid=_user.uid;
          });
          print(_name);
          print(_email);
        })
        .catchError((e){
          print(e);
        });
    } 
    else {
      setState(() {
        _name = null;
        _email = null;
        _uid=null;
      });
    }
  }

  Future<void> _profileUrl() async
  {
    if(_user!=null && _user.emailVerified)
    {
      await FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .get()
      .then((value){
        // print(value.data().containsKey('profileUrl'));
        if(value.data().containsKey('profileUrl')==true) 
        {
          setState(() {
            _url=value.data()['profileUrl'].toString();
          });
        }
        print(_url);
      });
    }
    else
    {
      setState(() {
        _url="https://png.pngitem.com/pimgs/s/506-5067022_sweet-shap-profile-placeholder-hd-png-download.png";
      });
    }
  }
   
  @override
  void initState() {
    super.initState();
    _user=FirebaseAuth.instance.currentUser;
    if(_user==null || _user.emailVerified==false)
    {
      setState(() {
        _user=null;
      });
    }
    _getDetails().then((_){
      _profileUrl();
    });
    // print(_name);
    // print(_email);
    // print(_uid);
  }


  Widget _drawer() {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          children: <Widget>[
            _uid != null? 
            UserAccountsDrawerHeader(
              accountName: Text(
                _name,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              accountEmail: Text(
                _email,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              currentAccountPicture:
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0
                  ),
                  color: Colors.black,
                  image: DecorationImage(
                    image:CachedNetworkImageProvider(
                      _url,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                child: _uid!=null?
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _url,
                    fit: BoxFit.fill,  
                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                      CircularProgressIndicator(
                        value: downloadProgress.progress,
                    ),
                    placeholderFadeInDuration: Duration(
                      seconds: 1,
                    ),
                    fadeInDuration: Duration(
                      seconds: 1,
                    ),
                  ),
                )
                :
                Text(
                  _name[0],
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            )
            : Container(),
            _uid != null? 
            ListTile(
              title: Text(
                "My Profile",
                style: TextStyle(color: Colors.white),
              ),
              leading: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => UserProfile()))
                  .then((_){
                    _profileUrl();
                    _getDetails();
                  });
              },
            )
            : Container(),
            Divider(
              color: Colors.blue,
              height: 0.0,
            ),
            ListTile(
              title: Text(
                _uid != null ? "Logout" : "Login",
                style: TextStyle(color: Colors.white),
              ),
              leading: Icon(
                Icons.account_box,
                color: Colors.white,
              ),
              onTap: () => _uid == null ? _singin() : _signOut(),
            ),
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
            ),
            Divider(
              color: Colors.blue,
              height: 0.0,
            ),
          ],
        ),
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    _helper.checkMemory();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hey Bloggers!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      drawer: _drawer(),
      floatingActionButton: FloatingActionButton(
        elevation: 2.0,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        splashColor: Colors.white,
        highlightElevation: 10.0,
        child: Icon(
          Icons.create,
          color: Colors.white,
          size: 30.0,
        ),
        onPressed: () 
        {
          if(FirebaseAuth.instance.currentUser!=null)
          {
            Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => BlogTile()))
              .then((value){
                if(value!=null)
                {
                  _helper.show(value);
                  _helper.flushbar.show(context);
                }
              });
          }
          else
          {
            Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Login()));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        padding: EdgeInsets.all(10.0),
        children: List.generate(8, (index) {
          return InkWell(
            splashColor: Colors.white,
            customBorder:RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Card(
              margin: EdgeInsets.all(2.0),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white,width: 0.5),
                  image: DecorationImage(
                    // image: AssetImage("assets/${blogArr[index].toLowerCase()}"+"_"+"${blogExtention[index].toLowerCase()}.jpg"),
                    image: CachedNetworkImageProvider(
                      _urls.urls[index],
                    ),
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.darken),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: [
                        Text(
                          blogArr[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                        Text(
                          blogExtention[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),
                    
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.white,
                      size: 30.0,
                    )
                  ],
                ),
              ),
            ),
            onTap: (){
              Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ShowBlogs("${blogArr[index]}"+" "+"${blogExtention[index]}",index)));
            }
          );
        }),
      ),
    );
  }
}
