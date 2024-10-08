import 'rive_model.dart';

class Menu {
  final String title;
  final RiveModel rive;

  Menu({required this.title, required this.rive});
}

// List<Menu> sidebarMenus2 = [
//   Menu(
//     title: "Home",
//     rive: RiveModel(
//         src: "assets/icons.riv",
//         artboard: "HOME",
//         stateMachineName: "HOME_interactivity"),
//   ),
//   Menu(
//     title: "Notifications",
//     rive: RiveModel(
//         src: "assets/icons.riv",
//         artboard: "BELL",
//         stateMachineName: "BELL_Interactivity"),
//   ),
// ];

List<Menu> bottomNavItems = [
  Menu(
    title: "Home",
    rive: RiveModel(
        src: "assets/Rive/Animated.riv",
        artboard: "HOME",
        stateMachineName: "HOME_interactivity"),
  ),
  Menu(
    title: "Chat",
    rive: RiveModel(
        src: "assets/Rive/Animated.riv",
        artboard: "CHAT",
        stateMachineName: "CHAT_Interactivity"),
  ),
  Menu(
    title: "Alert",
    rive: RiveModel(
        src: "assets/Rive/Animated.riv",
        artboard: "LIKE/STAR",
        stateMachineName: "STAR_Interactivity"),
  ),
  Menu(
    title: "Notification",
    rive: RiveModel(
        src: "assets/Rive/Animated.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
  ),
  Menu(
    title: "Profile",
    rive: RiveModel(
        src: "assets/Rive/Animated.riv",
        artboard: "USER",
        stateMachineName: "USER_Interactivity"),
  ),
];
