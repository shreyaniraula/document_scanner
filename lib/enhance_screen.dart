import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

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
    enhanceImage();
  }

  enhanceImage() {
    img.Image temp = img.decodeImage(widget.image.readAsBytesSync())!;
    inputImage = img.adjustColor(temp, brightness: 2);
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
