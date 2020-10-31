import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blogging_app/helper_functions.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  var _isLoading=false;
  var oldP,newP;
  Helper _helper=Helper();

  void _updatePassword()
  {
    if(newP.toString().length<8)
    {
      _helper.show("The new password must be of length 8.");
      _helper.flushbar.show(context);
    }
    setState(() {
      _isLoading=true;
    });
    AuthCredential authCredential = EmailAuthProvider.credential(
      email: FirebaseAuth.instance.currentUser.email,
      password: oldP,
    );
    FirebaseAuth.instance.currentUser.reauthenticateWithCredential(authCredential)
    .then((_){
      FirebaseAuth.instance.currentUser.updatePassword(newP).then((_){
        Navigator.of(context).pop("Your password has been updated");
      })
      .catchError((e)
      {
        print(e);
        setState(() {
          _isLoading=false;
        });
        if(e.code=='weak-password')
        {
          _helper.show("The password provided is too weak.");
          _helper.flushbar.show(context);
        }
        else
        {
          _helper.show("Something went wrong.Please try again");
          _helper.flushbar.show(context);
        }
      });
    })
    .catchError((e)
    {
      if(e.code=='wrong-password')
      {
        setState(() {
          _isLoading=false;
        });
        _helper.show("Please enter valid old password");
        _helper.flushbar.show(context);
      }
      else
      {
        _helper.show("Something went wrong.Please try again");
        _helper.flushbar.show(context);
      }
    });
  }

  Widget _body()
  {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            TextField(
              style: TextStyle(
                color: Colors.black
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Old Password",
                hintText: "Enter old password",
              ),
              obscureText: true,
              onChanged: (val){
                setState(() {
                  oldP=val;
                });
              },
              onSubmitted: (value)
              {
                if(value==null)
                {
                  return "Password should not be empty";
                }
              },
            ),
            SizedBox(height: 8.0,),
            TextField(
              style: TextStyle(
                color: Colors.black
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "New Password",
                hintText: "Enter new password",  
              ),
              obscureText: true,
              onChanged: (val){
                setState(() {
                  newP=val;
                });
              },
              onSubmitted: (value)
              {
                if(value==null)
                {
                  return "Password should not be empty";
                }
              },
            ),

            SizedBox(height: 30.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: new Text(
                      "Cancel",
                      style: new TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: new Text(
                      "Update",
                      style: new TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: (){
                    _updatePassword();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Password",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),      
      backgroundColor: Colors.black,
      body:_isLoading==true?
      Center(child: _helper.spinkit)
      :
      Center(
        child: SingleChildScrollView(
          child: _body(),
        ),
      )
    );
  }
}