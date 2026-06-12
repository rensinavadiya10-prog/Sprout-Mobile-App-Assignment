import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    print("Camera Initialization Error: $e");
  }
  runApp(const SproutCameraApp());
}

class SproutCameraApp extends StatelessWidget {
  const SproutCameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sprout Camera Quest',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const CameraQuestScreen(),
    );
  }
}

class CameraQuestScreen extends StatefulWidget {
  const CameraQuestScreen({Key? key}) : super(key: key);

  @override
  State<CameraQuestScreen> createState() => _CameraQuestScreenState();
}

class _CameraQuestScreenState extends State<CameraQuestScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _capturedImagePath;
  String _detectedItem = "";
  bool _showReward = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() { _isCameraInitialized = true; });
    } catch (e) {
      print("Camera Error: $e");
    }
  }

  void _captureAndIdentify() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    setState(() { _isProcessing = true; });

    try {
      XFile file = await _controller!.takePicture();
      await Future.delayed(const Duration(seconds: 2)); // AI simulation delay

      setState(() {
        _capturedImagePath = file.path;
        _isProcessing = false;
        _detectedItem = "Beautiful Flower 🌸"; 
        _showReward = true;
      });
    } catch (e) {
      setState(() { _isProcessing = false; });
      print("Error: $e");
    }
  }

  void _resetQuest() {
    setState(() {
      _capturedImagePath = null;
      _detectedItem = "";
      _showReward = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("🔍 Sprout Nature Quest", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: _showReward ? _buildRewardScreen() : _buildCameraScreen(),
    );
  }

  Widget _buildCameraScreen() {
    if (!_isCameraInitialized) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("🎯 Mission: Find and Snap a Flower around you! 🌸", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CameraPreview(_controller!),
              if (_isProcessing) const Container(color: Colors.black45, child: Center(child: Text("Identifying... ✨", style: TextStyle(color: Colors.white, fontSize: 18)))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: IconButton(icon: const Icon(Icons.camera), iconSize: 60, color: Colors.green, onPressed: _captureAndIdentify),
        )
      ],
    );
  }

  Widget _buildRewardScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Woohoo! Found It! 🎉", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 15),
          Image.file(File(_capturedImagePath!), height: 180, width: 180, fit: BoxFit.cover),
          const SizedBox(height: 15),
          Text("Detected: $_detectedItem", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          const Text("+10 Nature Points Badge! 🏆", style: TextStyle(fontSize: 18, color: Colors.amber)),
          const SizedBox(height: 25),
          ElevatedButton(onPressed: _resetQuest, child: const Text("Next Mission 🚀"))
        ],
      ),
    );
  }
}
