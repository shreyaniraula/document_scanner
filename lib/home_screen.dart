import 'dart:io';

import 'package:camera/camera.dart';
import 'package:document_scanner/card_scanner.dart';
import 'package:document_scanner/enhance_screen.dart';
import 'package:document_scanner/recognizer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImagePicker imagePicker;
  late List<CameraDescription> _camera;
  late CameraController cameraController;
  bool isInit = false;
  bool isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    requestPermissions();
  }

  @override
  void dispose() {
    if (isInit) {
      cameraController.dispose();
      isInit = false;
    }
    super.dispose();
  }

  requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    // var storageStatus = await Permission.storage.request();
    if (cameraStatus.isGranted) {
      setState(() {
        isPermissionGranted = true;
      });
      initializeCamera();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Camera Permission Required'),
          content: Text('This app needs camera permission to take photos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  initializeCamera() async {
    try {
      _camera = await availableCameras();
      if (_camera.isEmpty) {
        print('No cameras available');
        return;
      }
      cameraController = CameraController(
        _camera[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await cameraController.initialize();

      // Set flash mode to off after initialization
      await cameraController.setFlashMode(FlashMode.off);
      if (!mounted) {
        return;
      }
      setState(() {
        isInit = true;
      });
    } catch (e) {
      print("Camera initialization error: $e");
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            //Handle access error here
            break;
          case 'CameraAccessDeniedWithoutPrompt':
            print('Camera access denied without prompt');
            break;
          case 'CameraAccessRestricted':
            print('Camera access restricted');
            break;
          default:
            //Handle other error here
            break;
        }
      }
    }
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
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 300,
                    child:
                        isInit &&
                            isPermissionGranted &&
                            cameraController.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            child: isPermissionGranted
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Camera permission required',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                  ),
                ),

                Container(
                      color: Colors.white,
                      height: 2,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.all(20),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveY(
                      begin: 0,
                      end: MediaQuery.of(context).size.height - 300,
                      duration: Duration(milliseconds: 2000),
                    ),
              ],
            ),
          ),

          Card(
            color: Colors.blueAccent,
            child: SizedBox(
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
                    onTap: takePicture,
                    child: Icon(Icons.camera, size: 50, color: Colors.white),
                  ),
                  InkWell(
                    onTap: pickFromGallery,
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

  takePicture() async {
    print("Camera icon tapped 1");
    if (!isPermissionGranted) {
      print('"Camera permission not granted');
      return;
    }

    print("Camera icon tapped 2");
    if (!isInit || !cameraController.value.isInitialized) {
      print("Camera not initialized");
      return;
    }

    print("Camera icon tapped 3");
    if (cameraController.value.isTakingPicture) {
      print("Already taking a picture");
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      final XFile file = await cameraController.takePicture();
      Navigator.pop(context);
      File image = File(file.path);
      print("Picture taken successfully: ${file.path}");
      await processImage(image);
    } catch (e) {
      // Dismiss loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print("Error taking picture: $e");

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to take picture: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Separate method for picking from gallery
  pickFromGallery() async {
    try {
      XFile? xfile = await imagePicker.pickImage(source: ImageSource.gallery);

      if (xfile != null) {
        File image = File(xfile.path);
        await processImage(image);
      }
    } catch (e) {
      print("Error picking from gallery: $e");
    }
  }

  processImage(File image) async {
    try {
      // Read image bytes with error handling
      final bytes = await image.readAsBytes().catchError((e) {
        print("Error reading image: $e");
        return null;
      });

      if (bytes == null) return;
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImageCropper(image: bytes)),
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
      } else if (enhance) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return EnhanceScreen(image: image);
            },
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
