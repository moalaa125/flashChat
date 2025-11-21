import 'package:flash_chat/screens/button_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcomeS';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;

  Animation? animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    controller!.forward();
    controller!.addListener(() {
      setState(() {});
    });
    animation = CurvedAnimation(
      parent: controller!,
      curve: Curves.easeInOutExpo,
    );
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft ,
            end: Alignment.bottomLeft ,
            colors: [
              Color(0xFF1D546C),
              Color(0xFFF4F4F4),
              Color(0xFF1D546C),
            ]
          )
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: animation!.value * 70,
                      child: Image.asset('images/chat.png'),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'Flash Chat',
                        textStyle: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A3D64),
                        ),
                        speed: Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 48.0),
              Hero(
                tag: 'LoginButton',
                child: ButtonScreen(
                  clr: Color(0xFF1A3D64),
                  txt: 'Login',
                  onPressed: () {
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                ),
              ),
              Hero(
                tag: 'RegistrationButton',
                child: ButtonScreen(
                  clr: Color(0xFF0C2B4E),
                  txt: 'Register',
                  onPressed: () {
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
