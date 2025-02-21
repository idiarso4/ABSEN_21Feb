import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'camera_screen.dart';

class AttendanceCaptureScreen extends StatefulWidget {
  final String attendanceType; // 'check_in' or 'check_out'

  const AttendanceCaptureScreen({
    Key? key,
    required this.attendanceType,
  }) : super(key: key);

  @override
  State<AttendanceCaptureScreen> createState() => _AttendanceCaptureScreenState();
}

class _AttendanceCaptureScreenState extends State<AttendanceCaptureScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _errorMessage = 'Location services are disabled');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _errorMessage = 'Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _errorMessage = 
        'Location permissions are permanently denied, please enable in settings');
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handlePhotoCapture(String imagePath) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) return;

      // Convert image to base64
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Submit attendance
      await _apiService.storeAttendance(
        type: widget.attendanceType,
        photoBase64: base64Image,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance recorded successfully')),
        );
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.attendanceType == 'check_in' ? 'Check In' : 'Check Out'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraScreen(
              onPhotoCapture: _handlePhotoCapture,
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
} 