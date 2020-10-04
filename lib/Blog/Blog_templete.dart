import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'Blog_details.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:flushbar/flushbar.dart';

class BlogTile extends StatefulWidget {
  @override
  _BlogTileState createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile> {
  @override

  BlogDetails _blog=new BlogDetails();
  bool _isLoading=false;
  final GlobalKey<FormState> _fbKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _fbKey2 = GlobalKey<FormState>();
  SpinKitFadingCircle spinkit = SpinKitFadingCircle(
    color: Colors.blue,
    size: 50.0,
    duration: Duration(milliseconds: 3000),
  );
  final types=[
    "Tech Blogs",
    "Non-Tech Blogs",
    "Interview Exps",
    "Internship Exps",
    "Food Blogs",
    "Travel Blogs",
    "Political Blogs",
    "Business Blogs"
  ];
  var flushbar;
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

  var _docId;
  bool _addData()
  {
    User _user= FirebaseAuth.instance.currentUser;    
    Map<String,dynamic> data={
      'userId': _user.uid.toString(),
      'title': _blog.getTitle(),
      'description': _blog.getDescription(),
      'photosUrl': [],
    };
    _docId=DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseFirestore.instance
    .collection('${_blog.getType()}')
    .doc(_docId)
    .set(data)
    .then((value){
      print("data added");
    })
    .catchError((e){
      print(e);
      show("Opps!! Some error occured. Try again");
      flushbar..show(context);
      return false;
    });
    return true;
  }

  Future<void> _upload() async
  {
    _blog.getPhotos().forEach((element) async
    {
      StorageReference _storageRef= FirebaseStorage
        .instance
        .ref()
        .child('${_blog.getType()}')
        .child('${_blog.getTitle()}'+DateTime.now().millisecondsSinceEpoch.toString());

      final StorageUploadTask _task=_storageRef.putFile(element);
      StorageTaskSnapshot storageSnapshot = await _task.onComplete;

      storageSnapshot.ref.getDownloadURL()
      .then((value) async
      {
        await FirebaseFirestore.instance
        .collection('${_blog.getType()}')
        .doc(_docId)
        .update({
          "photosUrl" :FieldValue.arrayUnion([value.toString()])
        })
        .then((value){print("added value");})
        .catchError((e){
          print(e);
          show("Opps!! Some error occured. Try again");
          flushbar.show(context);
        });
      })
      .catchError((e){
        print(e);
        show("Opps!! Some error occured. Try again");
        flushbar.show(context);
      });
    });
  }

  Future<void> _addphotoToList() async
  {
    await ImagePicker.platform.pickImage(source: ImageSource.gallery)
    .then((_image){
      setState(() {
        _blog.addPhotos(io.File(_image.path));
      });  
    })
    .catchError((e){
      print(e);
      show("Opps!! Some error occured. Try again");
      flushbar..show(context);
    });
  }

  Widget _addphoto()
  {
    return GestureDetector(
      child: Container(
        height: 150,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child:Icon(
          Icons.add_a_photo_sharp,
          color: Colors.blue,
          size: 30.0,
        ),
      ),
      onTap: (){
        _addphotoToList();
      },
    );
  }

  Widget _addText(String text,double size,Color clr)
  {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0,8.0,8.0,0.0),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: clr,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize:size,
          ),
        ),
      ),
    );
  }

  void _deletephoto(int i)
  {
    setState(() {
      _blog.getPhotos().removeAt(i);  
    });
  }



  Widget _body()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _fbKey1,
            autovalidate: true,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                  ),
                  child: DropDownFormField(
                    value: _blog.getType(),
                    titleText: "Blog Type",
                    required: true,
                    hintText: 'Please choose blog type',
                    onChanged: (value) {
                      setState(() {
                        _blog.setType(value);
                      });
                    },
                    validator: (value){
                      if(value==null) {return "Type should not be empty!";}
                    },
                    dataSource: types.map((String v){
                        return {
                          "display": v,
                        "value": v,
                        };
                      }).toList(),
                      textField: 'display',
                      valueField: 'value',
                  ),
                ),

                SizedBox(height: 10.0,),    

                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    hintText: "Give title of few words...",
                    labelText: "Title",
                    prefixIcon: Icon(
                      Icons.title,
                      size: 30.0,
                    )
                  ),
                  autovalidate: true,
                  validator: (value) {
                    if (value==null) {return "Title should not be empty";}
                  },
                  onChanged: (value) {
                    setState(() {
                      _blog.setTitle(value);
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        _addText("Add your photos below",16.0,Colors.blue),

        _blog.getSize() !=0?  ListView.builder(
          itemCount: _blog.getSize(),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context,i)
          {
            return Dismissible(
              key: Key(_blog.getPhotos()[i].toString()),
              child: GestureDetector(
                child: new Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.fromLTRB(8.0,8.0,8.0,0.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child:ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      _blog.getPhotos()[i],
                      fit: BoxFit.fill,
                    ),
                  )
                ),
              ),
              onDismissed: (direction){
                _deletephoto(i);
              },
            );
          }
        )
        :SizedBox(height: 1.0,),


        _blog.getSize()==5? 
        _addText("You have added all 5 photos!! Drag a photo left/right inorder to delete:)",10.0,Colors.red): _addphoto(),

        SizedBox(height:10.0),

        Padding(
          padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,80.0),
          child: Form(
            key: _fbKey2,
            child: TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                hintText: "Write description here",
                labelText: "Description",
                prefixIcon: Icon(
                  Icons.description,
                  size: 30.0,
                ),

              ),
              maxLength: 1000,
              maxLines: null,
              validator: (value) {
                if (value.toString().length==0) {
                  return "Description should be atleast 100 words long.";
                }
              },
              onChanged: (value) {
                setState(() {
                  _blog.setDescription(value);
                });
              },
            ),
          ),
        )

      ],
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Create Your "),
            Text(
              "Blog",
              style: TextStyle(color:Colors.blue),
            ),
          ],
        ),
        leading: Container(),
      ),
      floatingActionButton: FlatButton(
        color: Colors.green,
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
              "Upload",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10.0,),
            Icon(
              Icons.upload_sharp,
              color: Colors.white,
            )
          ],
        ),
        onPressed: () {
          if(_fbKey1.currentState.validate() && _fbKey2.currentState.validate())
          {
            setState(() {
              _isLoading=true;
            });
            var answer=_addData();
            if(answer==true)
            {
              _upload();
              show("It may take a while to reflact on home page");
              flushbar.show(context)
              .then((_) {
                Navigator.of(context).pop();  
              });
            }              
          }
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      body:_isLoading==true?
      Center(child: spinkit,)
      :
      SingleChildScrollView(
        physics: ScrollPhysics(),
        child: _body()
      ),
    );
  }
}