import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'dart:ui';

class FaceService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.15,
    ),
  );

  Future<bool> detectFace(CameraImage image, InputImageRotation rotation) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.bgra8888;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );

      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) return false;

      // Verify face properties
      final face = faces.first;
      
      // Check if face is looking at camera
      final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 0;
      final headEulerY = face.headEulerAngleY ?? 0;  // Head rotation Y (left/right)
      final headEulerZ = face.headEulerAngleZ ?? 0;  // Head rotation Z (tilt)

      // Face validation criteria
      final bool isLookingAtCamera = 
        leftEyeOpen > 0.5 && 
        rightEyeOpen > 0.5 &&
        headEulerY.abs() < 20 &&  // Head not turned too much left/right
        headEulerZ.abs() < 20;    // Head not tilted too much

      return isLookingAtCamera;
    } catch (e) {
      print('Error in face detection: $e');
      return false;
    }
  }

  Future<void> dispose() async {
    await _faceDetector.close();
  }
} 