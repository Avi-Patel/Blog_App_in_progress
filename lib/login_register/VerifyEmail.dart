import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper_functions.dart';

class VerifyEmail extends StatefulWidget 
{
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> 
{

  Helper _helper= Helper();

  Future<void> _sentmail(BuildContext context) async 
  {
    User _user = FirebaseAuth.instance.currentUser;
    try 
    {
      await _user.sendEmailVerification();
      Navigator.of(context).pop();
    } 
    catch (e) 
    {
      _helper.show("An error occured while trying to send email verification");
      _helper.flushbar..show(context);
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email",textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "It seems you did not verify your email through" +
                "\n" +
                "verification link sent in email." +
                "\n" +
                " Click on 'Send Again' to get link again or click on 'Cancel'",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlineButton(
                    child: Text(
                      "Send Again",
                    ),
                    color: Colors.green,
                    onPressed: () => _sentmail(context),
                  ),
                  OutlineButton(
                    child: Text(
                      "Cancel",
                    ),
                    color: Colors.green,
                    onPressed: () => Navigator.of(context).pop(
                      "Hey, verify your email via link sent in the mail and the login",
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
