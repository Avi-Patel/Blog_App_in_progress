
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity/connectivity.dart';
class Helper
{
  var flushbar;
  void show(String s1) 
  {
      flushbar = Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.info_outline,color: Colors.blue,size: 30.0,),
      messageText: Text(
        s1,
        style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.white,
    );
  }
  void checkMemory()
  {
    ImageCache _imageCache=PaintingBinding.instance.imageCache;
    if(_imageCache.currentSizeBytes>= 50000000)
    {
      _imageCache.clear();
      _imageCache.clearLiveImages();
    }
  }
  SpinKitFadingFour spinkit = SpinKitFadingFour(
    color: Colors.blue,
    size: 50.0,
    duration: Duration(milliseconds: 2000),
  );

  bool checkConnectivity()
  {
    bool connection=true;
    Connectivity().checkConnectivity().then((value){
      if(value.toString()=="ConnectivityResult.none")
      {
        connection=false;
      }
    })
    .then((_){
      print(connection);
      return connection;
    });
  }
}