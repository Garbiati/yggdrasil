import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final String assetName;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const LoginButton({
    Key? key,
    required this.text,
    required this.assetName,
    required this.color,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: color,
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: AssetImage(assetName),
              height: 35.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
