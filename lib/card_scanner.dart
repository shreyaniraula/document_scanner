import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardScanner extends StatefulWidget {
  File image;
  CardScanner({super.key, required this.image});

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner> {
  late TextRecognizer textRecognizer;
  late EntityExtractor entityExtractor;
  String results = '';

  List<EntityDataModel> entitiesList = [];

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    entityExtractor = EntityExtractor(
      language: EntityExtractorLanguage.english,
    );
    doTextRecognition();
  }

  /*
  John’s meeting is on 5th September 2025 at 10 AM.
  TextRecognizer → extracts "John’s meeting is on 5th September 2025 at 10 AM."

  EntityExtractor → detects entities:

  DATE_TIME → "5th September 2025 at 10 AM"

  Results →
  DATE_TIME
  5th September 2025 at 10 AM
 */

  doTextRecognition() async {
    // Convert the given image file into an ML Kit readable format
    InputImage inputImage = InputImage.fromFile(widget.image);

    // Use the text recognizer to process the image and extract text
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    entitiesList.clear();

    // Store the raw recognized text (all text found in the image)
    results = recognizedText.text;

    // Pass the recognized text to the entity extractor
    // This will identify entities like dates, times, currencies, addresses, etc.
    final List<EntityAnnotation> annotations = await entityExtractor
        .annotateText(results);

    // Reset results to prepare for extracted entities
    results = "";

    // Loop through each annotation (a detected entity range in the text)
    for (final annotation in annotations) {
      // annotation.start -> starting index of the entity in the text
      // annotation.end   -> ending index of the entity
      // annotation.text  -> actual substring text for the entity

      // Loop through all entities inside this annotation
      for (final entity in annotation.entities) {
        // Append entity information (type + actual matched text) to results
        results += "${entity.type.name}\n${annotation.text}\n\n";
        entitiesList.add(EntityDataModel(entity.type.name, annotation.text));
      }
    }

    // Print results in the debug console (useful for development)
    print(results);

    // Update the UI with the new results
    setState(() {
      results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: Text('Scanner', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            children: [
              Image.file(widget.image, fit: BoxFit.contain),
              ListView.builder(
                itemCount: entitiesList.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                    color: Colors.blueAccent,
                    child: SizedBox(
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              entitiesList[index].iconData,
                              size: 25,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Text(
                                entitiesList[index].value,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: entitiesList[index].value,
                                  ),
                                );
                              },
                              child: Icon(Icons.copy, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Card(
              //   color: Colors.grey.shade300,
              //   margin: EdgeInsets.all(10),
              //   child: Column(
              //     children: [
              //       Container(
              //         color: Colors.blueAccent,
              //         child: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Icon(Icons.document_scanner, color: Colors.white),
              //               Text(
              //                 'Results',
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 18,
              //                 ),
              //               ),
              //               InkWell(
              //                 onTap: () {
              //                   Clipboard.setData(ClipboardData(text: results));
              //                   // ScaffoldMessenger.of(context).showSnackBar(
              //                   //   SnackBar(content: Text('Copied')),
              //                   // );
              //                 },
              //                 child: Icon(Icons.copy, color: Colors.white),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //       Text(results, style: TextStyle(fontSize: 18)),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntityDataModel {
  String name;
  String value;
  IconData? iconData;

  EntityDataModel(this.name, this.value) {
    if (name == 'phone') {
      iconData = Icons.phone;
    } else if (name == 'address') {
      iconData = Icons.location_on;
    } else if (name == 'email') {
      iconData = Icons.mail;
    } else if (name == 'url') {
      iconData = Icons.web;
    } else {
      iconData = Icons.ac_unit_outlined;
    }
  }
}
