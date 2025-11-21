import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/button_screen.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  String id = 'registerS';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF1D546C), Color(0xFFF4F4F4), Color(0xFF1D546C)],
          ),
        ),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                SizedBox(height: 48.0),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kInputStyle.copyWith(
                    hintText: 'Enter Your Email',
                    hintStyle: TextStyle(color: Color(0xFF0C2B4E)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF1D546C),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF0C2B4E),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kInputStyle.copyWith(
                    hintText: 'Enter Your Password',
                    hintStyle: TextStyle(color: Color(0xFF0C2B4E)),
                    prefixIcon: Icon(Icons.key, color: Color(0xFF0C2B4E)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF1D546C),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF0C2B4E),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Hero(
                  tag: 'RegistrationButton',
                  child: ButtonScreen(
                    clr: Color(0xFF0C2B4E),
                    txt: 'Register',
                    onPressed: () async {
                      FocusScope.of(context).unfocus(); // hide the keyboard

                      if (email == null ||
                          password == null ||
                          email!.isEmpty ||
                          password!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter email and password'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        showSpinner = true;
                      });

                      try {
                        final newUser = await _auth
                            .createUserWithEmailAndPassword(
                              email: email!.trim(),
                              password: password!,
                            );
                        if (newUser != null) {
                          setState(() {
                            showSpinner = false;
                          });
                          Navigator.pushNamed(context, ChatScreen().id);
                        }
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          showSpinner = false;
                        });

                        String errorMessage = 'An error occurred';
                        if (e.code == 'weak-password') {
                          errorMessage = 'The password provided is too weak.';
                        } else if (e.code == 'email-already-in-use') {
                          errorMessage =
                              'The account already exists for that email.';
                        } else if (e.code == 'invalid-email') {
                          errorMessage =
                              'The email address is badly formatted.';
                        } else if (e.code == 'network-request-failed') {
                          errorMessage = 'Check your internet connection.';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (e) {
                        setState(() {
                          showSpinner = false;
                        });
                        print(e);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
