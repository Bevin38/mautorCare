import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mautorcare/src/Constants/RIVE/nav_item_model.dart';
import 'package:mautorcare/src/Screens/Camera/camera_choice_screen.dart';
import 'package:mautorcare/src/Screens/Chatbot/chatbot_screen.dart';
import 'package:mautorcare/src/Screens/Home/homepage.dart';
import 'package:mautorcare/src/Screens/Insurance/insurance_screen.dart';
import 'package:mautorcare/src/Screens/Profile/profile_screen.dart';
import 'package:rive/rive.dart';

const Color bottomNavBgColor = Color(0xFF17203A);

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _BottomNavAnimatedState();
}

class _BottomNavAnimatedState extends State<Navbar> {
  List<SMIBool> riveIconInput = [];
  List<StateMachineController?> controllers = [];
  int slectedNavIndex = 0;
  late String currentPage;
  late int currentIndex;
  Timer? _inactivityTimer;
  double _navBarHeight = 36; // Initial height
  bool _isShrunk = false;
  bool overlap = true;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  // List<String> pageKeys = ["Home", "Chat", "Alert", "Insurance", "Profile"];

  void animateIcon(int index) {
    riveIconInput[index].change(true);
    Future.delayed(
      const Duration(seconds: 1),
      () {
        riveIconInput[index].change(false);
      },
    );
    setState(() {
      slectedNavIndex = index;
    });
  }

  void riveInit(Artboard artboard, {required String stateMachineName}) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, stateMachineName);

    artboard.addController(controller!);
    controllers.add(controller);

    riveIconInput.add(controller.findInput<bool>('active') as SMIBool);
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 4), () {
      if (!_isShrunk) {
        setState(() {
          _navBarHeight = 0; // Shrink height after 5 seconds
          _isShrunk = true;
          overlap = true;
        });
      }
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_isShrunk) {
      setState(() {
        overlap = false;
        _navBarHeight = 36; // Reset to original height
        _isShrunk = false;
      });
    }
    _startInactivityTimer(); // Restart the timer
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: overlap,
      body: IndexedStack(
        index: slectedNavIndex,
        children: const [
          Homepage(),
          ChatbotScreen(),
          CameraChoiceScreen(),
          InsuranceScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: GestureDetector(
        onTap: _resetInactivityTimer,
        child: AnimatedContainer(
          duration: const Duration(microseconds: 300),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(5),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              //backgroundBlendMode: BlendMode.multiply,
              color: bottomNavBgColor.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: bottomNavBgColor.withOpacity(0.3),
                    offset: const Offset(0, 20),
                    blurRadius: 20),
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(bottomNavItems.length, (index) {
              final riveIcon = bottomNavItems[index].rive;
              return GestureDetector(
                onTap: () {
                  animateIcon(index);
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => const Alert()));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBar(isActive: slectedNavIndex == index),
                    SizedBox(
                      height: _navBarHeight,
                      width: 36,
                      child: Opacity(
                        opacity: slectedNavIndex == index ? 1 : 0.5,
                        child: RiveAnimation.asset(
                          riveIcon.src,
                          artboard: riveIcon.artboard,
                          onInit: (artboard) {
                            riveInit(artboard,
                                stateMachineName: riveIcon.stateMachineName);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required this.isActive,
  });
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 200),
      margin: const EdgeInsets.only(bottom: 2),
      height: 4,
      width: isActive ? 20 : 0,
      decoration: const BoxDecoration(
        color: Color(0xFF81B4FF),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class Navigate extends StatelessWidget {
  const Navigate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
