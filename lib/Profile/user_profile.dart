import 'package:blogging_app/Profile/change_password.dart';
import 'package:blogging_app/Profile/change_pro_pic.dart';
import 'package:blogging_app/Profile/personal_blog.dart';
import 'package:blogging_app/Profile/rate_us.dart';
import 'package:blogging_app/Profile/saved_blogs.dart';
import 'package:blogging_app/helper_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  Helper _helper=Helper();
  var uid;
  String _url="https://png.pngitem.com/pimgs/s/506-5067022_sweet-shap-profile-placeholder-hd-png-download.png";
  String _defaultUrl="https://png.pngitem.com/pimgs/s/506-5067022_sweet-shap-profile-placeholder-hd-png-download.png";
  var _yourblogs=0;
  var _savedblogs=0;
  var _totallikes=0;
  var _name="...";
  var _isLoading=false;

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
        else
        {
          setState(() {
            _url=_defaultUrl;
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
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
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
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
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
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
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
        _helper.show("Opps!! something went wrong");
        _helper.flushbar.show(context);
      });
  }
  Future<void> _updateName() async
  {
    setState(() {
      _isLoading=true;
    });
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'name':_name,
      })
      .catchError((e){
        setState(() {
          _isLoading=false;
        });
        print("error : "+e.toString());
        _helper.show("Opps!! something went wrong");
        _helper.flushbar.show(context);
      });
    setState(() {
      _isLoading=false;
    });
  }
   
  @override
  void initState() {
    super.initState();
    uid=null;
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
    return RaisedButton(        
      elevation: 10.0,
      splashColor: Colors.white,
      highlightColor: Colors.white,
      padding: EdgeInsets.all(8.0),
      highlightElevation: 0.0,
      color: Colors.black,
      shape:RoundedRectangleBorder(
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
      onPressed: (){
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
    return RaisedButton(
      elevation: 10.0,
      splashColor: Colors.white,
      highlightColor: Colors.white,
      padding: EdgeInsets.all(8.0),
      highlightElevation: 0.0,
      color: Colors.black,
      shape:RoundedRectangleBorder(
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
      onPressed:(){
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
    return RaisedButton(
      elevation: 10.0,
      splashColor: Colors.white,
      highlightColor: Colors.white,
      padding: EdgeInsets.all(8.0),
      highlightElevation: 0.0,
      color: Colors.black,
      shape:RoundedRectangleBorder(
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
      onPressed: (){},
    );
  }

  Widget _createRowWithOptions(var prefix, String name, var suffix)
  {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0,vertical: 1.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  prefix,
                  color: Colors.white,
                ),
                SizedBox(width: 8.0,),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white
                  ),
                )
              ],
            ),
            Icon(
              suffix,
              color: Colors.white
            ),
          ],
        ),
      ),
      onTap: () async
      {
        if(name=="Change Password")
        {
          Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ChangePassword()))
          .then((msg){
            if(msg!=null)
            {
              _helper.show(msg);
              _helper.flushbar.show(context);
            }
          });
        }
        if(name=="Send Feedback")
        {
          Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => RateUs()))
          .then((msg){
            if(msg!=null)
            {
              _helper.show(msg);
              _helper.flushbar.show(context);
            }
          });
        }
        if(name=="Contact us")
        {
          var url = 'mailto:bloggenixhelp@gmail.com?subject=''&body=''';
          if (await canLaunch(url)) 
          {
            await launch(url);
          } 
          else 
          {
            _helper.show("Could not launch url");
            _helper.flushbar.show(context);
          }
        }
      },
    );
  }


  Future<void> _showDialogName()
  {
    var value;
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
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
                  labelText: "New Name",
                  hintText: "Enter new name",
                  labelStyle: TextStyle(
                    color: Colors.black
                  ),
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                  counterStyle: TextStyle(
                    color: Colors.black
                  ),
                ),
                cursorColor: Colors.black,
                onChanged: (val){
                  setState(() {
                    value=val;
                  });
                },
                onSubmitted: (value)
                {
                  if(value==null)
                  {
                    return "Name should not be empty";
                  }
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
                  _name=value;
                  // _isLoading=true;
                });
                _updateName();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    _helper.checkMemory();
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: _isLoading==true?
      _helper.spinkit
      :
      Container(
        margin: EdgeInsets.only(top:70.0),
        child: Stack(
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
                      highlightColor: Colors.white,
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
                        _showDialogName();
                      },
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.white,
              highlightColor: Colors.white,
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
                  child: Hero(
                    tag: "profilepic",
                    child:CachedNetworkImage(
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
              ),
              onTap: (){
                Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ChangeProPic(_url)))
                  .then((message){
                    print(message);
                    if(message!=null)
                    {
                      _helper.show(message);
                      _helper.flushbar.show(context);
                      _profileUrl();
                    }                        
                  });
              },
            ),
            DraggableScrollableSheet(
              initialChildSize: (1.0-300/MediaQuery.of(context).size.height),
              maxChildSize: 1.0,
              minChildSize: 0.3,
              builder: (BuildContext context, myscrollController) {
                return SingleChildScrollView(
                  controller: myscrollController,
                  child: Container(
                    padding: EdgeInsets.only(top: 10.0,bottom: 30.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft:Radius.circular(20.0),
                        topRight:Radius.circular(20.0),
                        bottomLeft:Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0), 
                      ),
                    ),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.expand_less,
                          size: 30.0,
                          color: Colors.black,
                        ),
                        SizedBox(height:20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _yourBlogs(),
                            _savedBlogs(),
                            _totalLikes(),
                          ],
                        ),
                        SizedBox(
                          height:30.0,
                        ),
                        _createRowWithOptions(Icons.email,"Change Email",Icons.chevron_right),
                        _createRowWithOptions(Icons.lock_open,"Change Password",Icons.chevron_right),
                        _createRowWithOptions(Icons.rate_review,"Send Feedback",Icons.chevron_right),
                        _createRowWithOptions(Icons.contact_mail,"Contact us",Icons.chevron_right),
                        _createRowWithOptions(Icons.table_chart,"Terms & Conditions",Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
            // SizedBox(height: 16.0,),
            //below image,name and email
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   padding: EdgeInsets.fromLTRB(8.0,30.0,8.0,8.0),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.only(
            //       topLeft: Radius.circular(20.0),
            //       topRight: Radius.circular(20.0),
            //     ),
            //     color: Colors.white
            //   ),
            //   child: Column(
            //     // mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           _yourBlogs(),
            //           _savedBlogs(),
            //           _totalLikes(),
            //         ],
            //       ),
            //       SizedBox(
            //         height:30.0,
            //       ),
            //       _createRowWithOptions(Icons.email,"Change Email",Icons.chevron_right),
            //       _createRowWithOptions(Icons.lock_open,"Change Password",Icons.chevron_right),
            //       _createRowWithOptions(Icons.rate_review,"Rate us",Icons.chevron_right),
            //       _createRowWithOptions(Icons.contact_mail,"Contact us",Icons.chevron_right),
            //       _createRowWithOptions(Icons.table_chart,"Terms & Conditions",Icons.chevron_right),
            //     ],
            //   ),
            // )
      ),
    );
  }
}