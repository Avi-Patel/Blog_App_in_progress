import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../helper_functions.dart';
import 'Blog_details.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:html_editor/html_editor.dart';

class BlogTile extends StatefulWidget {
  @override
  _BlogTileState createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile> {

  ScrollController _scrolctrl = ScrollController();
  GlobalKey<HtmlEditorState> keyEditor = GlobalKey();
  BlogDetails _blog=new BlogDetails();
  Helper _helper=Helper();
  String result = "";
  bool _isLoading=false;
  final GlobalKey<FormState> _fbKey1 = GlobalKey<FormState>();
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

  var _docId;
  Future<bool> _addData() async
  {
    User _user= FirebaseAuth.instance.currentUser;    
    Map<String,dynamic> data={
      'userId': _user.uid.toString(),
      'title': _blog.getTitle(),
      'description': _blog.getDescription(),
      'minsRead': _blog.getMinsRead().length~/500+1,
      'photosUrl': [],
      '#ratings':0,
      'star': 0.0,
      'date': "${DateTime.now().day}"+"/"+"${DateTime.now().month}"+"/"+"${DateTime.now().year}",
      'likes': 0,
    };
    _docId=DateTime.now().microsecondsSinceEpoch.toString();

    await FirebaseFirestore.instance
    .collection('${_blog.getType()}')
    .doc(_docId)
    .set(data)
    .then((value) async{
      print("data added");
      await FirebaseFirestore.instance
      .collection('users')
      .doc(_user.uid.toString())
      .update({
        'Your Blogs': FieldValue.increment(1),
      })
      .catchError((e){
        print(e);
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
        return false;  
      });
    })
    .catchError((e){
      print(e);
      _helper.show("Opps!! Some error occured. Try again");
      _helper.flushbar..show(context);
      return false;
    });
    return true;
  }

  Future<void> _upload() async
  {
    for(var element in _blog.getPhotos())
    {
      StorageReference _storageRef= FirebaseStorage
        .instance
        .ref()
        .child('${_blog.getType()}')
        .child('${_blog.getTitle()}'+DateTime.now().microsecondsSinceEpoch.toString());

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
        .then((value){
          print("added value");
        })
        .catchError((e){
          print(e);
          _helper.show("Opps!! Some error occured. Try again");
          _helper.flushbar.show(context);
        });
      })
      .catchError((e){
        print(e);
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar.show(context);
      });
    }
  }

  Future<void> _addphotoToList() async
  {
    // ignore: invalid_use_of_visible_for_testing_member
    await ImagePicker.platform.pickImage(source: ImageSource.gallery)
    .then((_image){
      setState(() {
        _blog.addPhotos(io.File(_image.path));
      });  
    })
    .catchError((e){
      print(e);
      _helper.show("You did not selected any photo");
      _helper.flushbar..show(context);
    });
  }

  Widget _addphoto()
  {
    return GestureDetector(
      child: Container(
        height: 150,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
      padding: EdgeInsets.fromLTRB(4.0,8.0,4.0,0.0),
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

  String _removeImgText(String s)
  {
    bool go=true;
    // print(s.length);;
    int i=0;
    while(go)
    { 
      if(s.contains("<img") && s.contains(".jpg\">"))
      {
        int r=s.indexOf("<img");
        int l=s.indexOf(".jpg\">");
        s=s.replaceRange(r, l+6, "");
        print("r="+r.toString()+", l="+l.toString());
      }
      else go=false;
      i=i+1;
      if(i==10) break;
    }
    s=s.replaceAll("<p>", "");
    s=s.replaceAll("</p>", "");
    s=s.replaceAll("<b>", "");
    s=s.replaceAll("</b>", "");
    s=s.replaceAll("<i>", "");
    s=s.replaceAll("</i>", "");
    s=s.replaceAll("<br>", "");
    s=s.replaceAll("<u>", "");
    s=s.replaceAll("</u>", "");
    return s;
  }

  Widget _body()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Form(
            key: _fbKey1,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    fillColor: Colors.white,
                    hintText: "Give title of few words...",
                    labelText: "Title",
                    prefixIcon: Icon(
                      Icons.title,
                      size: 30.0,
                    )
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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

        _addText("Add your photos for gallery below",16.0,Colors.blue),

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
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.fromLTRB(4.0,8.0,4.0,0.0),
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
        _addText(
          "You have added all 5 photos!! Drag a photo left/right inorder to delete:)",
          10.0,Colors.red
        )
        : _addphoto(),

        _blog.getSize()<5?
        _addText(
          "You can add upto 5 photos. Drag a photo left/right inorder to delete:)",
          10.0,Colors.blue
        )
        : SizedBox(
          height: 0.0,          
        ),

        SizedBox(height:10.0),

        Padding(
          padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,80.0),
          child: HtmlEditor(
            hint: "write description here...",
            //value: "text content initial, if any",
            key: keyEditor,
            height: 500,
          ),
        ),

        SizedBox(
          height: 200.0,
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isLoading!=true?
      AppBar(
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
      )
      :AppBar(),
      floatingActionButton: _isLoading!=true?
      RaisedButton.icon(
        color: Colors.green,
        elevation: 10.0,
        splashColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 16.0),
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        icon: Icon(
          Icons.upload_sharp,
          color: Colors.white
        ),
        label: Text(
          "Upload",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        onPressed:() async{
          var result=await keyEditor.currentState.getText();
          print(result);
          String removed=_removeImgText(result);
          print(removed);
          if(result.toString().length==0)
          {
            _helper.show("description can not be empty");
            _helper.flushbar.show(context);
          }
          else if(_isLoading==false && _fbKey1.currentState.validate())
          {
            _blog.setDescription(result.toString());
            _blog.setMinsRead(removed);
            print(_blog.getDescription());
            setState(() {
              _isLoading=true;
            });
            var answer=await _addData();
            if(answer==true)
            {
              await _upload();
              Navigator.of(context).pop("It may take a while to reflact on home page");  
            }
            else
            {
              setState(() {
                _isLoading=false;
              });
            }              
          }
        }
      )
      :Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      body:_isLoading==true?
      Center(child: _helper.spinkit,)
      :
      PrimaryScrollController(
        controller: _scrolctrl,
        child: CupertinoScrollbar(
          thickness: 20.0,
          thicknessWhileDragging: 16.0,
          radius: Radius.circular(10.0),
          radiusWhileDragging: Radius.circular(10.0),
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: _body(),
          ),
        ),
      ),
    );
  }
}