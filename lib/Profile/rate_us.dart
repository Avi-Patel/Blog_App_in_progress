import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:blogging_app/helper_functions.dart';

class RateUs extends StatefulWidget {
  @override
  _RateUsState createState() => _RateUsState();
}

class _RateUsState extends State<RateUs> {

  var _rating=1.0;
  String _rateText;
  Helper _helper=Helper();
  bool _isLoading=false;
  Future<void> _submitFeedback() async
  {
    setState(() {
      _isLoading=true;
    });
    bool _isAlreadyrated=false;
    var _previousRating=0.0;
    var uid=FirebaseAuth.instance.currentUser.uid;

    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get()
      .then((doc){
        if(doc.data().containsKey('AppRating'))
        {
          _isAlreadyrated=true;
          _previousRating=doc.data()['AppRating'];
        }
      });
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'AppRating': _rating,
        'Description': _rateText,
      })
      .catchError((e){
        print("error : "+e.toString());
        _helper.show("Opps!! something went wrong");
        _helper.flushbar.show(context);
      });
    await FirebaseFirestore.instance
      .collection('User ratings')
      .doc('rating summery')
      .get()
      .then((docsnapshot) async{
        if(docsnapshot.data()!=null && docsnapshot.data().containsKey('#ratings'))
        {
          var appRating=docsnapshot.data()['App rating'];
          var numOfRatings=docsnapshot.data()['#ratings'];
          var newRating;
          if(_isAlreadyrated)
          {
            newRating=(appRating*numOfRatings-_previousRating+_rating)/numOfRatings;
          }
          else
          {
            newRating=(appRating*numOfRatings+_rating)/(numOfRatings+1);
            numOfRatings++;
          }
          await FirebaseFirestore.instance
            .collection('User ratings')
            .doc('rating summery')
            .update({
              '#ratings': numOfRatings,
              'App rating': newRating
            })
            .then((_){
              Navigator.of(context).pop("Thanks for your feedback :)");
            })
            .catchError((e){
              print("error : "+e.toString());
              _helper.show("Opps!! something went wrong");
              _helper.flushbar.show(context);
            });
        }
        else
        {
          await FirebaseFirestore.instance
            .collection('User ratings')
            .doc('rating summery')
            .set({
              '#ratings': 1,
              'App rating': _rating,
            })
            .then((_){
              Navigator.of(context).pop("Thanks for your feedback :)");
            })
            .catchError((e){
              print("error : "+e.toString());
              _helper.show("Opps!! something went wrong");
              _helper.flushbar.show(context);
            });
        }
      });
    setState(() {
      _isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading==true?
    _helper.spinkit
    :
    Scaffold(
      appBar: AppBar(
        title: Text(
          "Feedback",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(10.0,50.0,10.0,10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RatingBar(
                initialRating: 1,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating=rating;
                  });
                  print(_rating);
                },
              ),
              SizedBox(
                height:30.0
              ),
              Text(
                "Star : ${(_rating).toInt()}/5",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              TextField(
                minLines: 5,
                maxLines: 10,
                onChanged: (value){
                  _rateText=value;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Please describe your experience...",
                  labelText: "Description",
                  labelStyle: TextStyle(
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height:40.0),

              RaisedButton(
                elevation: 10.0,
                color: Colors.blue,
                splashColor: Colors.white,
                padding: EdgeInsets.all(10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child:Text(
                  "Submit Feedback",
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: (){
                  _submitFeedback();                  
                },
              ),
              SizedBox(
                height: 100,
              ),
              Text(
                "Note: If you already gave your feedback earlier then this "
                 "feedback will overwrite previous feedback",
                 style: TextStyle(
                   color:Colors.white,
                   fontSize: 12.0,
                   fontWeight: FontWeight.w500
                 ),
                 textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}