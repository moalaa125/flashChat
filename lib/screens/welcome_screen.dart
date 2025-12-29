import 'package:flash_chat/screens/button_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/registration_screen.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

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
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.only(top: 120, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Image.asset('images/Frame.png', scale: 2.5),
                  ),
                  SizedBox(height: 50),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Welcome to Flash chat!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    textAlign: TextAlign.center,
                    'Get ready for instant messaging , \ndelivered at the speed of light',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 48.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 100,
                      child: Hero(
                        tag: 'LoginButton',
                        child: ButtonScreen(
                          clr: Color(0xFFf25d9c),
                          txt: 'Sign up',
                          fontsize: 22,
                          onPressed: () {
                            Navigator.pushNamed(context, RegistrationScreen.id);
                          },
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'RegistrationButton',
                      child: ButtonScreen(
                        clr: Colors.white,
                        txt: 'Sign in ',
                        txtColor: Color(0xFFf25d9c),
                        onPressed: () {
                          Navigator.pushNamed(context, LoginScreen.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
