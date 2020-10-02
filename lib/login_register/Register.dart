import 'package:blogging_app/login_register/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
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
  SpinKitFadingCircle spinkit = SpinKitFadingCircle(
    color: Colors.blue,
    size: 50.0,
    duration: Duration(milliseconds: 2000),
  );

  var flushbar;
  void show(String s1) 
  {
    flushbar=Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.info_outline,color: Colors.blue,),
      messageText: Text( 
        s1,
        style: TextStyle(color: Colors.white,fontWeight: FontWeight.w300),
      ),
      backgroundColor: Colors.black87,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    );
  }

  Future<void> _register() async 
  {
    setState(() {
      _isLoading=true;
    });
    print(_isLoading);

    await FirebaseAuth.instance
    .createUserWithEmailAndPassword(email: _email, password: _pass)
    .then((_user) async{
      await _user.user.sendEmailVerification()
      .then((_) async{        
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
          setState(() {
            _isLoading=false;
          });
        })
        .catchError((e){
          print(e);
        });
      })
      .catchError((e){
        print("An error occured while trying to send email verification");
        print(e.message);
        show("An error occured while trying to send email verification");
        flushbar.show(context);
      });
    })
    .catchError((signUpError) {
      print(signUpError.code.toString());
      if(signUpError.code.toString() == "email-already-in-use")
      {
        print(signUpError.code.toString());
        show("Email already in use!!");
        flushbar.show(context);
      }
      else if(signUpError.code.toString() == "weak-password")
      {
        show("Password is weak!!");
        flushbar.show(context);
      }
      else if(signUpError.code.toString() == "invalid-email")
      {
        show("email id invalid!!");
        flushbar.show(context);
      }
      else
      {
        show("something went wrong!!");
        flushbar.show(context);
      }
    });    
    print(_isLoading);
  }

  Widget _body() 
  {
    return Card(
      elevation: 5.0,
      color: Colors.black87,
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0,32.0,16.0,32.0),
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
                      fillColor: Colors.white,
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
                      fillColor: Colors.white,
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
                      fillColor: Colors.white,
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
                          print(_isLoading);
                          if(_isLoading==false)
                          {
                            print(_isLoading);
                            Navigator.of(context).pop();
                          }
                          else 
                          {
                            setState(() {
                              _isLoading=false;
                            });
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
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
      appBar: AppBar(
        title: Text(
          "Register",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white24,
      body:_isLoading==true?
      Center(child: spinkit)
      :
      Center(
        child: SingleChildScrollView(
          child: _body(),
        ),
      )
    );
  }
}
