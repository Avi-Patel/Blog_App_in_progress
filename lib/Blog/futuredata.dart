import 'package:blogging_app/Blog/full_blog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../helper_functions.dart';
import 'blog_data_model.dart';
import 'package:blogging_app/image_urls.dart';

// ignore: must_be_immutable
class FutureData extends StatefulWidget {
  final FutureDataModel _data;
  String _type,_indicator;
  var _index;
  FutureData(this._data,this._type,this._indicator,this._index);
  @override
  _FutureDataState createState() => _FutureDataState(_data,_type,_indicator,_index);
}

class _FutureDataState extends State<FutureData> {
  final FutureDataModel _data;
  String _type,_indicator;
  var _index;
  _FutureDataState(this._data,this._type,this._indicator,this._index);

  Future<FutureDataModel> _load() async {
    await _data.loadUser();
    return _data;
  }

  Urls _urls=Urls();
  Helper _helper=Helper();
  bool liked=false;
  String type;
  var uid;
  bool  saved=false,_isLoading=false;
  
  Future<void> _checklike() async
  {
    setState(() {
      liked=false;
    });
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
    setState(() {
      saved=false;
    });
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

  Future<void> _deletePersonalBlog() async
  {
    setState(() {
      _isLoading=true;
    });
    // var doc=await FirebaseFirestore.instance
    //   .collection(_type)
    //   .doc(_data.id)
    //   .get();
    // var likes=doc.data()['likes'];
    var likes=_data.likes;
    await FirebaseFirestore.instance
      .collection('users')
      .get()
      .then((snapshot){
        snapshot.docs.forEach((user) {
          if(user.data().containsKey(_type))
          {
            List ids=user.data()[_type];
            ids.forEach((element) async{
              if(element==_data.id) 
              {
                await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.id)
                  .update({
                    _type : FieldValue.arrayRemove([_data.id]),
                    'Saved Blogs' : FieldValue.increment(-1),
                  })
                  .catchError((e){
                    print("error : " +e.toString());
                    _helper.show("Opps!! Something went wrong");
                    _helper.flushbar.show(context);
                    setState(() {
                      _isLoading=false;
                    });
                  });
              }
            });
          } 
        });
      })
      .catchError((e){
        print("error : " +e.toString());
        _helper.show("Opps!! Something went wrong");
        _helper.flushbar.show(context);
        setState(() {
          _isLoading=false;
        });
      });
    for(int i=0;i<_data.photosUrl.length;i++)
    {
      FirebaseStorage.instance
        .getReferenceFromUrl(_data.photosUrl[i])
        .then((res) {
          res.delete().then((res) {
            print("Deleted!");
            Navigator.of(context).pop("Photo deleted:).It will reflact in a moment.");
          })
          .catchError((e){
            print(e);
            _helper.show("Opps!! Some error occured. Try again");
            _helper.flushbar..show(context);
          });
        })
        .catchError((e){
          print(e);
          _helper.show("Opps!! Some error occured. Try again");
          _helper.flushbar..show(context);
        });
    }
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'Total Likes': FieldValue.increment(-likes),
        'Your Blogs' : FieldValue.increment(-1),
      });
    await FirebaseFirestore.instance
      .collection(_type)
      .doc(_data.id)
      .delete();
    setState(() {
      _isLoading=false;
    });
  }

  Future<void> _deleteSavedBlog() async
  {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'Saved Blogs': FieldValue.increment(-1),
        _type : FieldValue.arrayRemove([_data.id]),
      })
      .then((_){
        print("Blog removed from your saved blogs");
        _helper.show("Blog removed from your saved blogs");
        _helper.flushbar.show(context);
      })
      .catchError((e)
      {
        print("error : " +e.toString());
        _helper.show("Opps!! Something went wrong");
        _helper.flushbar.show(context);
      });
  }

  Future<void> _showDialog()
  {
    return showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: Text(
          "Do you want to delete this blog permanently? It can not be recovered later.",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
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
                "No",
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
                "Yes",
                style: new TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () async{
              _deletePersonalBlog();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    uid=null;
    super.initState();
    print(_data.minsRead);
    if(FirebaseAuth.instance.currentUser!=null)
    {
      setState(() {
        uid=FirebaseAuth.instance.currentUser.uid.toString();
      });
    }
    type=_type.replaceAll(" ", "_");
    type=type.toLowerCase();
    print(type);

    if(uid!=null)
    {
      _checklike();
      print(liked);
      _checksave();
      print(saved);
    }
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _helper.checkMemory();
    return _isLoading==true?
    _helper.spinkit
    :
    Padding(
      padding: const EdgeInsets.all(4.0),
      child: FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<FutureDataModel> message) {
          if (!message.hasData)
            return Container();
          return Column(
            children: [
              new Material(
                elevation: 10.0,
                color: Colors.white.withOpacity(0.0),
                child: new InkWell(
                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                  splashColor: Colors.white,
                  highlightColor: Colors.white,
                  onTap: (){
                    Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (context) => FullBlog(_data,_type,_indicator,_index),

                      ))
                      .then((_){
                        if(uid!=null)
                        {
                          _checklike();
                          _checksave();
                        }
                      });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width/3,
                        height: MediaQuery.of(context).size.width/3,
                        child: _data.photosUrl.length==0?
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl:_urls.urls[_index],
                              fit: BoxFit.fill,
                            ),
                          )
                          :
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: _data.photosUrl[0],
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
                                    
                      SizedBox(width: 8.0,),
                      Expanded(
                        child: Column(
                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _data.title,                                
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                                fontStyle: FontStyle.normal
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            SizedBox(height: 4.0,),
                            Row(
                              children: [
                                Text(
                                  "${_data.minsRead}"+" min read ",
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
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.normal
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  // name.containsKey(doc.data()['userId'])? "By "+name[doc.data()['userId']]: "By xyz",
                                  "By "+_data.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.normal
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
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
                            
                            SizedBox(height: 8.0,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if(_indicator!="saved")
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      saved==false? 
                                      Icons.bookmark_border
                                      :
                                      Icons.bookmark,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: (){
                                    _saveBlog();
                                  },
                                ),
                                SizedBox(width: 4.0,),
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.share,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: (){},
                                ),
                                SizedBox(width: 4.0,),
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      liked==false? 
                                      Icons.favorite_border
                                      :
                                      Icons.favorite,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () async{
                                    _updatelikes();
                                  }
                                ),
                                SizedBox(width: 4.0,),
                                Text(
                                  "${_data.likes}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                    fontStyle: FontStyle.normal
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if(_indicator=="personal")
              GestureDetector(
                child: Icon(                  
                  Icons.delete_sharp,
                  size: 32.0,
                  color: Colors.red,
                ),
                onTap: () {
                  _showDialog();
                }
              ),

              Divider(
                color: Colors.white,
                height: 20.0,
              ),

            ],
          );
        },
      ),
    );
  }
}
