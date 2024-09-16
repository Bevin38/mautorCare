import 'package:flutter/material.dart';
import 'package:mautorcare/src/Screens/Home/homepage.dart';

class InsuranceInfoScreen extends StatefulWidget {
  const InsuranceInfoScreen({super.key});

  @override
  State<InsuranceInfoScreen> createState() => _InsuranceInfoScreenState();
}

class _InsuranceInfoScreenState extends State<InsuranceInfoScreen>
    with TickerProviderStateMixin {
  String? selectedInsurance;
  bool isOthersSelected = true;

  final List<String> images = [
    "assets/insurance/Insurance1.jpg",
    "assets/insurance/Insurance2.jpg",
    "assets/insurance/Insurance3.png",
    "assets/insurance/Insurance4.jpg",
    "assets/insurance/Insurance5.jpg",
    "assets/insurance/Insurance6.png"
  ];

  late AnimationController _controller;
  late Animation<Alignment> _topAlignAnimation;
  late Animation<Alignment> _bottomAlignAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _topAlignAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      )
    ]).animate(_controller);

    _bottomAlignAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      )
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Insurance",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 24, 2, 122))),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: const [
                          Color.fromARGB(255, 157, 26, 218),
                          Color.fromARGB(255, 31, 66, 223)
                        ],
                            begin: _topAlignAnimation.value,
                            end: _bottomAlignAnimation.value)),
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      //shrinkWrap: true, //ensure that gridview do not take all space
                      // physics:
                      //     const NeverScrollableScrollPhysics(), //ensure that gridview do not scroll
                      itemCount: images.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),

                      itemBuilder: (context, index) {
                        //check if others is selected
                        if (index == images.length) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                isOthersSelected = true;
                                selectedInsurance =
                                    ''; // Clear the text field for input
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(15),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(108, 223, 223, 223),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    '            OTHER \nProvide the name in the textbox below',
                                    style: TextStyle(
                                        fontSize: 19,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        //normal image item
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isOthersSelected = false;
                              selectedInsurance = images[index];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    image: AssetImage(images[index]),
                                    fit: BoxFit.fill)),
                          ),
                        );
                      },
                    ),
                  );
                }),
            const SizedBox(height: 10),
            const Text(
              "Please select an Insurance Company above",
              style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 49, 14, 177),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: selectedInsurance ?? ""),
              readOnly: !isOthersSelected,
              onChanged: (value) {
                if (isOthersSelected) {
                  setState(() {
                    selectedInsurance = value;
                  });
                }
              },
              decoration: const InputDecoration(
                  labelText: "Selected Insurance",
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            TextFormField(
                // obscureText: true,
                // obscuringCharacter: "*",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Cred1';
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

            const SizedBox(child: Padding(padding: EdgeInsets.only(top: 25))),

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

            const SizedBox(child: Padding(padding: EdgeInsets.only(top: 25))),

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

            const SizedBox(child: Padding(padding: EdgeInsets.only(top: 25))),

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

            const SizedBox(child: Padding(padding: EdgeInsets.only(top: 25))),

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

            const SizedBox(child: Padding(padding: EdgeInsets.only(top: 25))),

            TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Cred6';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    label: const Text("Cred 6"),
                    hintText: "Enter Cred6",
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

            const SizedBox(child: Padding(padding: EdgeInsets.only(top: 25))),
            //GO TO APP HOMEPAGE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  },
                  child: const Text("PROCEED")),
            ),
          ]),
        ),
      ),
    );
  }
}
