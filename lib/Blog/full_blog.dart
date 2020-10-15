import 'dart:ui';
import 'package:blogging_app/Blog/blog_data_model.dart';
import 'package:blogging_app/Blog/full_image.dart';
import 'package:blogging_app/helper_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:blogging_app/image_urls.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:url_launcher/url_launcher.dart';



// ignore: must_be_immutable
class FullBlog extends StatefulWidget {
  FutureDataModel _data;
  String _type,_indicator;
  var _index;
  FullBlog(this._data,this._type,this._indicator,this._index);
  @override
  _FullBlogState createState() => _FullBlogState(_data,_type,_indicator,_index);
}

class _FullBlogState extends State<FullBlog> {
  FutureDataModel _data;
  String _type,_indicator;
  var _index;
  _FullBlogState(this._data,this._type,this._indicator,this._index);

  Urls _urls= Urls();
  Helper _helper=Helper();
  bool liked=false;
  String type;
  var uid;
  bool  saved=false;
  var _rating=1.0;
  bool _hasrated=false;
  
  Future<void> _checklike() async
  {
    FirebaseFirestore
      .instance
      .collection(_type)
      .doc(_data.id)
      .get()
      .then((document){
        if(document.data().containsKey('likeIds'))
        {
          document.data()['likeIds'].forEach((element) {
            print(element);
            if(element.toString()==uid)
            {
              setState(() {
                liked=true;
              });
              print("liked "+liked.toString());
            }
          });
        }
      });
  }

  Future<void> _updatelikes() async
  {
    if(uid==null)
    {
      _helper.show("You are not logged in!");
      _helper.flushbar..show(context);
      return;
    }
    if(liked==false)
    {
      await FirebaseFirestore
      .instance
      .collection(_type)
      .doc(_data.id)
      .update({
        'likes':_data.likes+1,
        'likeIds':FieldValue.arrayUnion([uid]),
      }).then((value){
        setState(() {
          _data.likes=_data.likes+1;
          liked=true;
        });
      });
      await FirebaseFirestore.instance
      .collection('users')
      .doc(_data.userId)
      .update({
        'Total Likes': FieldValue.increment(1),
      })
      .catchError((e){
        print(e);
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
      });
    }
    else
    {
      await FirebaseFirestore
      .instance
      .collection(_type)
      .doc(_data.id)
      .update({
        'likes':_data.likes-1,
        'likeIds': FieldValue.arrayRemove([uid]),
      }).then((value){
        setState(() {
          _data.likes=_data.likes-1;
          liked=false;
        });
      });
      await FirebaseFirestore.instance
      .collection('users')
      .doc(_data.userId)
      .update({
        'Total Likes': FieldValue.increment(-1),
      })
      .catchError((e){
        print(e);
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
      });
    }
  }

  Future<void> _checksave() async
  {
    FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .get()
      .then((document){
        if(document.data().containsKey(_type)==true)
        {
          List ids=document.data()[_type];
          ids.forEach((element) {
            print(element);
            if(element.toString()==_data.id.toString())
            {
              setState(() {
                saved=true;
              });
              print("saved "+saved.toString());
            }
          });
        }
      });
  }

