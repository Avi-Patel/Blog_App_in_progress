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
  String _email;
  String _pass;
  bool eye_closed=true,_isLoading=false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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

  // @override
  // void initState() 
  // {
  //   // TODO: implement initState
  //   super.initState();
    
  // }

  // @override
  // void dispose() 
  // {
  //   // TODO: implement dispose
  //   super.dispose();
  // }

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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    hintText: "Enter Email",
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
                  height: 10.0,
                ),
                FlatButton(
                  color: Colors.blue,
                  splashColor: Colors.white,
                  minWidth: 100.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Forgot password? ",
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
                    ),
                    FlatButton(
                      color: Colors.blue,
                      splashColor: Colors.white,
                      minWidth: 100.0,
                      child: Text(
                        "Click Here ",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                      onPressed: (){
                        FocusScope.of(context).unfocus();
                        _forgotpass();
                      } 
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have a account? ",
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
                    ),
                    FlatButton(
                      color: Colors.blue,
                      splashColor: Colors.white,
                      minWidth: 100.0,
                      child: Text(
                        "Register",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Register()));
                      }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) 
  {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Login",textAlign: TextAlign.center),
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
