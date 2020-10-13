import 'dart:ui';
import 'package:blogging_app/Blog/Blog_templete.dart';
import 'package:blogging_app/Blog/Show_blogs.dart';
import 'package:blogging_app/Profile/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_register/Login.dart';
import 'image_urls.dart';

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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.black,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: "Roboto Slab"
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  String msg=null;
  HomePage({this.msg});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  User _user;
  String name = null;
  String email = null;
  String uid=null;
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
    Navigator.of(context).pop();
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

    if (_user != null && _user.emailVerified) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get()
        .then((value) {
          setState(() {
            name = value.data()['name'];
            email = _user.email;
          });
          print(name);
          print(email);
        })
        .catchError((e){
          print(e);
        });
    } 
    else {
      setState(() {
        name = null;
        email = null;
        uid=null;
      });
    }
  }

  Future<void> _profileUrl() async
  {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
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
   
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.msg!=null)
    {
      show(widget.msg);
      flushbar.show(context);
    }
    _user=FirebaseAuth.instance.currentUser;
    _getname();
    // print(name);
    // print(email);
    // print(uid);
    if(_user!=null)
    {
      setState(() {
        uid=_user.uid;
      });
      _profileUrl();
    }
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
                        child: _url!=null?
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
                          onTap: () {
                            Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) => UserProfile()))
                              .then((_){
                                _profileUrl();
                                _getname();
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
      backgroundColor: Colors.black,
      drawer: _drawer(),
      floatingActionButton: FlatButton(
        color: Colors.blue,
        splashColor: Colors.white,
        padding: EdgeInsets.fromLTRB(10.0,10.0,10.0,10.0),
        shape: RoundedRectangleBorder(
          // side: BorderSide(color: Colors.black, width: 1),
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
          // Navigator.of(context)
          //     .push(MaterialPageRoute(builder: (context) => BlogTile()));
          // print(FirebaseAuth.instance.currentUser);
          if(FirebaseAuth.instance.currentUser!=null)
          {
            Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => BlogTile()))
              .then((value){
                if(value!=null)
                {
                  show(value);
                  flushbar.show(context);
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Container(
        // height: MediaQuery.of(context).size.height,
        // width: MediaQuery.of(context).size.width,
        // color: Colors.black,
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(8, (index) {
            return InkWell(
              splashColor: Colors.white,
              highlightColor: Colors.white,
              child: Card(
                elevation: 10.0,
                color: Colors.black,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.white),
                    image: DecorationImage(
                      // image: AssetImage("assets/${blogArr[index].toLowerCase()}"+"_"+"${blogExtention[index].toLowerCase()}.jpg"),
                      image: CachedNetworkImageProvider(
                        _urls.urls[index],
                      ),
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.7), BlendMode.darken),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //  SizedBox(height: MediaQuery.of(context).size.height/15,),
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
                  .push(MaterialPageRoute(builder: (context) => ShowBlogs("${blogArr[index]}"+" "+"${blogExtention[index]}")));
              }
            );
          }),
        ),
      ),
    );
  }
}
