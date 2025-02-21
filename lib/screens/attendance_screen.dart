import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../services/api_service.dart';
import '../models/attendance.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final _apiService = ApiService();
  QRViewController? controller;
  Attendance? todayAttendance;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
  }

  Future<void> _loadTodayAttendance() async {
    try {
      setState(() => isLoading = true);
      final response = await _apiService.getTodayAttendance();
      if (response['success']) {
        setState(() {
          todayAttendance = Attendance.fromJson(response['data']['attendance']);
        });
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (photo == null) throw Exception('No photo was taken');

    final bytes = await photo.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _submitAttendance(String type) async {
    try {
      setState(() => isLoading = true);

      // Get current location
      final position = await _getCurrentLocation();
      
      // Take photo
      final photoBase64 = await _takePhoto();

      // Submit attendance
      await _apiService.storeAttendance(
        type: type,
        photoBase64: photoBase64,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );

      // Reload attendance data
      await _loadTodayAttendance();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance recorded successfully')),
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Attendance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (todayAttendance != null) ...[
                    Text('Check-in: ${todayAttendance?.checkIn ?? 'Not yet'}'),
                    Text('Check-out: ${todayAttendance?.checkOut ?? 'Not yet'}'),
                    Text('Status: ${todayAttendance?.status}'),
                  ] else
                    const Text('No attendance record for today'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (errorMessage != null)
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: todayAttendance?.checkIn == null
                ? () => _submitAttendance('check_in')
                : null,
            child: const Text('Check In'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: todayAttendance?.checkIn != null &&
                    todayAttendance?.checkOut == null
                ? () => _submitAttendance('check_out')
                : null,
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
} 