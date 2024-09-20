import 'package:flutter/material.dart';
import 'package:mautorcare/src/Screens/Insurance/insurance_screen.dart';
import 'package:mautorcare/src/Screens/Profile/profile_screen.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              if (settings.name == '') {
                return const InsuranceScreen();
              }
              return const ProfileScreen();
            },
          );
        });
  }
}
