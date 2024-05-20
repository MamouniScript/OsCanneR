import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

class Recognizerscreen extends StatefulWidget {
  final File image;
  Recognizerscreen(this.image);

  @override
  State<Recognizerscreen> createState() => _RecognizerscreenState();
}

class _RecognizerscreenState extends State<Recognizerscreen> {
  String _results = "";
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _initializeLangDetect();
    _performOCR();
  }

  Future<void> _initializeLangDetect() async {
    try {
      await langdetect.initLangDetect();
    } catch (e) {
      print("Error initializing language detection: $e");
    }
  }

  Future<void> _performOCR() async {
    try {
      // Perform OCR
      String text = await FlutterTesseractOcr.extractText(
        widget.image.path,
        language: await _detectLanguage(widget.image),
      );

      setState(() {
        _results = text;
        _scanning = false;
      });
    } catch (e) {
      print("Error during OCR: $e");
      setState(() {
        _results = "Error during OCR: $e";
        _scanning = false;
      });
    }
  }

  Future<String> _detectLanguage(File image) async {
    try {
      // Detect language
      String languageCode = langdetect.detect(await _getImageBase64(image));
      print(languageCode);

      // Return the detected language code
      return languageCode;
    } catch (e) {
      print("Error during language detection: $e");
      return "eng"; // Default to English if language detection fails
    }
  }

  Future<String> _getImageBase64(File image) async {
    // Load the image as bytes
    List<int> imageBytes = await image.readAsBytes();

    // Convert bytes to a base64 string
    return base64Encode(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Text Extraction'),
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
                          Text(
                            'Extracted Text',
                            style: TextStyle(color: Colors.white),
                          ),
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
                          _results,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
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
