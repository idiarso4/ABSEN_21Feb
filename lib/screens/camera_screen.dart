import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../services/face_service.dart';

class CameraScreen extends StatefulWidget {
  final Function(String) onPhotoCapture;

  const CameraScreen({Key? key, required this.onPhotoCapture}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  FaceService? _faceService;
  bool _isCameraInitialized = false;
  bool _isFaceDetected = false;
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      _faceService = FaceService();
      
      _controller!.startImageStream((image) => _processCameraImage(image));
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    try {
      final rotation = InputImageRotation.rotation90deg;
      final faceDetected = await _faceService?.detectFace(image, rotation) ?? false;

      if (mounted && faceDetected != _isFaceDetected) {
        setState(() {
          _isFaceDetected = faceDetected;
        });
      }
    } catch (e) {
      print('Error processing camera image: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraInitialized || !_isFaceDetected) return;

    try {
      final image = await _controller?.takePicture();
      if (image != null) {
        widget.onPhotoCapture(image.path);
      }
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _isFaceDetected ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                _isFaceDetected ? 'Face Detected' : 'No Face Detected',
                style: TextStyle(
                  color: _isFaceDetected ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isFaceDetected ? _capturePhoto : null,
                child: const Text('Capture Photo'),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 