import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/button_screen.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'loginS';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authLogin = FirebaseAuth.instance;
  String? email;
  String? password;
  bool spinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: ModalProgressHUD(
          inAsyncCall: spinner,
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
                    child: Image.asset('images/chat.png'),
                  ),
                ),
                SizedBox(height: 48.0),
                TextField(
                  cursorColor: Color(0xFF0C2B4E),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },

                  decoration: kInputStyle.copyWith(
                    hintText: 'Enter Your Email',
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  cursorColor: Color(0xFF0C2B4E),
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kInputStyle.copyWith(
                    hintText: 'Enter Your Password',
                    prefixIcon: Icon(Icons.key, color: Color(0xFF0C2B4E)),
                  ),
                ),
                SizedBox(height: 24.0),
                Hero(
                  tag: 'LoginButton',
                  child: ButtonScreen(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
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
                        spinner = true;
                      });

                      try {
                        final loginUser = await _authLogin
                            .signInWithEmailAndPassword(
                              email: email!.trim(),
                              password: password!,
                            );
                        if (loginUser != null) {
                          setState(() {
                            spinner = false;
                          });
                          Navigator.pushNamed(context, ChatScreen.id);
                        }
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          spinner = false;
                        });

                        String errorMessage = 'An error occurred';
                        if (e.code == 'user-not-found') {
                          errorMessage = 'No user found for that email.';
                        } else if (e.code == 'wrong-password') {
                          errorMessage = 'Wrong password provided.';
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
                          spinner = false;
                        });
                        print(e);
                      }
                    },
                    clr: Color(0xFF1A3D64),
                    txt: 'Login',
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
