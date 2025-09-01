import 'dart:io';

import 'package:camera/camera.dart';
import 'package:document_scanner/card_scanner.dart';
import 'package:document_scanner/recognizer_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImagePicker imagePicker;
  late List<CameraDescription> _camera;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    initializeCamera();
  }

  initializeCamera() async {
    _camera = await availableCameras();
  }

  bool scan = false;
  bool recognize = true;
  bool enhance = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 50, bottom: 15, left: 5, right: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            color: Colors.blueAccent,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        scan = true;
                        recognize = false;
                        enhance = false;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.scanner,
                          size: 25,
                          color: scan ? Colors.black : Colors.white,
                        ),
                        Text(
                          'Scan',
                          style: TextStyle(
                            color: scan ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        scan = false;
                        recognize = true;
                        enhance = false;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner,
                          size: 25,
                          color: recognize ? Colors.black : Colors.white,
                        ),
                        Text(
                          'Recognize',
                          style: TextStyle(
                            color: recognize ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        scan = false;
                        recognize = false;
                        enhance = true;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_sharp,
                          size: 25,
                          color: enhance ? Colors.black : Colors.white,
                        ),
                        Text(
                          'Enhance',
                          style: TextStyle(
                            color: enhance ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Card(
            color: Colors.black,
            child: Container(height: MediaQuery.of(context).size.height - 300),
          ),

          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.rotate_left,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Icon(Icons.camera, size: 50, color: Colors.white),
                  ),
                  InkWell(
                    onTap: () async {
                      XFile? xfile = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (xfile != null) {
                        File image = File(xfile.path);
                        final editedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImageCropper(image: image.readAsBytesSync()),
                          ),
                        );
                        image.writeAsBytes(editedImage);
                        if (recognize) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return RecognizerScreen(image: image);
                              },
                            ),
                          );
                        } else if (scan) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return CardScanner(image: image);
                              },
                            ),
                          );
                        }
                      }
                    },
                    child: Icon(
                      Icons.image_outlined,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
