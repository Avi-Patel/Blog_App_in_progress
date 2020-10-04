import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'VerifyEmail.dart';
import '../main.dart';
import 'Register.dart';

class Login extends StatefulWidget 
{  
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>
{
  String _email="";
  String _pass="";
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

  Future<void> _login() async 
  {
    setState(() {
      _isLoading=true;
    });

    await FirebaseAuth.instance
    .signInWithEmailAndPassword(email: _email, password: _pass)
    .then((_user){
      print(_user.user.email);
      print(_user.user.uid);
      print(_user.user.emailVerified);
      if (_user.user.emailVerified == false) 
      {
        setState(() {
          _isLoading=false;
        });
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => VerifyEmail()));
      } 
      else 
      {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
      }
    })
    .catchError((e){
      print("error" + e.toString());
      setState(() {
        _isLoading=false;
      });
      show("Incorrect email or password!!");
      flushbar..show(context);
    });
  }

  Future<void> _forgotpass() async 
  {
    var ans = EmailValidator.validate(_email.toString());
    if (ans == false) {
      show("Enter correct email");
      flushbar..show(context);
      return;
    }
    print(_email.toString());

    await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: _email.toString())
    .get()
    .then((_snapshot) async{
      if (_snapshot.size == 0) 
      {
        show("Email does not exist in our database.");
        flushbar..show(context);
      }
      else
      {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email)
        .then((_){
          print(
            "Password reset link has been sent to your email. Reset and try login again");
          show(
              "Password reset link has been sent to your email. Reset and try login again");
          flushbar..show(context);
        })
        .catchError((e){
          print(e);
          show("Can not sent link right now. Try again");
          flushbar..show(context);
        });
      }
    })
    .catchError((e){
      show("Opps!! Some error occured. Try again");
      flushbar..show(context);
    });
  }

  @override
  void initState() 
  {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() 
  {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _body() 
  {
    return Card(
      elevation: 5.0,
      color: Colors.black,
      margin: EdgeInsets.all(4.0),
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
                    keyboardType: TextInputType.emailAddress,
                    initialValue: _email,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Enter Email",
                      labelText: "Email",
                      labelStyle: TextStyle(
                        backgroundColor: Colors.white,
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        size: 30.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      enabled: true,
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(color:Colors.red),
                      ),
                      
                    ),
                    validator: (value) {
                      if (EmailValidator.validate(value) == false) {
                        return "Enter correct email";
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Enter Password",
                      labelText: "Password",
                      labelStyle: TextStyle(
                        backgroundColor: Colors.white,
                      ),
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
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                    ),
                    obscureText: eye_closed,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Password can not be empty";
                      }
                      if (value.toString().length < 8) {
                        return "Password should contain atleast 8 characters";
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      GestureDetector(
                        child: Text(
                          "Forgot password? ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          softWrap: true,
                        ),
                        onTap: (){
                          FocusScope.of(context).unfocus();
                          _forgotpass();
                        } ,
                      ),
                      GestureDetector(
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Register()));
                        },
                      ),
                      
                    ],
                  ),

                  SizedBox(
                    height:50.0,
                  ),
                  FlatButton(
                    color: Colors.blue,
                    splashColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height:40.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10.0,),
                        Icon(
                          Icons.login_rounded ,
                          color: Colors.white,
                        )
                      ],
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        FocusScope.of(context).unfocus();
                        _login();
                      }
                    }
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Forgot password? ",
                  //       style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
                  //     ),
                  //     FlatButton(
                  //       color: Colors.blue,
                  //       splashColor: Colors.white,
                  //       minWidth: 100.0,
                  //       child: Text(
                  //         "Click Here ",
                  //         style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                  //       ),
                  //       onPressed: (){
                  //         FocusScope.of(context).unfocus();
                  //         _forgotpass();
                  //       } 
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 15.0,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Don't have a account? ",
                  //       style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
                  //     ),
                  //     FlatButton(
                  //       color: Colors.blue,
                  //       splashColor: Colors.white,
                  //       minWidth: 100.0,
                  //       child: Text(
                  //         "Register",
                  //         style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                  //       ),
                  //       onPressed: () {
                  //         FocusScope.of(context).unfocus();
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(builder: (context) => Register()));
                  //       }
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
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
