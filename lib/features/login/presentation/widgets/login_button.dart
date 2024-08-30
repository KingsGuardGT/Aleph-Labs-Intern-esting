import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final Color splashColor;
  final textColor;
  final highlightColor;
  final fillColor;

  const LoginButton(
      {required Key key,
      required this.text,
      @required this.textColor,
      required this.splashColor,
      @required this.fillColor,
      @required this.highlightColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0.0),
        backgroundColor: WidgetStateProperty.all(fillColor),
        foregroundColor: WidgetStateProperty.all(textColor),
        splashFactory: InkRipple.splashFactory,
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      onPressed: () {},
    );
  }
}
