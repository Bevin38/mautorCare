import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AiCameraScreen extends StatefulWidget {
  const AiCameraScreen({super.key});

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen> {
  File? image;
  late ImagePicker imagePicker;
  late ImageLabeler labeler;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();

    loadCustomModel();
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  void loadCustomModel() async {
    final modelPath =
        await getModelPath('assets/object_detection/model.tflite');
    ImageLabelerOptions options = LocalLabelerOptions(
      confidenceThreshold: 0.6,
      modelPath: modelPath,
    );
    labeler = ImageLabeler(options: options);
  }

  chooseImage() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      image = File(selectedImage.path);
      performImageLabeling();
      setState(() {
        image;
      });
    }
  }

  captureImage() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (selectedImage != null) {
      image = File(selectedImage.path);
      performImageLabeling();
      setState(() {
        image;
      });
    }
  }

  String results = "";
  performImageLabeling() async {
    results = "";
    InputImage inputImage = InputImage.fromFile(image!);

    final List<ImageLabel> labels = await labeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;

      results += "$text   ${confidence.toStringAsFixed(2)}\n";
    }

    setState(() {
      results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                color: Colors.grey,
                margin: const EdgeInsets.all(5),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  child: image == null
                      ? const Icon(
                          Icons.image_outlined,
                          size: 100,
                        )
                      : Image.file(image!),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(10),
                color: Colors.blue.shade400,
                child: SizedBox(
                  height: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: const Icon(Icons.image, size: 50),
                        onTap: () {
                          chooseImage();
                        },
                      ),
                      InkWell(
                        child: const Icon(Icons.camera, size: 50),
                        onTap: () {
                          captureImage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: const Color.fromARGB(199, 0, 0, 0),
                margin: const EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    results,
                    style: const TextStyle(fontSize: 19, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
