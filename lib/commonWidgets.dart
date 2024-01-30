import 'package:flutter/material.dart';
import 'package:payment_tool/constants.dart';

class CustomCloseButton extends StatelessWidget {
  final String buttonText;

  CustomCloseButton({required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.IconColor),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: StyleConstants.border))),
      child: Text(
        buttonText,
        style:
            const TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
      ),
      onPressed: () {
        Navigator.of(context).pop(); // Cierra el pop-up
      },
    );
  }
}
