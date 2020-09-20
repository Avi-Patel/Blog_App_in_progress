import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BlogStoreDetails{
  String _uid;
  String _title;
  String _description;
  List<String> _photosUrl=new List();

  BlogStoreDetails(String uid,String title,String description,List<String> photosUrl)
  {
    this._uid=uid;
    this._title=title;
    this._description=description;
    this._photosUrl=photosUrl;
  }
}