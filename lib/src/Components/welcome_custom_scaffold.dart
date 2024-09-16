import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class WelcomeCustomScaffold extends StatelessWidget {
  const WelcomeCustomScaffold({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const RiveAnimation.asset(
            "assets/Rive/car_background.riv",
            fit: BoxFit.cover,
          ),
          SafeArea(child: child!)
        ],
      ),
    );
  }
}
