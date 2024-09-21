import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:mautorcare/src/Constants/theme.dart';
import 'package:mautorcare/src/Screens/Profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
//  final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    //var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Align(
          child: Text(
            "Profile",
            style: TextStyle(
                color: Color.fromARGB(255, 127, 92, 216),
                fontSize: 35,
                fontWeight: FontWeight.w400),
          ),
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Column(
                children: [
                  Stack(children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const Image(
                            image: AssetImage(
                                "assets/pexels-photo-14653174.jpeg")),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.grey,
                          ),
                          child: const Icon(LineAwesomeIcons.camera_retro_solid,
                              size: 27, color: Colors.black)),
                    )
                  ]),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Profile Name",
                style: TextStyle(color: Colors.grey),
              ),
              const Text(
                "Email",
                style: TextStyle(color: Colors.yellow),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfileScreen()));
                    },
                    child: const Text("View Profile")),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.transparent,
              ),
              const SizedBox(height: 10),

              //list
              ProfileMenuWidget(
                title: "Settings",
                icon: LineAwesomeIcons.cog_solid,
                iconColour: const Color.fromARGB(255, 58, 31, 125),
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: "Billing",
                icon: LineAwesomeIcons.wallet_solid,
                iconColour: const Color.fromARGB(255, 58, 31, 125),
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: "User Management",
                icon: LineAwesomeIcons.user_check_solid,
                iconColour: const Color.fromARGB(255, 58, 31, 125),
                onPress: () {},
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 20,
              ),
              ProfileMenuWidget(
                title: "Information",
                icon: LineAwesomeIcons.info_solid,
                iconColour: const Color.fromARGB(255, 58, 31, 125),
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: "Log Out",
                icon: LineAwesomeIcons.sign_out_alt_solid,
                textColor: Colors.red,
                iconColour: Colors.red,
                endIcon: false,
                onPress: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
    this.iconColour,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;
  final Color? iconColour;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100), color: iconColour),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: Text(title,
          style: const TextStyle(color: Colors.grey).apply(color: textColor)),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.3),
              ),
              child: const Icon(LineAwesomeIcons.angle_right_solid,
                  size: 18, color: Colors.grey))
          : null,
    );
  }
}
