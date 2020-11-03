import 'dart:io' as io;
import 'package:blogging_app/helper_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ChangeProPic extends StatefulWidget {
  String _url;
  ChangeProPic(this._url);
  @override
  _ChangeProPicState createState() => _ChangeProPicState(_url);
}

class _ChangeProPicState extends State<ChangeProPic> {
  String _url;
  _ChangeProPicState(this._url);

  Helper _helper=Helper();
  String uid=FirebaseAuth.instance.currentUser.uid;
  bool loading=false;
  String _defaultUrl="https://png.pngitem.com/pimgs/s/506-5067022_sweet-shap-profile-placeholder-hd-png-download.png";
  

  Future<void> _uploadProPic() async
  {
    // ignore: invalid_use_of_visible_for_testing_member
    await ImagePicker.platform.pickImage(source: ImageSource.gallery)
    .then((_image) async{ 
      if(_url!=_defaultUrl)
      {
        FirebaseStorage.instance
          .getReferenceFromUrl(_url)
          .then((res) {
            res.delete().then((res) {
              print("Deleted!");
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
          _helper.show("Opps!! Some error occured. Try again");
          _helper.flushbar.show(context);
        });
      })
      .catchError((e){
        print(e);
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar.show(context);
      });
    })
    .catchError((e){
      print(e);
      _helper.show("You did not selected any photo");
      _helper.flushbar..show(context);
    });    
  }

  Future<void> _deleteProPic() async
  {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'profileUrl': FieldValue.delete()
      })
      .catchError((e){
        print(e);
        _helper.show("Opps!! Some error occured. Try again");
        _helper.flushbar..show(context);
      });

    FirebaseStorage.instance
      .getReferenceFromUrl(_url)
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
        child: _helper.spinkit,
      )
      :
      Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    elevation: 10.0,
                    color: Colors.blue,
                    splashColor: Colors.white,
                    shape: RoundedRectangleBorder(
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
                  if(_url!=_defaultUrl)
                  RaisedButton(
                    elevation: 10.0,
                    color: Colors.blue,
                    splashColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Remove Photo",
                          style:
                              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                        )
                      ],
                    ),
                    onPressed: () async{
                      setState(() {
                        loading=true;
                      });
                      _deleteProPic().whenComplete((){
                        setState(() {
                          loading=false;
                        });
                      });
                    },
                  ),
                  
                ],
              )
            ],
          ),
        ),
      ), 
    );
  }
}