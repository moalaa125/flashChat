import 'package:flutter/material.dart';

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({
    required this.clr,
    required this.txt,
    this.onPressed,
    super.key,
  });

  final Color clr;
  final String txt;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: clr,
        borderRadius: BorderRadius.circular(30.0),
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(seconds: 3),
          child: MaterialButton(onPressed: onPressed, child: Text(txt)),
        ),
      ),
    );
  }
}
