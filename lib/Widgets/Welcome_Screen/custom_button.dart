import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton(
      {super.key,
      this.buttonText,
      this.onTap,
      this.color,
      this.textColor,
      this.borderRadius});
  final String? buttonText;
  final Widget? onTap;
  final Color? color;
  final Color? textColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (e) => onTap!));
      },
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: color!,
          borderRadius: borderRadius!,
          //topRight: Radius.circular(50),
        ),
        child: Text(
          buttonText!,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: textColor!),
        ),
      ),
    );
  }
}
