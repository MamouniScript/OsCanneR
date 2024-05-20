import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oscanner/recognizerScreen.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImagePicker imagePicker;
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription>? cameras;
  int selectedCameraIdx = 0;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    _initializeControllerFuture = _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    PermissionStatus status = await Permission.camera.request();
    if (status.isDenied) {
      // Handle permission denied
      return;
    }

    // Continue initializing camera if permission granted
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![selectedCameraIdx],
        ResolutionPreset.high,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {});
      }
    } else {
      print('No cameras available');
    }
  }


  void stopCameraFeed() async {
    if (_cameraController != null) {
      _cameraController.dispose();
      await _initializeCamera(); // Re-initialize the camera
    }
  }

  void _switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    selectedCameraIdx = (selectedCameraIdx + 1) % cameras!.length;
    _cameraController = CameraController(
      cameras![selectedCameraIdx],
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  void _navigateToRecognizerscreen(File image) {
    _cameraController.dispose();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => Recognizerscreen(image)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 50, bottom: 15, left: 5, right: 5),
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
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.document_scanner_outlined,
                            size: 41,
                            color: Colors.white,
                          ),
                          Text(
                            'Scan',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onTap: () {},
                    ),
                    InkWell(
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_color_text,
                            size: 41,
                            color: Colors.white,
                          ),
                          Text(
                            'Extraire Text',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.black,
              child: Container(
                height: MediaQuery.of(context).size.height - 300,
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_cameraController);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
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
                      child: const Icon(
                        Icons.cameraswitch_outlined,
                        size: 41,
                        color: Colors.white,
                      ),
                      onTap: () {
                        _switchCamera();
                      },
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.camera_rounded,
                        size: 47,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        try {
                          await _initializeControllerFuture;
                          final XFile image = await _cameraController.takePicture();
                          stopCameraFeed(); // Stop camera feed before navigation
                          _navigateToRecognizerscreen(File(image.path));
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.image,
                        size: 45,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        XFile? xfile = await imagePicker.pickImage(
                            source: ImageSource.gallery);
                        if (xfile != null) {
                          File image = File(xfile.path);
                          if (mounted) {
                            _cameraController.dispose();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (ctx) {
                                  return Recognizerscreen(image);
                                })).then((_) {
                              // Reinitialize the camera when returning to this screen
                              //_initializeCamera();
                            });
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
