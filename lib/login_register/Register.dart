import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Register extends StatefulWidget 
{
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin 
{
  String _pass;
  String _email;
  String _name;
  bool eye_closed=true,_isLoading=false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SpinKitFadingCircle spinkit = SpinKitFadingCircle(
    color: Colors.blue,
    size: 50.0,
    duration: Duration(milliseconds: 2000),
  );

  var flushbar;
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

  Future<void> _register() async 
  {
    setState(() {
      _isLoading=true;
    });

    await FirebaseAuth.instance
    .createUserWithEmailAndPassword(email: _email, password: _pass)
    .then((_user) async{
      await _user.user.sendEmailVerification()
      .then((_) async{
        show("Verify yourself by clicking on the link sent via mail");
        flushbar..show(context);
        await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.user.uid)
        .set({
          'name': _name,
          'email': _email,
        })
        .then((_) 
        {
          print("Successfully added to database");
          flushbar..show(context);
        })
        .catchError((e){
          print(e);
        });
      })
      .catchError((e){
        print("An error occured while trying to send email verification");
        print(e.message);
        show("An error occured while trying to send email verification");
        flushbar..show(context);
      });
    })
    .catchError((e){
      show("Something has went wrong!! Try again");
      flushbar..show(context);
    });
  }

  Widget _body() 
  {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0,0.0,16.0,16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 100,
                ),
                SizedBox(height: 15.0,),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    hintText: "Enter full name",
                    labelText: "Name",
                    prefixIcon: Icon(
                      Icons.perm_identity_sharp,
                      size: 30.0,
                    ),
                  ),
                  validator: (value) {
                    if (value.toString().length == 0) {
                      return "Name can not be empty!";
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
                SizedBox(height: 15.0,),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    hintText: "Enter gmail id",
                    labelText: "Email",
                    prefixIcon: Icon(
                      Icons.email,
                      size: 30.0,
                    ),
                  ),
                  validator: (value) {
                    if (EmailValidator.validate(value) == false) {
                      return "Enter correct email";
                    }
                  },
                  onChanged: (String value) {
                    _email = value;
                    // print(_email);
                  },
                ),
                SizedBox(height: 15.0,),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    hintText: "Enter Pass",
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.lock,
                      size: 30.0,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        eye_closed==true?
                        Icons.visibility_off
                        :
                        Icons.visibility,
                      ),
                      onPressed: (){
                        setState(() {
                          if(eye_closed==true) eye_closed=false;
                          else eye_closed=true;
                        });
                      },
                    ),
                  ),
                  obscureText: eye_closed,
                  validator: (value) {
                    if (value.toString().length==0) {
                      return "Password can not be empty";
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      _pass = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                FlatButton(
                  color: Colors.blue,
                  splashColor: Colors.white,
                  minWidth: 100.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Register",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10.0,),
                      Icon(
                        Icons.person_add_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      FocusScope.of(context).unfocus();
                      _register().then((_){
                        Navigator.of(context).pop();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Register",textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.white70, BlendMode.softLight),
            image: AssetImage(
              "assets/login_back.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading==true?
        Center(child: spinkit)
        :
        SingleChildScrollView(
          child: _body(),
        ),
      ),
    );
  }
}
