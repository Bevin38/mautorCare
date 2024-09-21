import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<QrScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Scan QR code"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, "/generate");
                },
                icon: const Icon(Icons.qr_code))
          ],
        ),
        body: MobileScanner(
          controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates, returnImage: true),
          onDetect: (capture) async {
            final List<Barcode> barcodes = capture.barcodes;
            final Uint8List? image = capture.image;
            // for (final barcode in barcodes)
            {
              // print("Barcode found! ${barcode.rawValue}"
              // );
            }

            if (image != null) {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(barcodes.first.rawValue ?? ""),
                      content: Image(image: MemoryImage(image)),
                    );
                  });
            } else {}
          },
        ));
  }
}
