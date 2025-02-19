# Aplikasi Absensi SMKN 1 Punggelan

Aplikasi absensi mobile untuk SMKN 1 Punggelan yang memungkinkan siswa dan guru untuk melakukan absensi secara digital dengan fitur foto selfie dan lokasi GPS.

## Fitur Utama

### 1. Autentikasi & Keamanan
- Login dengan email dan password
- Token-based authentication
- Auto logout saat token expired
- Rate limiting untuk keamanan API
- Validasi input untuk mencegah injeksi

### 2. Manajemen Profil
- Lihat dan edit informasi profil
- Update foto profil dengan preview
- Validasi format dan ukuran foto (max 5MB)
- Kontrol izin update profil oleh admin
- Rate limiting (6 request/menit)
- Riwayat perubahan profil (audit trail)

### 3. Absensi Digital
- Check-in dan check-out dengan foto selfie
- Validasi lokasi GPS
- Deteksi jam kerja berdasarkan jadwal
- Status absensi (Hadir, Terlambat, Alpha)
- Riwayat absensi bulanan
- Export data absensi (PDF/Excel)

### 4. Manajemen Cuti
- Pengajuan cuti dengan alasan
- Pilih tanggal mulai dan selesai
- Status persetujuan cuti
- Riwayat pengajuan cuti
- Notifikasi status cuti

### 5. Dashboard & Laporan
- Ringkasan absensi harian
- Statistik kehadiran bulanan
- Grafik keterlambatan
- Filter dan pencarian data
- Export laporan dalam berbagai format

## Teknologi

### Frontend (Mobile)
- Flutter 3.x
- Provider untuk state management
- Dio untuk HTTP client
- SharedPreferences untuk local storage
- Image picker & cropper
- Geolocator untuk GPS
- Local notifications

### Backend
- Laravel 10.x
- MySQL database
- JWT authentication
- API rate limiting
- File storage (foto profil & absensi)
- Background jobs untuk notifikasi
- Admin panel dengan Filament

## Keamanan

### Autentikasi
- Token JWT dengan expiry
- Refresh token mechanism
- Password hashing (bcrypt)
- HTTPS untuk semua komunikasi
- Validasi token di setiap request

### Data Protection
- Enkripsi data sensitif
- Rate limiting untuk mencegah abuse
- Validasi input ketat
- Sanitasi output
- Audit logging

### File Upload
- Validasi tipe file
- Batasan ukuran (5MB)
- Scan virus/malware
- Nama file yang aman
- Penyimpanan terenkripsi

## Performa

### Optimisasi
- Lazy loading untuk gambar
- Caching data lokal
- Kompresi gambar
- Pagination untuk data besar
- Background processing

### Offline Support
- Caching data offline
- Queue untuk absensi offline
- Sinkronisasi otomatis
- Conflict resolution

## Implementasi Teknis

### 1. Consume REST API
- Dio HTTP Client dengan interceptor untuk:
  - Token management (Bearer token)
  - Error handling global
  - Request/response logging
  - Retry mechanism
  - Timeout handling
```dart
class DioClient {
  late Dio _dio;
  
  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }
}
```

### 2. Face Recognition & Liveness Detection
- Google ML Kit untuk deteksi wajah
- Custom liveness detection dengan:
  - Deteksi kedipan mata
  - Deteksi gerakan kepala
  - Anti spoofing detection
```dart
class FaceDetectionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );
  
  Future<bool> detectLiveness(CameraImage image) async {
    // Implementasi liveness detection
  }
}
```

### 3. Location Services
- OpenStreetMap untuk visualisasi lokasi
- Geolocator untuk tracking GPS
- Geocoding untuk konversi koordinat
- Geofencing untuk validasi lokasi
```dart
class LocationService {
  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  static bool isWithinRadius(LatLng point1, LatLng point2, double radius) {
    // Validasi radius lokasi
  }
}
```

### 4. Local Storage & Caching
- Hive untuk penyimpanan data offline
- SharedPreferences untuk user preferences
- SQLite untuk data kompleks
- Cache manager untuk gambar
```dart
@HiveType(typeId: 0)
class AttendanceBox extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late DateTime checkInTime;
  
  @HiveField(2)
  late String photoPath;
}
```

### 5. Background Services
- WorkManager untuk task scheduling
- Firebase Cloud Messaging untuk notifikasi
- Background location updates
- Offline sync queue
```dart
class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
}
```

### 6. Image Processing
- Image cropping dengan aspect ratio tetap
- Kompresi gambar otomatis
- Watermarking (timestamp & lokasi)
- Caching gambar dengan CacheManager
```dart
class ImageProcessor {
  static Future<File> processAttendancePhoto(File originalFile) async {
    // Kompresi
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalFile.path,
      originalFile.path.replaceAll('.jpg', '_compressed.jpg'),
      quality: 70,
    );
    
    // Watermark
    final watermarkedFile = await addWatermark(
      compressedFile!,
      DateTime.now().toString(),
    );
    
    return watermarkedFile;
  }
}
```

