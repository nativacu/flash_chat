import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final _fireStore = FirebaseFirestore.instance;
User? loggedInUser;

Map<String, Color> bubbleColors = {};
final Set<Color> _usedColors = {Colors.lightBlueAccent};

void _initBubbleColors() {
  String userEmail = loggedInUser?.email ?? '';
  bubbleColors.clear();
  _usedColors.clear();
  bubbleColors[userEmail] = Colors.lightBlueAccent;
}

MapEntry<String, Color> getSenderEntry(String email) {
  Color color = bubbleColors[email] ?? generateUniqueColor();
  bubbleColors[email] = color;
  return MapEntry(email, color);
}

Color generateUniqueColor() {
  Color newColor;

  do {
    newColor = _randomPastelColor();
  } while (_usedColors.contains(newColor) ||
      !_hasSufficientContrast(newColor) ||
      newColor == Colors.lightBlueAccent);

  _usedColors.add(newColor);
  return newColor;
}

Color _randomPastelColor() {
  Random random = Random();
  int r = random.nextInt(116) + 150; // 150 to 255
  int g = random.nextInt(116) + 150; // 150 to 255
  int b = random.nextInt(116) + 150; // 150 to 255

  return Color.fromARGB(255, r, g, b);
}

// Check if color has enough contrast with white (using the luminance difference)
bool _hasSufficientContrast(Color color) {
  double luminance = color.computeLuminance();
  return luminance < 0.7; // Ensures contrast with white (1.0 is white)
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static const String id = 'chat';

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _messageTextController = TextEditingController();

  late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      _initBubbleColors();
    }
  }

  Future<void> onLogout() async {
    try {
      await _auth.signOut();
      _redirectToHome();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _redirectToHome() {
    Navigator.pushReplacementNamed(
      context,
      WelcomeScreen.id,
    );
  }

  Future<void> onSend() async {
    try {
      _fireStore.collection('messages').add(
        {
          'text': messageText,
          'sender': loggedInUser?.email,
        },
      );

      _messageTextController.clear();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onLogout,
          ),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageTextController,
                      onChanged: (value) {
                        setState(() {
                          messageText = value;
                        });
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: onSend,
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _fireStore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];

        for (var doc in messages) {
          Map<String, dynamic> data = doc.data();
          String senderEmail = data['sender'];
          messageBubbles.add(
            MessageBubble(
              text: data['text'],
              sender: getSenderEntry(senderEmail),
              isMe: loggedInUser?.email == senderEmail,
            ),
          );
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
  });

  final MapEntry<String, Color> sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text(
              sender.key,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
            ),
          ),
          Material(
            color: sender.value,
            elevation: 2.0,
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(30.0),
              topLeft: isMe ? const Radius.circular(30.0) : Radius.zero,
              bottomRight: const Radius.circular(30.0),
              topRight: isMe ? Radius.zero : const Radius.circular(30.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
