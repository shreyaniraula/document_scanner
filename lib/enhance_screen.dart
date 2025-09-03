import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';

class EnhanceScreen extends StatefulWidget {
  File image;
  EnhanceScreen({super.key, required this.image});

  @override
  State<EnhanceScreen> createState() => _EnhanceScreenState();
}

class _EnhanceScreenState extends State<EnhanceScreen> {
  late img.Image inputImage;
  @override
  void initState() {
    super.initState();
    inputImage = img.decodeImage(widget.image.readAsBytesSync())!;
    initMediaStore();
    enhanceImage();
  }

  initMediaStore() async {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = "DocumentScanner";
  }

  enhanceImage() {
    img.Image temp = img.decodeImage(widget.image.readAsBytesSync())!;
    inputImage = img.adjustColor(temp, brightness: brightness);
    inputImage = img.contrast(inputImage, contrast: contrast);
    setState(() {
      inputImage;
    });
  }

  double contrast = 150;
  double brightness = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text('Enhance', style: TextStyle(color: Colors.white)),
        actions: [
          InkWell(
            onTap: () async {
              // Write to a temporary file first
              final bytes = Uint8List.fromList(img.encodePng(inputImage));
              final tempDir = await getTemporaryDirectory();
              final tempFile = File(
                "${tempDir.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}.png",
              );
              await tempFile.writeAsBytes(bytes);

              final mediaStore = MediaStore();
              final saveInfo = await mediaStore.saveFile(
                tempFilePath: tempFile.path,
                dirType: DirType.photo,
                dirName: DirName.pictures,
              );

              print("Saved to gallery at: ${saveInfo?.uri}");
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image saved to gallery.')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.save_alt),
            ),
          ),
          InkWell(
            onTap: () async {
              final editedImage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ImageFilters(
                      image: Uint8List.fromList(img.encodePng(inputImage)),
                    );
                  },
                ),
              );
              inputImage = img.decodeImage(editedImage)!;
              setState(() {
                inputImage;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.filter),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.all(10),
                color: Colors.grey,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.5,
                  margin: EdgeInsets.all(15),
                  child: Image.memory(
                    //convert inputimage to uint8 and pass to image.memory
                    Uint8List.fromList(img.encodeBmp(inputImage)),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 10),
                child: Row(
                  children: [
                    Icon(Icons.contrast, size: 20, color: Colors.blueAccent),
                    Expanded(
                      child: Slider(
                        value: contrast,
                        onChanged: (value) {
                          contrast = value;
                          enhanceImage();
                          setState(() {
                            contrast;
                          });
                        },
                        min: 80,
                        max: 200,
                        divisions: 12,
                        label: contrast.toStringAsFixed(2),
                        activeColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.brightness_5,
                      size: 20,
                      color: Colors.blueAccent,
                    ),
                    Expanded(
                      child: Slider(
                        value: brightness,
                        onChanged: (value) {
                          brightness = value;
                          enhanceImage();
                          setState(() {
                            brightness;
                          });
                        },
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: brightness.toStringAsFixed(2),
                        activeColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
