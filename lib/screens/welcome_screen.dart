import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/widgets/rounded_button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  static const String id = 'welcome';

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    animation =
        ColorTween(begin: Colors.amberAccent.shade200, end: Colors.white)
            .animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });

    _checkIfAuthenticated();
  }

  _checkIfAuthenticated() {
    if (_auth.currentUser != null) {
      print('logged in already');
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SafeArea(
              child: Row(
                children: <Widget>[
                  Hero(
                    tag: 'lightning',
                    child: SizedBox(
                      height: 60.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  SizedBox(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText('Flash Chat',
                              speed: const Duration(milliseconds: 275)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              buttonColor: Colors.lightBlueAccent,
              buttonText: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              buttonColor: Colors.blueAccent,
              buttonText: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
