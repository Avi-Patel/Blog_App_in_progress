import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BlogDetails{
  String _type;
  String _title;
  String _description;
  List<File> _photos=new List();

  BlogDetails({type,title,description,photos});

  void setType(String type)
  {
    this._type=type;
  }
  void setTitle(String title)
  {
    this._title=title;
  }
  void setDescription(String description)
  {
    this._description=description;
  }
  void setPhotos(List<File> photos)
  {
    this._photos=photos;
  }
  void addPhotos(File photo)
  {
    this._photos.add(photo);
  }
  int getSize()
  {
    return _photos.length;
  }
  String getType()
  {
    return _type;
  }
  String getTitle()
  {
    return _title;
  }
  String getDescription()
  {
    return _description;
  }
  List<File> getPhotos()
  {
    return _photos;
  }
}