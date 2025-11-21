import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  String id = 'chatS';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textEdiingColtroller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  String? messageText;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          currentUserEmail = user.email;
          print('Logged in as: $currentUserEmail');
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.chat , color: Color(0xFFF4F4F4),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close ,color: Color(0xFFF4F4F4)),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text(
          'Flash Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFF4F4F4),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D546C),
        elevation: 3,
        shadowColor: Colors.black,
        surfaceTintColor: Color(0xFF1D546C),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D546C), Color(0xFFF4F4F4), Color(0xFF1D546C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              currentUserEmail == null
                  ? Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Color(0xFF1A3D64),
                  ),
                ),
              )
                  : MassegaesStream(
                currentUserEmail: currentUserEmail!,
                scrollController: _scrollController,
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: textEdiingColtroller,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Color(0xFFF4F4F4)),
                      onPressed: () async {
                        if (messageText != null &&
                            messageText!.trim().isNotEmpty) {
                          await _fireStore.collection('messages').add({
                            'text': messageText,
                            'sender': currentUserEmail,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          textEdiingColtroller.clear();
                          scrollToBottom();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

class MassegaesStream extends StatelessWidget {
  final String currentUserEmail;
  final ScrollController scrollController;

  const MassegaesStream({
    super.key,
    required this.currentUserEmail,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('messages')
          .orderBy('timestamp', descending: true) // ✅ الأحدث أولاً
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Expanded(
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            ),
          );
        }

        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];

        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>;
          final messageText = messageData['text'] ?? '';
          final messageSender = messageData['sender'] ?? '';

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUserEmail == messageSender,
          );

          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            controller: scrollController,
            reverse: true, // ✅ يجعل الأحدث في الأسفل
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? sender;
  final String? text;
  final bool? isMe;

  const MessageBubble({super.key, this.sender, this.text, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe!
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            sender ?? 'Unknown',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          Material(
            elevation: 4,
            borderRadius: isMe!
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
            color: isMe! ? Colors.cyan.shade700 : Colors.grey[200],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text ?? '',
                style: TextStyle(
                  color: isMe! ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
