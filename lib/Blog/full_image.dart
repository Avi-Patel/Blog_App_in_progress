import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullImage extends StatefulWidget {
  String _imageUrl;
  FullImage(this._imageUrl);
  @override
  _FullImageState createState() => _FullImageState(_imageUrl);
}

class _FullImageState extends State<FullImage> {
  String _imageUrl;
  _FullImageState(this._imageUrl);
  @override
  Widget build(BuildContext context) {
    return Center(
      child:Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: CachedNetworkImage(
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
        ),
      )
    );
  }
}