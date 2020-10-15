import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helper_functions.dart';
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
  Helper _helper=Helper();
  String _email="";
  String _pass="";
  bool _eyeClosed=true,_isLoading=false;
  final _formKey = GlobalKey<FormState>();


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
          .push(MaterialPageRoute(builder: (context) => VerifyEmail()))
          .then((value){
            if(value!=null)
            {
              _helper.show(value);
              _helper.flushbar.show(context);
            }
          });
      } 
      else 
      {
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => HomePage(
              msg:"Hey, Welcome buddy :)"
            )));
      }
    })
    .catchError((e){
      print("error" + e.toString());
      setState(() {
        _isLoading=false;
      });
      _helper.show("Incorrect email or password!!");
      _helper.flushbar.show(context);
    });
  }

  Future<void> _forgotpass() async 
  {
    var ans = EmailValidator.validate(_email.toString());
    if (ans == false) {
      _helper.show("Enter correct email");
      _helper.flushbar..show(context);
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
        _helper.show("Email does not exist in our database.");
        _helper.flushbar..show(context);
      }
      else
      {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email)
        .then((_){
          print(
            "Password reset link has been sent to your email. Reset and try login again");
          _helper.show(
              "Password reset link has been sent to your email. Reset and try login again");
          _helper.flushbar.show(context);
        })
        .catchError((e){
          print(e);
          _helper.show("Can not sent link right now. Try again");
          _helper.flushbar..show(context);
        });
      }
    })
    .catchError((e){
      _helper.show("Opps!! Some error occured. Try again");
      _helper.flushbar..show(context);
    });
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
                      if (EmailValidator.validate(value) == false) 
                      {
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
                          _eyeClosed==true?
                          Icons.visibility_off
                          :
                          Icons.visibility,
                        ),
                        onPressed: (){
                          setState(() {
                            if(_eyeClosed==true) _eyeClosed=false;
                            else _eyeClosed=true;
                          });
                        },
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                    ),
                    obscureText: _eyeClosed,
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
                            MaterialPageRoute(builder: (context) => Register()))
                            .then((value){
                              if(value!=null)
                              {
                                _helper.show(value);
                                _helper.flushbar.show(context);
                              }
                            });
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
