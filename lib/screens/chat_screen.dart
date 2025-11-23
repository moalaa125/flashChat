import 'dart:io';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _fireStore = FirebaseFirestore.instance;
final supabase = Supabase.instance.client;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static String id = 'chatS';

  @override
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textEdiingColtroller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  String? messageText;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    textEdiingColtroller.dispose();
    super.dispose();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          currentUserEmail = user.email;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error')));
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/temp_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _stopRecordingAndSend() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        await _uploadAndSendAudio(path);
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _uploadAndSendAudio(String filePath) async {
    final File file = File(filePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      // نستخدم Supabase هنا فقط للتخزين (Storage)
      await supabase.storage
          .from('voice_notes')
          .upload(
        fileName,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final String publicUrl = supabase.storage
          .from('voice_notes')
          .getPublicUrl(fileName);

      await _fireStore.collection('messages').add({
        'sender': currentUserEmail,
        'text': '',
        'audio_url': publicUrl,
        'type': 'voice',
        'timestamp': FieldValue.serverTimestamp(),
      });

      scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send audio')),
        );
      }
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Hero(
            tag: 'logo',
            child: SizedBox(
              height: 35,
              width: 35,
              child: Image.asset('images/chat.png'),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.xmark, color: Color(0xFFF4F4F4)),
            onPressed: () async {
              // Show confirmation dialog
              final bool? shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Color(0xFF0C2B4E),
                    title: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Color(0xFFF4F4F4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to log out?',
                      style: TextStyle(color: Color(0xFFF4F4F4)),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // No
                        },
                        child: Text(
                          'No',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Yes
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ),
                    ],
                  );
                },
              );

              // If user confirmed logout, proceed
              if (shouldLogout == true) {
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
              }
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
        backgroundColor: Color(0xFF0C2B4E),
        elevation: 3,
        shadowColor: Colors.black,
        surfaceTintColor: Color(0xFF0C2B4E),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0C2B4E), Color(0xFFF4F4F4), Color(0xFF0C2B4E)],
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        textSelectionTheme: TextSelectionThemeData(
                          selectionHandleColor: Colors.white,
                          cursorColor: Colors.white,
                        ),
                      ),
                      child: TextField(
                        controller: textEdiingColtroller,
                        onChanged: (value) {
                          messageText = value;
                        },
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isRecording ? FontAwesomeIcons.microphoneLines : FontAwesomeIcons.microphone,
                      color: _isRecording ? Colors.red : Colors.white,
                    ),
                    onPressed: _isRecording ? _stopRecordingAndSend : _startRecording,
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.paperPlane, color: Color(0xFFF4F4F4)),
                    onPressed: () async {
                      if (messageText != null &&
                          messageText!.trim().isNotEmpty) {
                        await _fireStore.collection('messages').add({
                          'text': messageText,
                          'sender': currentUserEmail,
                          'type': 'text',
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        textEdiingColtroller.clear();
                        messageText = null;
                        scrollToBottom();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
          .orderBy('timestamp', descending: true)
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

          final type = messageData['type'] ?? 'text';
          final audioUrl = messageData['audio_url'];

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUserEmail == messageSender,
            isVoice: type == 'voice',
            audioUrl: audioUrl,
            messageId: message.id,
          );

          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            controller: scrollController,

            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatefulWidget {
  final String? sender;
  final String? text;
  final bool? isMe;
  final bool isVoice;
  final String? audioUrl;
  final String messageId;

  const MessageBubble({
    super.key,
    this.sender,
    this.text,
    this.isMe,
    this.isVoice = false,
    this.audioUrl,
    required this.messageId,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  double _dragOffset = 0.0;
  final double _deleteIconSize = 24.0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _deleteMessage() async {
    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF0C2B4E),
          title: Text(
            'Delete Message',
            style: TextStyle(
              color: Color(0xFFF4F4F4),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this message?',
            style: TextStyle(color: Color(0xFFF4F4F4)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion, proceed with delete
    if (shouldDelete == true) {
      try {
        await _fireStore.collection('messages').doc(widget.messageId).delete();
        setState(() {
          _dragOffset = 0.0;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في حذف الرسالة')),
          );
        }
      }
    } else {
      // If user clicked No or closed dialog, reset the message to normal state
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < 0) {
      // Swiping left (from right to left)
      setState(() {
        _dragOffset = (_dragOffset - details.delta.dx).clamp(0.0, _deleteIconSize);
      });
    } else if (details.delta.dx > 0) {
      // Swiping right (back)
      setState(() {
        _dragOffset = (_dragOffset - details.delta.dx).clamp(0.0, _deleteIconSize);
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset < _deleteIconSize * 0.5) {
      // Snap back if not dragged enough
      setState(() {
        _dragOffset = 0.0;
      });
    } else {
      // Keep it open if dragged enough
      setState(() {
        _dragOffset = _deleteIconSize;
      });
    }
  }

  void _toggleAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (widget.audioUrl != null) {
        await _audioPlayer.play(UrlSource(widget.audioUrl!));
        setState(() {
          isPlaying = true;
        });
        _audioPlayer.onPlayerComplete.listen((event) {
          if (mounted) {
            setState(() {
              isPlaying = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only allow swipe-to-delete for messages sent by current user
    if (!widget.isMe!) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender ?? 'Unknown',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Material(
              elevation: 4,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              color: Colors.grey[350],
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: widget.isVoice
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                        color: Colors.black87,
                      ),
                      onPressed: _toggleAudio,
                    ),
                    Text(
                      "Voice Message",
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                )
                    : Text(
                  widget.text ?? '',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // For sent messages, add swipe-to-delete functionality
    return Padding(
      padding: EdgeInsets.all(10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Message content with gesture detector
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(-_dragOffset, 0, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.sender ?? 'Unknown',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      color: Color(0xFF0C2B4E),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: widget.isVoice
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                                color: Colors.white,
                              ),
                              onPressed: _toggleAudio,
                            ),
                            Text(
                              "Voice Message",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                            : Text(
                          widget.text ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Delete icon in the gap between message and screen edge
          Positioned(
            right: -10,
            top: 1,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _dragOffset > 5 ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: _dragOffset < 5,
                child: Center(
                  child: GestureDetector(
                    onTap: _deleteMessage,
                    child: Container(
                      width: _deleteIconSize,
                      height: _deleteIconSize,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
