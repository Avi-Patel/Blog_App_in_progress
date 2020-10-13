import 'package:blogging_app/Profile/change_pro_pic.dart';
import 'package:blogging_app/Profile/personal_blog.dart';
import 'package:blogging_app/Profile/saved_blogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  var uid=null;
  String _url="https://png.pngitem.com/pimgs/s/506-5067022_sweet-shap-profile-placeholder-hd-png-download.png";
  var flushbar;
  var _yourblogs=0;
  var _savedblogs=0;
  var _totallikes=0;
  var _name="...";

  void show(String s1) 
  {
      flushbar = Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.info_outline,color: Colors.blue,),
      messageText: Text(
        s1,
        style: TextStyle(color: Colors.white,fontWeight: FontWeight.w300),
      ),
      backgroundColor: Colors.black87,
    );
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

  Future<void> _fecthYourBlogs() async
  {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get()
      .then((value)
      {
        if(value.data().containsKey('Your Blogs'))
        setState(() {
          _yourblogs=value.data()['Your Blogs'];
        });
      })
      .catchError((e){
        print(e);
        show("Opps!! Some error occured. Try again");
        flushbar..show(context);
      });
  }
  Future<void> _fecthSavedBlogs() async
  {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get()
      .then((value)
      {
        if(value.data().containsKey('Saved Blogs'))
        setState(() {
          _savedblogs=value.data()['Saved Blogs'];
        });
      })
      .catchError((e){
        print(e);
        show("Opps!! Some error occured. Try again");
        flushbar..show(context);
      });
  }
  Future<void> _fecthTotalLikes() async
  {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get()
      .then((value)
      {
        if(value.data().containsKey('Total Likes'))
        setState(() {
          _totallikes=value.data()['Total Likes'];
        });
      })
      .catchError((e){
        print(e);
        show("Opps!! Some error occured. Try again");
        flushbar..show(context);
      });
  }

  Future<void> _fetchName() async
  {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get()
      .then((value){
        setState(() {
          _name=value.data()['name'];
        });
      })
      .catchError((e){
        print("error : "+e.toString());
        show("Opps!! something went wrong");
      });
  }
  Future<void> _updateName() async
  {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'name':_name,
      })
      .catchError((e){
        print("error : "+e.toString());
        show("Opps!! something went wrong");
      });
  }
   
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(FirebaseAuth.instance.currentUser!=null)
    {
      setState(() {
        uid=FirebaseAuth.instance.currentUser.uid.toString();
      });
    }
    _profileUrl();
    _fecthSavedBlogs();
    _fecthYourBlogs();
    _fecthTotalLikes();
    _fetchName();
  }


  Widget _yourBlogs()
  {
    return InkWell(
      splashColor: Colors.black,
      child: Container(
        padding: EdgeInsets.all(8.0),
        width: MediaQuery.of(context).size.width/4,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            ),
            Text(
              "Blogs",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            ),
            SizedBox(height: 8.0,),
            Text(
              _yourblogs.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            )
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => PersonalBlogs()))
          .then((_){
            _fecthYourBlogs();
            _fecthTotalLikes();
            _fecthSavedBlogs();
          });
      },
    );
  }

  Widget _savedBlogs()
  {
    return InkWell(
      splashColor: Colors.black,
      highlightColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width/4,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.0),
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Saved",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            ),
            Text(
              "Blogs",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            ),
            SizedBox(height: 8.0,),
            Text(
              _savedblogs.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            )
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SavedBlogs()))
          .then((_){
            _fecthSavedBlogs();
            _fecthTotalLikes();
          });
      },
    );
  }
  
  Widget _totalLikes()
  {
    return InkWell(
      splashColor: Colors.black,
      highlightColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width/4,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.0),
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Total",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            ),
            Text(
              "Likes",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            ),
            SizedBox(height: 8.0,),
            Text(
              _totallikes.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontStyle: FontStyle.normal
              ),
            )
          ],
        ),
      ),
      onTap: (){},
    );
  }

  Future<void> _showDialog()
  {
    var name;
    return showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: Column(
          children: [
            TextField(
              style: TextStyle(
                color: Colors.black
              ),
              decoration: InputDecoration(
                enabledBorder: new UnderlineInputBorder(
                borderSide: new BorderSide(
                  color: Colors.black
                )
              ),
                labelText: "Name",
                hintText: "Enter name here",
                labelStyle: TextStyle(
                  color: Colors.black
                ),
                hintStyle: TextStyle(
                  color: Colors.black
                ),
                counterStyle: TextStyle(
                  color: Colors.black
                ),
              ),
              cursorColor: Colors.white,

              onChanged: (value){
                setState(() {
                  name=value;
                });
              },
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
        actions: <Widget>[
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: new Text(
                "Cancel",
                style: new TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
            onTap: (){
              Navigator.of(context).pop();
            },
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: new Text(
                "Update",
                style: new TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
            onTap: (){
              setState(() {
                _name=name;
              });
              _updateName().whenComplete((){
                Navigator.of(context).pop();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: EdgeInsets.only(top:30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(8.0,50.0,8.0,8.0),
                  child: Container(
                    height: 200.0,
                    padding: EdgeInsets.fromLTRB(8.0,70.0,8.0,8.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.blue,
                        width: 1.0
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20.0,
                            fontStyle: FontStyle.normal
                          ),
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser.email,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            fontStyle: FontStyle.normal
                          ),
                        ),
                        SizedBox(height: 16.0,),
                        FlatButton(
                          color: Colors.blue,
                          splashColor: Colors.white,
                          padding: EdgeInsets.fromLTRB(4.0,4.0,4.0,4.0),
                          shape: RoundedRectangleBorder(
                            // side: BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Edit",
                              style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              fontStyle: FontStyle.normal
                            ),
                          ),
                          onPressed: (){
                            _showDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.white,
                  child:Container(
                    width: 100.0,
                    height: 100.0,
                    decoration:BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 2.0
                      ),
                      shape: BoxShape.circle, 
                      color: Colors.blue,
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _url,
                        fit: BoxFit.fill,  
                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                          CircularProgressIndicator(value: downloadProgress.progress
                        ),
                        placeholderFadeInDuration: Duration(
                          seconds: 1,
                        ),
                        fadeInDuration: Duration(
                          seconds: 1,
                        ),
                      ),
                    ),
                  ),
                  onTap: (){
                    Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => ChangeProPic(_url)))
                      .then((message){
                        print(message);
                        if(message!=null)
                        {
                          show(message);
                          flushbar.show(context);
                          _profileUrl();
                        }                        
                      });
                  },
                )
              ],
            ),

            SizedBox(height: 16.0,),
            //below image,name and email
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(8.0,30.0,8.0,8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  color: Colors.white
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _yourBlogs(),
                        _savedBlogs(),
                        _totalLikes(),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}