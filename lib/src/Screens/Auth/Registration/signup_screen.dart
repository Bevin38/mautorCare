import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mautorcare/src/Components/welcome_custom_scaffold.dart';
//import 'package:mautorcare/src/Screens/Auth/Registration/user_info_screen.dart';
import 'package:mautorcare/src/Screens/Auth/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mautorcare/firebase_options.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WelcomeCustomScaffold(
      child: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
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
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Welcome!',
                              style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.w900,
                                  color: Color.fromARGB(255, 24, 2, 122)),
                            ),
                            const SizedBox(
                              child: Padding(padding: EdgeInsets.only(top: 20)),
                            ),
                            TextFormField(
                                controller: _email,
                                enableSuggestions: false,
                                autocorrect: false,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Email';
                                  }
                                  return null;
                                },
                                // onSaved: (String email) {
                                //   _email = email;
                                // },
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
                                child:
                                    Padding(padding: EdgeInsets.only(top: 25))),
                            TextFormField(
                                controller: _password,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                obscuringCharacter: "*",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Password';
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
                                child:
                                    Padding(padding: EdgeInsets.only(top: 25))),
                            // TextFormField(
                            //     obscureText: true,
                            //     obscuringCharacter: "*",
                            //     validator: (value) {
                            //       if (value == null || value.isEmpty) {
                            //         return 'Please enter Email';
                            //       }
                            //       return null;
                            //     },
                            //     decoration: InputDecoration(
                            //         label: const Text("Confirm Password"),
                            //         hintText: "Enter Password Again",
                            //         hintStyle: const TextStyle(
                            //           color: Color.fromARGB(197, 68, 2, 122),
                            //         ),
                            //         border: OutlineInputBorder(
                            //           borderSide: const BorderSide(
                            //             color: Color.fromARGB(197, 68, 2, 122),
                            //           ),
                            //           borderRadius: BorderRadius.circular(10),
                            //         ),
                            //         enabledBorder: const OutlineInputBorder(
                            //             borderSide: BorderSide(
                            //           color: Color.fromARGB(197, 68, 2, 122),
                            //         )))),
                            // const SizedBox(
                            //    child: Padding(padding: EdgeInsets.only(top: 20))),
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
                                child:
                                    Padding(padding: EdgeInsets.only(top: 25))),
                            //GO TO APP HOMEPAGE
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    final email = _email.text;
                                    final password = _password.text;
                                    try {
                                      final userCredential = await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                        email: email,
                                        password: password,
                                      );
                                      print(userCredential);
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'email-already in use') {
                                        print('Email Already in use.');
                                      } else if (e.code == 'weak-password') {
                                        print('Weak Password.');
                                      } else if (e.code == 'invalid-email') {
                                        print(
                                            'The supplied auth email is incorrect.');
                                      } else {
                                        print('Sign-up failed: ${e.message}');
                                      }
                                    } catch (e) {
                                      print('An error occurred: $e');
                                    }

                                    Navigator.push(
                                        // ignore: use_build_context_synchronously
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignInScreen()));
                                  },
                                  child: const Text("Sign Up")),
                            ),
                            const SizedBox(
                                child:
                                    Padding(padding: EdgeInsets.only(top: 30))),
                            //SIGN UP WITH DIFFERENT MEDIA
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Divider(),
                                ),
                              ],
                            ),
                            const SizedBox(
                                child:
                                    Padding(padding: EdgeInsets.only(top: 20))),
                            const Row(
                              children: [
                                //LOGOS
                              ],
                            ),
                            const SizedBox(
                                child:
                                    Padding(padding: EdgeInsets.only(top: 20))),
                            // //REGISTRATION NEW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account?  ",
                                  style: TextStyle(color: Colors.black26),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (e) =>
                                                  const SignInScreen()));
                                    },
                                    child: const Text(
                                      "Sign in",
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
              );
            default:
              return const Text("Loading....");
          }
        },
      ),
    );
  }
}