### 7. State Management
- Provider untuk state management
- Repository pattern untuk data layer
- Service locator (get_it)
- Clean architecture
```dart
class AttendanceNotifier extends ChangeNotifier {
  final AttendanceRepository _repository;
  final LocationService _locationService;
  final FaceDetectionService _faceService;
  
  Future<void> submitAttendance(File photo) async {
    try {
      // 1. Validasi wajah
      final isLive = await _faceService.detectLiveness(photo);
      if (!isLive) throw Exception('Liveness check failed');
      
      // 2. Validasi lokasi
      final location = await _locationService.getCurrentLocation();
      final isWithinRadius = _locationService.isWithinRadius(/*...*/);
      if (!isWithinRadius) throw Exception('Location validation failed');
      
      // 3. Proses gambar
      final processedPhoto = await ImageProcessor.processAttendancePhoto(photo);
      
      // 4. Submit ke server
      await _repository.submitAttendance(processedPhoto, location);
      
    } catch (e) {
      // Handle error
    }
  }
}
```

### 8. Custom UI Components
- Skeleton loading
- Pull to refresh
- Infinite scroll
- Custom camera overlay
- Shimmer effect
```dart
class CustomCameraOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Face outline
        CustomPaint(
          painter: FaceOutlinePainter(),
        ),
        // Guidelines
        Positioned(
          bottom: 20,
          child: Text('Posisikan wajah Anda di dalam garis'),
        ),
      ],
    );
  }
}
```

### 9. Error Handling & Logging
- Sentry.io untuk error tracking
- Custom error handling
- Crashlytics integration
- Debug & release logging
```dart
class LoggingService {
  static Future<void> logError(
    dynamic error,
    StackTrace stackTrace,
    {String? context}
  ) async {
    if (kReleaseMode) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: context,
      );
    } else {
      print('Error: $error\nContext: $context\n$stackTrace');
    }
  }
}
```

### 10. Security
- Certificate pinning
- Biometric authentication
- Secure storage untuk sensitive data
- Anti-screenshot protection
```dart
class SecurityService {
  static Future<void> initializeSecurity() async {
    // Certificate pinning
    Dio().httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          return _validateCertificate(cert.fingerprint);
        };
        return client;
      },
    );
    
    // Secure storage
    final storage = FlutterSecureStorage();
    await storage.write(
      key: 'api_key',
      value: 'secret_key',
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }
}
```

### 11. Testing
- Unit tests dengan mockito
- Widget tests
- Integration tests
- Performance testing
```dart
void main() {
  group('Attendance Service Tests', () {
    late MockAttendanceRepository mockRepository;
    late MockLocationService mockLocationService;
    late AttendanceService service;
    
    setUp(() {
      mockRepository = MockAttendanceRepository();
      mockLocationService = MockLocationService();
      service = AttendanceService(
        repository: mockRepository,
        locationService: mockLocationService,
      );
    });
    
    test('submit attendance success', () async {
      // Test implementation
    });
  });
}
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Networking
  dio: ^5.5.0
  connectivity_plus: ^5.0.0
  
  # State Management
  provider: ^6.1.1
  get_it: ^7.6.4
  
  # Storage
  hive: ^2.2.3
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  
  # Location
  geolocator: ^10.1.0
  flutter_map: ^6.0.1
  geocoding: ^2.1.1
  
  # Camera & Image
  camera: ^0.10.5+9
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
  flutter_image_compress: ^2.1.0
  
  # Face Detection
  google_mlkit_face_detection: ^0.9.0
  
  # Background Services
  workmanager: ^0.5.2
  flutter_background_service: ^5.0.5
  
  # Security
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.8
  
  # Logging & Analytics
  sentry_flutter: ^7.14.0
  firebase_crashlytics: ^3.4.8
  
  # UI Components
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1
  flutter_spinkit: ^5.2.0
  
dev_dependencies:
  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
```

## Pengaturan Proyek

### Prasyarat
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code
- Git

### Instalasi
1. Clone repository
```bash
git clone [repository-url]
cd absensi-smkn1-punggelan
```

2. Install dependencies
```bash
flutter pub get
```

3. Setup environment
```bash
cp .env.example .env
# Edit .env sesuai konfigurasi
```

4. Run aplikasi
```bash
flutter run
```

### Build & Deploy
- Debug: `flutter build apk --debug`
- Release: `flutter build apk --release`
- Bundle: `flutter build appbundle`

## Struktur Proyek
```
lib/
├── app/
│   ├── data/
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   └── entities/
│   └── presentation/
│       ├── home/
│       ├── profile/
│       ├── attendance/
│       └── leave/
├── core/
│   ├── config/
│   ├── network/
│   └── utils/
└── main.dart
```

## API Endpoints

### Autentikasi
- POST /api/login
- GET /api/user

### Profil
- GET /profile/check-update-permission
- POST /api/profile/update

### Absensi
- GET /api/get-attendance-today
- GET /api/get-schedule
- POST /api/store-attendance
- GET /api/get-attendance-by-month-year/{month}/{year}
- POST /api/banned
- GET /api/get-photo

### Cuti
- GET /api/leaves
- POST /api/leaves

## Kontribusi

1. Fork repository
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## Lisensi

Hak Cipta 2024 SMKN 1 Punggelan. All rights reserved.

## Kontak

SMKN 1 Punggelan - [@smkn1punggelan](https://twitter.com/smkn1punggelan)

Project Link: [https://github.com/smkn1punggelan/absensi-app](https://github.com/smkn1punggelan/absensi-app)
