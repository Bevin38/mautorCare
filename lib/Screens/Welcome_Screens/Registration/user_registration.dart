import 'package:flutter/material.dart';
import 'package:mautorcare/Screens/Welcome_Screens/Registration/insurance_registration.dart';
//import 'package:mautorcare/Widgets/Welcome_Screen/custom_scaffold.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 228, 228, 228),
        centerTitle: true,
        title: const Text("User Credentials",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 24, 2, 122))),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(230, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
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
                                label: const Text("Username"),
                                hintText: "Enter Username(can be fictitious)",
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
                                return 'Please enter Username';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("Full Name"),
                                hintText: "Enter Name",
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
                            child: Padding(padding: EdgeInsets.only(top: 25))),
                        TextFormField(
                            obscureText: true,
                            obscuringCharacter: "*",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter NID';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("National ID"),
                                hintText: "Enter NID Again",
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
                            child: Padding(padding: EdgeInsets.only(top: 25))),
                        TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Cred 1';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("Cred 1"),
                                hintText: "Enter Cred1",
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
                            child: Padding(padding: EdgeInsets.only(top: 25))),
                        TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Cred2';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("Cred 2"),
                                hintText: "Enter Cred2",
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
                            child: Padding(padding: EdgeInsets.only(top: 25))),
                        TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Cred3';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("Cred 3"),
                                hintText: "Enter Cred3",
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
                            child: Padding(padding: EdgeInsets.only(top: 25))),
                        TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Cred4';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("Cred 4"),
                                hintText: "Enter Cred4",
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
                            child: Padding(padding: EdgeInsets.only(top: 25))),
                        TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Cred5';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text("Cred 5"),
                                hintText: "Enter Cred5",
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

                        const SizedBox(
                            child: Padding(padding: EdgeInsets.only(top: 25))),
                        //GO TO APP HOMEPAGE
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const InsuranceRegistration()));
                              },
                              child: const Text("PROCEED")),
                        ),
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
