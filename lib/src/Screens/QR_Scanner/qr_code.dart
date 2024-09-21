import 'package:flutter/material.dart';
import 'package:mautorcare/src/Components/navbar.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrCode extends StatefulWidget {
  const QrCode({super.key});

  @override
  State<QrCode> createState() => _GenerateCodePageState();
}

class _GenerateCodePageState extends State<QrCode> {
  String? qrData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          iconSize: 35,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Navbar()),
            );
// Navigate back to the previous screen
          },
        ),
        title: const Text("Displaying QR code"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, "/scan");
              },
              icon: const Icon(Icons.qr_code_scanner))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              onSubmitted: (value) {
                setState(() {
                  qrData = value;
                });
              },
            ),
            if (qrData != null) PrettyQrView.data(data: qrData!),
          ],
        ),
      ),
    );
  }
}
