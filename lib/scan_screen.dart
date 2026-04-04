import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class PlantScanScreen extends StatefulWidget {
  const PlantScanScreen({Key? key}) : super(key: key);

  @override
  State<PlantScanScreen> createState() => _PlantScanScreenState();
}

class _PlantScanScreenState extends State<PlantScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera(); // Boot up the camera when the screen loads
  }

  Future<void> _initCamera() async {
    // 1. Find the hardware cameras on the device
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // 2. Pick the first one (usually the back camera)
    final firstCamera = cameras.first;

    // 3. Set up the controller
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false, // No audio needed for plants!
    );

    // 4. Initialize it and update the UI
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Turn the camera off when leaving the screen to save battery
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6), 
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP HEADER ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.document_scanner, color: Color(0xFF135A3B)),
                  const SizedBox(width: 8),
                  const Text(
                    'Plant Scanner',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF135A3B)),
                  ),
                ],
              ),
            ),

            // --- LIVE CAMERA FEED ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black, // Black background while loading
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF135A3B), width: 4),
                ),
                clipBehavior: Clip.hardEdge, // Keeps the camera inside the rounded borders
                child: _controller == null
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF135A3B)))
                    : FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            // Camera is ready, show the feed!
                            return CameraPreview(_controller!);
                          } else {
                            // Camera is loading, show a spinner
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF135A3B)));
                          }
                        },
                      ),
              ),
            ),

            // --- FAKE CAPTURE BUTTON (For Now) ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Scanning plant... (AI connection coming soon!)'))
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF135A3B),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Analyze Plant', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}