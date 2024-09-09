import 'package:flutter/material.dart';
import 'package:mautorcare/Screens/Welcome_Screens/Registration/signup_screen.dart';
import 'package:mautorcare/Widgets/Welcome_Screen/custom_scaffold.dart';
import 'package:mautorcare/main.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

final _formSignInKey = GlobalKey<FormState>();

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
              flex: 1,
              child: SizedBox(
                height: 10,
              )),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(230, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: SingleChildScrollView(
                child: Form(
                    key: _formSignInKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 24, 2, 122)),
                        ),
                        const SizedBox(
                          child: Padding(padding: EdgeInsets.only(top: 20)),
                        ),
                        TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("Email"),
                                hintText: "Enter Email",
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(197, 68, 2, 122),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(197, 68, 2, 122),
                                    width: 3.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(197, 68, 2, 122),
                                )))),
                        const SizedBox(
                            child: Padding(padding: EdgeInsets.only(top: 25))),
                        TextFormField(
                            obscureText: true,
                            obscuringCharacter: "*",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("Password"),
                                hintText: "Enter Password",
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(197, 68, 2, 122),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(197, 68, 2, 122),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(197, 68, 2, 122),
                                )))),
                        const SizedBox(
                            child: Padding(padding: EdgeInsets.only(top: 20))),
                        // Row( children: [Checkbox(value: rememberPassword, onChanged: (onchanged: (bool? value {setState(() {
                        //   rememberPasword = value!;
                        // });})))],),
                        GestureDetector(
                          child: const Text(
                            "Forget password?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                            child: Padding(padding: EdgeInsets.only(top: 20))),
                        //GO TO APP HOMEPAGE
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomeWin()));
                              },
                              child: const Text("Sign In")),
                        ),
                        const SizedBox(
                            child: Padding(padding: EdgeInsets.only(top: 20))),
                        //SIGN UP WITH DIFFERENT MEDIA
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              child: Text("Sign up with"),
                            ),
                            Expanded(
                              child: Divider(),
                            )
                          ],
                        ),
                        const SizedBox(
                            child: Padding(padding: EdgeInsets.only(top: 20))),
                        const Row(
                          children: [
                            //LOGOS
                          ],
                        ),
                        const SizedBox(
                            child: Padding(padding: EdgeInsets.only(top: 20))),
                        // //REGISTRATION NEW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?  ",
                              style: TextStyle(color: Colors.black26),
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (e) =>
                                              const SignUpScreen()));
                                },
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 5, 32, 148),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        Color.fromARGB(255, 5, 32, 148),
                                  ),
                                ))
                          ],
                        )
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
