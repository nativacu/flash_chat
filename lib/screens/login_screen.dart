import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/login_arguments.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/widgets/rounded_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = 'login';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool _showSpinner = false;

  late String email = '';
  late String password = '';

  final TextEditingController _emailController = TextEditingController();

  void prefillEmailController(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is LoginArguments) {
      email = args.email;
      _emailController.text = email;
    }
  }

  Future<void> onLogin() async {
    _toggleSpinner();
    try {
      var user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        _navToChat();
      }
      _toggleSpinner();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _toggleSpinner();
    }
  }

  _navToChat() {
    Navigator.pushNamed(
      context,
      ChatScreen.id,
    );
  }

  _toggleSpinner() {
    setState(() {
      _showSpinner = !_showSpinner;
    });
  }

  @override
  Widget build(BuildContext context) {
    prefillEmailController(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'lightning',
                child: SizedBox(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email.',
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password.',
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                buttonColor: Colors.lightBlueAccent,
                buttonText: 'Log In',
                onPressed: () async {
                  await onLogin();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
