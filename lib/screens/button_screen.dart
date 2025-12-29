import 'package:flutter/material.dart';

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({
    this.fontsize,
    this.clr,
    this.txtColor,
    required this.txt,
    this.onPressed,
    super.key,
  });

  final Color? clr;
  final Color? txtColor;
  final double? fontsize  ;
  final String txt;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: clr,
        borderRadius: BorderRadius.circular(10.0),
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(seconds: 3),
          child: MaterialButton(onPressed: onPressed, child: Text(txt , style: TextStyle(color: txtColor , fontSize: fontsize),)),
        ),
      ),
    );
  }
}
