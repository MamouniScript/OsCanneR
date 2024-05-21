import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class Recognizerscreen extends StatefulWidget {
  final File image;
  Recognizerscreen(this.image);

  @override
  State<Recognizerscreen> createState() => _RecognizerscreenState();
}

class _RecognizerscreenState extends State<Recognizerscreen> {
  late TextRecognizer textRecognizer;
  String results = "";
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    doTextRecognition();
  }

  @override
  void dispose() {
    // Dispose of the text recognizer
    textRecognizer.close();
    super.dispose();
  }

  doTextRecognition() async {
    InputImage inputImage = InputImage.fromFile(widget.image);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      results = recognizedText.text;
      _scanning = false;
    });

    // Printing details for debugging purposes
    print(results);
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Iterate over lines if needed
        for (TextElement element in line.elements) {
          // Iterate over elements if needed
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Extraction'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(widget.image),
              SizedBox(height: 16.0),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.blueAccent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Results', style: TextStyle(color: Colors.white)),
                          IconButton(
                            icon: Icon(Icons.copy, color: Colors.white),
                            onPressed: () {
                              // Implement copy functionality if needed
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: _scanning
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                        child: Text(
                          results,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

