import 'package:cloud_firestore/cloud_firestore.dart';

class FutureDataModel {
  String description;
  String userId;
  List<dynamic> photosUrl=new List();
  String title;
  String name;
  String id;
  var star;
  var numOfRating;
  var date;
  var likes;

  FutureDataModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.description = snapshot.data()['description'];
    this.userId = snapshot.data()['userId'];
    this.photosUrl = snapshot.data()["photosUrl"];
    this.title=snapshot.data()['title'];
    this.id=snapshot.id;
    this.star=snapshot.data()['star'];
    this.numOfRating=snapshot.data()['#ratings'];
    this.date=snapshot.data()['date'];
    this.likes=snapshot.data()['likes'];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "description": this.description,
      "photosUrl": this.photosUrl,
      "userId": this.userId,
      "title": this.title,
      "name": this.name,
      "star": this.star,
      "#ratings": this.numOfRating,
      "date": this.date,
      "likes": this.likes,
    };
    return map;

  }

  Future<void> loadUser() async {
    await FirebaseFirestore.instance.collection('users').doc(this.userId).get().then((value){
      this.name=value.data()['name'];
    });
  }

}