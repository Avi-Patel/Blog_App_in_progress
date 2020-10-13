import 'dart:math';
import 'dart:io' as io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

class ChangeProPic extends StatefulWidget {
  String _url;
  ChangeProPic(this._url);
  @override
  _ChangeProPicState createState() => _ChangeProPicState(_url);
}

class _ChangeProPicState extends State<ChangeProPic> {
  String _url;
  _ChangeProPicState(this._url);

  String uid=FirebaseAuth.instance.currentUser.uid;
  var flushbar;
  bool loading=false;

  SpinKitFadingCircle spinkit = SpinKitFadingCircle(
    color: Colors.blue,
    size: 50.0,
    duration: Duration(milliseconds: 3000),
  );
  
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

  Future<void> _uploadProPic() async
  {
    await ImagePicker.platform.pickImage(source: ImageSource.gallery)
    .then((_image) async{
      // setState(() {
      //   _blog.addPhotos(io.File(_image.path));
      // });  
      StorageReference _storageRef= FirebaseStorage
        .instance
        .ref()
        .child('Profile Pics')
        .child(DateTime.now().millisecondsSinceEpoch.toString());

      final StorageUploadTask _task=_storageRef.putFile(io.File(_image.path));
      StorageTaskSnapshot storageSnapshot = await _task.onComplete;

      storageSnapshot.ref.getDownloadURL()
      .then((value) async
      {
        await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
          "profileUrl" :value.toString()
        })
        .then((_){
          print("Photo uploaded");
          Navigator.of(context).pop("It will reflact in a moment.");
        })
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
    })
    .catchError((e){
      print(e);
      show("You did not selected any photo");
      flushbar..show(context);
    });    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Photo",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: loading==true?
      Center(
        child: spinkit,
      )
      :
      Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // height: MediaQuery.of(context).size.height-200,
                // width: MediaQuery.of(context).size.width,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: NetworkImage(
                //       _url,
                //     ),
                //     fit: BoxFit.fill,
                //   )
                // ),
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  imageUrl: _url,
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

              SizedBox(height: 20.0,),

              FlatButton(
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
                      "Change Photo",
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Icon(
                      Icons.add_a_photo_sharp,
                      color: Colors.white,
                    )
                  ],
                ),
                onPressed: () async{
                  setState(() {
                    loading=true;
                  });
                  _uploadProPic().whenComplete((){
                    setState(() {
                      loading=false;
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ), 
    );
  }
}