  Future<void> _saveBlog() async
  {
    if(uid==null)
    {
      _helper.show("You are not logged in!");
      _helper.flushbar..show(context);
      return;
    }
    if(saved==false)
    {
      await FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .update({
        _type : FieldValue.arrayUnion([_data.id]),
      }).then((value){
        setState(() {
          saved=true;
        });
      });
      await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'Saved Blogs': FieldValue.increment(1),
      })
      .catchError((e){
        print(e);
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
      });
    }
    else
    {
      await FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .update({
        _type: FieldValue.arrayRemove([_data.id]),
      }).then((value){
        setState(() {
          saved=false;
        });
      });
      await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'Saved Blogs': FieldValue.increment(-1),
      })
      .catchError((e){
        print(e);
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
      });
    }
  }

  Future<void> _checkrated() async
  {
    FirebaseFirestore
      .instance
      .collection(_type)
      .doc(_data.id)
      .get()
      .then((document){
        if(document.data().containsKey('ratingIds'))
        {
          document.data()['ratingIds'].forEach((element) {
            print(element);
            if(element.toString()==uid)
            {
              setState(() {
                _hasrated=true;
              });
              print("rated "+_hasrated.toString());
            }
          });
        }
      });
  }
  Future<void> _updateRating() async
  {
    await FirebaseFirestore.instance
      .collection(_type)
      .doc(_data.id)
      .update({
        'ratingIds': FieldValue.arrayUnion([uid]),
      })
      .then((_) async{
        await FirebaseFirestore.instance
        .collection(_type)
        .doc(_data.id)
        .update({
          'star': FieldValue.increment(_rating),
          '#ratings': FieldValue.increment(1),
        })
        .then((_){
          setState(() {
            _data.star=_data.star+_rating;
            _data.numOfRating=_data.numOfRating+1;
            _hasrated=true;
          });
        })
        .catchError((e){
          print("error"+e.toString());
          _helper.show("Opps!! Something went wrong");
          _helper.flushbar.show(context);
        });
      }); 
  }

  Future<String> _profileUrl() async
  {
    String _url;
    await FirebaseFirestore.instance
      .collection('users')
      .doc(_data.userId)
      .get()
      .then((value){
        print(value.data().containsKey('profileUrl'));
        value.data().containsKey('profileUrl')?        
          _url=value.data()['profileUrl'].toString()
          :
          _url="https://png.pngitem.com/pimgs/s/506-5067022_sweet-shap-profile-placeholder-hd-png-download.png";
        print(_url);
      });
    print(_url);
    return _url;
  }

  Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    _helper.show("Could not launch url");
    _helper.flushbar.show(context);
  }
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
    type=_type.replaceAll(" ", "_");
    type=type.toLowerCase();
    print(type);

    setState(() {
      print("description : "+_data.description);
      _data.description=_data.description.replaceAll('<p><br><br></p>', '');
      print("description : "+_data.description);
    });
    if(uid!=null)
    {
      _checklike();
      _checksave();
      _checkrated();
    }
  }
  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _showDialog()
  {
    return showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: Column(
          children: [
            RatingBar(
              initialRating: 1,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating=rating;
                });
                print(_rating);
              },
            ),
          ],
        ),

        backgroundColor: Colors.black,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
        actions: <Widget>[
          new SizedBox(
            height: 30.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: FlatButton(
                child: new Text(
                  "Cancel",
                  style: new TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
                ),
                onPressed:(){
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          new SizedBox(
            height: 30.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: FlatButton(
                child: new Text(
                  "Submit",
                  style: new TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
                ),
                onPressed:(){
                  _updateRating().whenComplete((){
                    Navigator.of(context).pop();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Container(
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        image:CachedNetworkImageProvider(
                          _urls.urls[_index],
                        ),
                        fit: BoxFit.fill,
                      )
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:175.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(_indicator!="saved")
                      Container(
                        child: IconButton(
                          icon: Icon(
                            saved==false? 
                            Icons.bookmark_border
                            :
                            Icons.bookmark,
                          ),
                          color: Colors.white,
                          onPressed: (){
                            _saveBlog();
                          }
                        ),
                      ),
                      Container(
                        child: IconButton(
                          icon: Icon(Icons.share),
                          color: Colors.white,
                          onPressed: (){

                          }
                        ),
                      ),
                      Container(
                        child: IconButton(
                          icon: Icon(
                            liked==false? 
                            Icons.favorite_border
                            :
                            Icons.favorite,
                            size: 24.0,
                            color: Colors.white,
                          ),
                          color: Colors.white,
                          onPressed: (){
                            _updatelikes();
                          },
                        ),
                      ),
                    ],
                  )
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 8.0),
              child: Text(
                // "Dknwd wj qd qkd qwjndq, dnw dwkj bdew ejkde dewj dewddwdwqadwdd",
                _data.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                  fontStyle: FontStyle.normal
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(8.0,4.0,8.0,4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white38,
                    ),
                    child: Text(
                      _type,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                        fontStyle: FontStyle.normal
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _data.numOfRating>0?
                          "${(_data.star/_data.numOfRating).toString().substring(0,3)}"
                          :
                          "0.0",
                          // "4.5",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                            fontStyle: FontStyle.normal
                          ),
                        ),
                        Icon(
                          Icons.star,
                          size: 20.0,
                          color: Colors.black,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            ListTile(
              leading: FutureBuilder(
                future: _profileUrl(),
                initialData: "https://png.pngitem.com/pimgs/s/506-5067022_sweet-shap-profile-placeholder-hd-png-download.png",
                builder: (context,AsyncSnapshot<String> url){
                  print(url);
                  return CachedNetworkImage(
                    // "assets/tech_blogs.jpg",
                    imageUrl:url.data,
                    // fit: BoxFit.fill,
                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                      CircularProgressIndicator(value: downloadProgress.progress
                    ),
                    placeholderFadeInDuration: Duration(
                      seconds: 1,
                    ),
                    fadeInDuration: Duration(
                      seconds: 1,
                    ),
                  );
                },
                
              ),
              title: Text(
                // "Avi Patel",
                _data.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                  fontStyle: FontStyle.normal
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    "${(_data.description.length~/100)+1}"+" min read ",
                    // "3"+" min read ",
                    style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                    fontStyle: FontStyle.normal
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 8.0,
                  ),
                  Text(
                    " ${_data.date}",
                    // " 10/10/2000",
                    style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                    fontStyle: FontStyle.normal
                    ),
                  ),
                ],
              ),
              onTap: (){},
            ),

            _data.photosUrl.length>0?
            SizedBox(
              height: MediaQuery.of(context).size.width*3/4,
              child: ListView.builder(
                itemCount: _data.photosUrl.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context,index){
                  return InkWell(
                    splashColor: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width*3/4,
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child:ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: _data.photosUrl[index],
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
                      .push(MaterialPageRoute(builder: (context) => FullImage(_data.photosUrl[index],"link")));
                    },
                  );
                },
              ),
            )
            :SizedBox(height: 0.0,),

            SizedBox(height: 16.0,),
            Container(
              margin: EdgeInsets.all(8.0),
              alignment: Alignment.topLeft,
              child: 
              // Text(
              //   // "nasknas csakjc kjsd skd \nwqk\nj d djksw diwjdns djwsd sjcjc\n"
              //   // +"sncjkswc dsjkc kswdcs kackc wn DKKk XWDWQEFE",
              //   _data.description,
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 14.0,
              //     fontWeight: FontWeight.w400,
              //     fontStyle: FontStyle.normal
              //   ),
              // ),
              Html(
                data: """
                  <div>${_data.description}</div>
                """,
                style: {
                  "div":Style(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                },
                 onLinkTap: (url) async
                 {
                   await _launchURL(url);
                 },
                onImageTap: (src){
                  // Navigator.of(context)
                  //   .push(MaterialPageRoute(builder: (context) => FullImage(src,"file")));
                },
              )
            ),

            SizedBox(height: 32.0,),
            _hasrated==false?
            GestureDetector(
              child: Text(
                "Rate this Blog",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  fontSize: 16.0,
                  color: Colors.white
                ),
              ),
              onTap: (){
                if(uid==null)
                {
                  _helper.show("You are not logged in!");
                  _helper.flushbar.show(context);
                }
                else{
                  _showDialog();
                }
              },
            )
            :
            Text(
              "You have rated this blog",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13.0,
                color: Colors.white
              ),
            ),
            SizedBox(height: 32.0,),
          ],
        ),
      ),
    );
  }
}