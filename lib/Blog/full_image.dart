import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
// ignore: must_be_immutable
class FullImage extends StatefulWidget {
  String _imageUrl,_type;
  FullImage(this._imageUrl,this._type);
  @override
  _FullImageState createState() => _FullImageState(_imageUrl,_type);
}

class _FullImageState extends State<FullImage> {
  String _imageUrl,_type;
  _FullImageState(this._imageUrl,this._type);
  @override
  Widget build(BuildContext context) {
    return Center(
      child:Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: _type=="link"?
        CachedNetworkImage(
          imageUrl: _imageUrl,
          progressIndicatorBuilder: (context, url, downloadProgress) => 
            CircularProgressIndicator(value: downloadProgress.progress
          ),
          placeholderFadeInDuration: Duration(
            seconds: 1,
          ),
          fadeInDuration: Duration(
            seconds: 1,
          ),
        )
        :
        Image.file(
          io.File(_imageUrl)
        )
      )
    );
  }
}