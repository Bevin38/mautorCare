import 'package:flutter/material.dart';
import 'package:mautorcare/Screens/Welcome_Screens/Registration/signup_screen.dart';
import 'package:mautorcare/Screens/Welcome_Screens/signin_screen.dart';
import 'package:mautorcare/Widgets/Welcome_Screen/custom_button.dart';
import 'package:mautorcare/Widgets/Welcome_Screen/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 50,
                horizontal: 20.0,
              ),
              margin: const EdgeInsets.only(
                right: 110,
              ),
              child: Column(children: [
                RichText(
                  textAlign: TextAlign.left,
                  text: const TextSpan(children: [
                    TextSpan(
                        text: 'Welcome!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w900,
                        )),
                    TextSpan(
                        text: "\nWe're glad you are here, let's get started.",
                        style: TextStyle(fontSize: 25))
                  ]),
                ),
              ]),
            ),
          ),
          const Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                      child: WelcomeButton(
                    buttonText: 'Sign In',
                    onTap: SignInScreen(),
                    color: Color.fromARGB(197, 68, 2, 122),
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(30)),
                    textColor: Colors.white,
                  )),
                  Expanded(
                      child: WelcomeButton(
                    buttonText: 'Sign Up',
                    onTap: SignUpScreen(),
                    color: Color.fromARGB(169, 255, 255, 255),
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(30)),
                    textColor: Color.fromARGB(197, 68, 2, 122),
                  ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
