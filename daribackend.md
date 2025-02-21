# Dokumentasi API Aplikasi

## Langkah-langkah Penggunaan API

1. Autentikasi
   - Login untuk mendapatkan token
   - Gunakan token untuk mengakses endpoint terproteksi
   - Cek info user yang sedang login

2. Manajemen Profil
   - Cek izin update profil
   - Update data profil dan foto

3. Manajemen Absensi
   - Cek absensi hari ini
   - Lihat jadwal
   - Melakukan absensi (check-in/check-out)
   - Melihat riwayat absensi per bulan
   - Mengakses foto absensi
   - Pengelolaan banned attendance

4. Manajemen Cuti
   - Melihat daftar cuti
   - Mengajukan permohonan cuti baru

5. Manajemen File
   - Upload foto
   - Pengelolaan file

6. Pembelajaran
   - Akses aktivitas pembelajaran
   - Cek progress pembelajaran
   - Submit hasil pembelajaran

7. Dashboard
   - Lihat ringkasan dashboard
   - Cek aktivitas terbaru
   - Akses statistik

8. PKL (Praktik Kerja Lapangan)
   - Lihat lokasi PKL
   - Akses data PKL siswa
   - Submit laporan harian
   - Monitor progress PKL

9. Jadwal Ibadah
   - Cek jadwal ibadah
   - Absensi ibadah
   - Lihat statistik kehadiran

10. Akademik
    - Akses informasi kelas
    - Lihat data jurusan
    - Cek mata pelajaran
    - Akses jadwal pelajaran
    - Lihat nilai

11. Ekstrakurikuler
    - Lihat daftar ekstrakurikuler
    - Pendaftaran ekstrakurikuler
    - Cek jadwal kegiatan

12. Bimbingan Konseling
    - Akses riwayat konseling
    - Buat permintaan konseling
    - Lihat data kunjungan rumah
    - Monitor masalah siswa

13. Piket & Perizinan
    - Cek jadwal piket guru
    - Submit laporan piket
    - Akses daftar laporan

14. Manajemen Kehadiran
    - Generate QR Code
    - Cek kehadiran kelas
    - Absensi shalat dhuha
    - Akses peta lokasi
    - Pengelolaan jadwal
    - Manajemen izin

## Autentikasi

Semua endpoint yang memerlukan autentikasi harus menyertakan token Bearer di header:
```
Authorization: Bearer {token}
```

### 1. Login
```
POST /api/login

Request:
{
    "email": "string",
    "password": "string"
}

Response:
{
    "success": true,
    "data": {
        "token": "string",
        "user": {
            "id": integer,
            "name": "string",
            "email": "string",
            "role": "string"
        }
    }
}
```

### 2. Get User Info
```
GET /api/user
Authorization: Bearer {token}

Response:
{
    "id": integer,
    "name": "string",
    "email": "string",
    "role": "string"
}
```

## Profil

### 1. Cek Izin Update Profil
```
GET /profile/check-update-permission

Response:
{
    "success": true,
    "data": {
        "can_update_profile": boolean
    }
}
```

### 2. Update Profil dan Foto
```
POST /api/profile/update
Content-Type: multipart/form-data
Authorization: Bearer {token}

Request:
{
    "name": "string",
    "email": "string",
    "phone": "string|null",
    "password": "string|null",
    "photo": "file|nullable|image|max:2048"
}

Response Success:
{
    "success": true,
    "message": "Profil berhasil diperbarui",
    "data": {
        "user": {
            "id": integer,
            "name": "string",
            "email": "string",
            "phone": "string|null",
            "photo": "string|null"
        }
    }
}

Response Error (Fitur Foto Dinonaktifkan):
{
    "success": false,
    "message": "Fitur upload foto sedang dinonaktifkan",
    "error": "PHOTO_UPLOAD_DISABLED"
}

Response Error (Rate Limit):
{
    "success": false,
    "message": "Terlalu banyak permintaan. Silakan coba lagi nanti.",
    "error": "TOO_MANY_REQUESTS"
}

Catatan:
- Endpoint ini dibatasi 6 request per menit
- File foto harus berformat gambar (jpeg, png, gif) dengan ukuran maksimal 2MB
- Fitur upload foto dapat dinonaktifkan oleh admin
- Setiap perubahan foto akan dicatat dalam sistem audit
```

## Absensi

### 1. Get Absensi Hari Ini
```
GET /api/get-attendance-today
Authorization: Bearer {token}

Response:
{
    "success": true,
    "data": {
        "attendance": {
            "id": integer,
            "user_id": integer,
            "date": "string (Y-m-d)",
            "check_in": "string (H:i:s)",
            "check_out": "string (H:i:s)",
            "status": "string"
        }
    }
}
```

### 2. Get Jadwal
```
GET /api/get-schedule
Authorization: Bearer {token}

Response:
{
    "success": true,
    "data": {
        "schedules": [
            {
                "id": integer,
                "day": "string",
                "start_time": "string (H:i:s)",
                "end_time": "string (H:i:s)"
            }
        ]
    }
}
```

### 3. Simpan Absensi
```
POST /api/store-attendance
Authorization: Bearer {token}

Request:
{
    "type": "string (check_in/check_out)",
    "photo": "base64_string",
    "latitude": "string",
    "longitude": "string"
}

Response:
{
    "success": true,
    "message": "string",
    "data": {
        "attendance": {
            "id": integer,
            "user_id": integer,
            "date": "string (Y-m-d)",
            "check_in": "string (H:i:s)",
            "check_out": "string (H:i:s)",
            "status": "string"
        }
    }
}
```

### 4. Get Absensi per Bulan
```
GET /api/get-attendance-by-month-year/{month}/{year}
Authorization: Bearer {token}

Parameters:
- month: integer (1-12)
- year: integer (YYYY)

Response:
{
    "success": true,
    "data": {
        "attendances": [
            {
                "id": integer,
                "date": "string (Y-m-d)",
                "check_in": "string (H:i:s)",
                "check_out": "string (H:i:s)",
                "status": "string"
            }
        ]
    }
}
```

### 5. Banned Attendance
```
POST /api/banned
Authorization: Bearer {token}

Request:
{
    "user_id": integer,
    "reason": "string"
}

Response:
{
    "success": true,
    "message": "string"
}
```

### 6. Get Photo
```
GET /api/get-photo
Authorization: Bearer {token}

Response:
{
    "success": true,
    "data": {
        "photo_url": "string"
    }
}
```

## Cuti

### 1. Get Daftar Cuti
```
GET /api/leaves
Authorization: Bearer {token}

Response:
{
    "success": true,
    "data": {
        "leaves": [
            {
                "id": integer,
                "user_id": integer,
                "start_date": "string (Y-m-d)",
                "end_date": "string (Y-m-d)",
                "reason": "string",
                "status": "string",
                "created_at": "string (Y-m-d H:i:s)"
            }
        ]
    }
}
```

### 2. Buat Cuti Baru
```
POST /api/leaves
Authorization: Bearer {token}

Request:
{
    "start_date": "string (Y-m-d)",
    "end_date": "string (Y-m-d)",
    "reason": "string"
}

Response:
{
    "success": true,
    "message": "string",
    "data": {
        "leave": {
            "id": integer,
            "user_id": integer,
            "start_date": "string (Y-m-d)",
            "end_date": "string (Y-m-d)",
            "reason": "string",
            "status": "string",
            "created_at": "string (Y-m-d H:i:s)"
        }
    }
}
```

## Upload

### 1. Upload Photo
```
POST /test-upload
Content-Type: multipart/form-data

Form Data:
- photo: File (image, max: 5MB)

Response:
{
    "success": true,
    "message": "File uploaded successfully. Path: {path}"
}
```

## API Learning (Pembelajaran)
- `GET /api/learning/activities` - Mengambil daftar aktivitas pembelajaran
- `GET /api/learning/progress` - Mengambil progress pembelajaran siswa
- `POST /api/learning/submit` - Mengirim hasil aktivitas pembelajaran

## API Dashboard
- `GET /api/dashboard/summary` - Mengambil ringkasan dashboard
- `GET /api/dashboard/recent-activities` - Mengambil aktivitas terbaru
- `GET /api/dashboard/statistics` - Mengambil statistik dashboard

## API PKL (Praktik Kerja Lapangan)
- `GET /api/pkl/locations` - Mendapatkan daftar lokasi PKL
- `GET /api/pkl/student` - Mendapatkan data PKL siswa
- `POST /api/pkl/daily-report` - Mengirim laporan harian PKL
- `GET /api/pkl/progress` - Melihat progress PKL

## API PRAY (Jadwal Ibadah)
- `GET /api/pray/schedule` - Mendapatkan jadwal ibadah hari ini
- `GET /api/pray/attendance` - Melihat kehadiran ibadah pengguna
- `POST /api/pray/mark-attendance` - Menandai kehadiran ibadah
- `GET /api/pray/statistics` - Melihat statistik kehadiran ibadah

## API Akademik
- `GET /api/academic/classes` - Daftar kelas
- `GET /api/academic/student-class` - Info kelas siswa
- `GET /api/academic/majors` - Daftar jurusan
- `GET /api/academic/subjects` - Daftar mata pelajaran
- `GET /api/academic/schedule` - Jadwal pelajaran
- `GET /api/academic/grades` - Nilai siswa

## API Ekstrakurikuler
- `GET /api/extracurricular/activities` - Daftar ekstrakurikuler
- `GET /api/extracurricular/student` - Ekstrakurikuler siswa
- `POST /api/extracurricular/register` - Daftar ekstrakurikuler
- `GET /api/extracurricular/schedule` - Jadwal ekstrakurikuler

## API Bimbingan Konseling
- `GET /api/counseling/history` - Riwayat konseling
- `POST /api/counseling/request` - Permintaan konseling
- `GET /api/counseling/home-visits` - Data kunjungan rumah
- `GET /api/counseling/issues` - Tracking masalah siswa

## API Piket & Perizinan (Duty)
- `GET /api/duty/schedule` - Mendapatkan jadwal piket guru
- `POST /api/duty/report` - Mengirim laporan piket
- `GET /api/duty/reports` - Melihat daftar laporan piket

## API Attendance Management
### QR Code
- `POST /api/attendance/qr-code` - Generate QR Code untuk presensi

### Class Attendance
- `GET /api/attendance/class` - Melihat kehadiran kelas

### Dhuha Prayer
- `GET /api/attendance/dhuha` - Melihat kehadiran shalat dhuha
- `POST /api/attendance/dhuha` - Menandai kehadiran shalat dhuha

### Location Map
- `GET /api/attendance/locations` - Mendapatkan daftar lokasi yang diizinkan untuk presensi

### Schedules
- `GET /api/attendance/schedules` - Mendapatkan jadwal presensi

### Leaves (Izin)
- `POST /api/attendance/leave` - Mengajukan permintaan izin
- `GET /api/attendance/leaves` - Melihat daftar izin

Catatan: Semua endpoint API di atas memerlukan autentikasi menggunakan Laravel Sanctum. Request harus menyertakan token yang valid di header Authorization.

Catatan: Semua response error akan mengikuti format:
```
{
    "success": false,
    "message": "string",
    "errors": {
        "field": [
            "error message"
        ]
    }
}
```

2. Untuk endpoint yang memerlukan autentikasi, jika token tidak valid atau expired, akan mengembalikan response dengan status code 401:
```
{
    "success": false,
    "message": "Unauthenticated"
}
```

3. Untuk upload file:
   - Maksimum ukuran file: 5MB
   - Format yang didukung: jpeg, jpg, png
   - File akan disimpan di storage/app/public/user-photos


   # Dokumentasi Aplikasi Sistem Informasi Manajemen Sekolah

## Tentang Aplikasi

Aplikasi ini adalah Sistem Informasi Manajemen Sekolah yang komprehensif, dirancang untuk memudahkan pengelolaan berbagai aspek administrasi dan kegiatan sekolah. Aplikasi menggunakan framework Laravel dengan Filament sebagai admin panel.

## Fitur Utama

### 1. Manajemen Pengguna
- Multi-role user (Admin, Guru, Siswa)
- Manajemen profil dengan kontrol izin
- Autentikasi aman dengan Laravel Sanctum
- Upload dan manajemen foto profil
- Perubahan password dengan validasi

### 2. Manajemen Akademik
#### a. Kelas dan Jurusan
- Pengelolaan data kelas
- Pengelolaan jurusan
- Penempatan siswa di kelas
- Tracking riwayat kelas siswa

#### b. Penilaian
- Input nilai per mata pelajaran
- Penilaian siswa
- Detail penilaian siswa
- Export nilai ke Excel

#### c. Mata Pelajaran
- Manajemen mata pelajaran
- Aktivitas pengajaran
- Jadwal pelajaran

### 3. Presensi dan Kehadiran
- Presensi guru dan siswa
- Presensi sholat
- Manajemen shift
- Validasi lokasi presensi
- Foto selfie saat presensi
- Laporan kehadiran bulanan
- Export data presensi

### 4. Bimbingan dan Konseling
- Pencatatan konseling
- Home visit
- Tracking masalah siswa
- Laporan bimbingan

### 5. Ekstrakurikuler
- Manajemen ekstrakurikuler
- Pendaftaran siswa
- Pembimbing ekstrakurikuler
- Jadwal kegiatan

### 6. Praktek Kerja Lapangan (PKL)
- Manajemen tempat PKL
- Penempatan siswa
- Jurnal kegiatan
- Bimbingan PKL
- Penilaian PKL

### 7. Piket Guru
- Jadwal piket
- Pencatatan kegiatan piket
- Laporan piket

### 8. Manajemen Cuti
- Pengajuan cuti
- Approval cuti
- Tracking status cuti
- Riwayat cuti

### 9. Pengaturan Sistem
- Pengaturan umum aplikasi
- Kontrol izin fitur
- Manajemen menu
- Grup menu

## Teknologi

### Backend
- Laravel 10
- PHP 8.1+
- MySQL Database
- Laravel Sanctum untuk API authentication
- Filament untuk admin panel

### Keamanan
- Rate limiting untuk API
- Validasi input ketat
- Sanitasi data
- CORS policy
- Audit trail/logging

### Penyimpanan
- Local storage untuk file
- Optimasi gambar
- Backup otomatis

## API

Aplikasi menyediakan REST API lengkap untuk:
- Autentikasi
- Manajemen profil
- Presensi
- Cuti
- Upload file

Detail lengkap API dapat dilihat di file `catatan API`.

## Hak Akses

### Admin
- Akses penuh ke semua fitur
- Manajemen pengguna
- Pengaturan sistem
- Laporan dan export data

### Guru
- Manajemen profil
- Input nilai
- Presensi
- Bimbingan siswa
- Piket
- Pembimbingan PKL
- Pembimbingan ekstrakurikuler

### Siswa
- Lihat nilai
- Presensi
- Jurnal PKL
- Ekstrakurikuler
- Pengajuan konseling
- Manajemen profil (dengan izin)

## Pengembangan Selanjutnya

Beberapa fitur yang direncanakan untuk pengembangan:
1. Integrasi dengan sistem pembayaran
2. Aplikasi mobile untuk siswa dan guru
3. Notifikasi real-time
4. Rapor digital
5. E-learning
6. Perpustakaan digital

## Mobile Application (Flutter)

### Teknologi
- Flutter 3.x
- Dart 3.x
- GetX untuk state management
- Dio untuk HTTP client
- Hive untuk local storage

### Fitur Utama Mobile

#### 1. Presensi dengan Face Recognition
```dart
Implementasi:
- Package: google_ml_kit
- Face detection dengan MLKit
- Face matching dengan custom algorithm
- Liveness detection untuk mencegah spoofing
- Caching foto wajah untuk offline matching
```

Proses Verifikasi:
1. Capture foto wajah
2. Deteksi wajah dengan MLKit
3. Extract facial landmarks
4. Compare dengan foto referensi
5. Validasi liveness
6. Kirim ke server untuk final verification

#### 2. Lokasi dengan OpenStreetMap
```dart
Implementasi:
- Package: flutter_map
- Tiles: OpenStreetMap
- Geolocation: geolocator
- Geocoding untuk konversi koordinat ke alamat
```

Fitur Map:
1. Current location tracking
2. Radius validasi presensi
3. Custom markers untuk:
   - Lokasi user
   - Lokasi sekolah
   - Area yang diizinkan
4. Offline map caching
5. Reverse geocoding untuk detail alamat

### Integrasi dengan Backend

#### Face Recognition API
```http
POST /api/attendance/verify-face
Multipart Form Data:
- photo: File
- reference_photo: File (optional)
- location: {lat: float, lng: float}

Response:
{
    "success": boolean,
    "match_percentage": float,
    "is_live": boolean,
    "location_valid": boolean
}
```

#### Location Validation API
```http
POST /api/attendance/validate-location
Body:
{
    "latitude": float,
    "longitude": float,
    "accuracy": float
}

Response:
{
    "success": boolean,
    "distance_to_target": float,
    "is_within_radius": boolean
}
```

### Keamanan Mobile

#### Face Recognition
- Liveness detection untuk mencegah foto
- Enkripsi data biometrik
- Validasi multiple angle
- Rate limiting untuk attempts
- Logging untuk suspicious activities

#### Location
- Validasi accuracy GPS
- Deteksi mock location
- Timestamp validation
- Path tracking untuk anomaly detection

### Offline Capabilities
1. Face Recognition
   - Caching foto referensi
   - Offline matching
   - Sync saat online

2. Maps
   - Offline map tiles
   - Cached locations
   - Background location updates

### Mobile-Specific Features
1. Notifikasi
   - Push notifications (Firebase)
   - Local notifications
   - Geofencing alerts

2. Optimasi
   - Lazy loading resources
   - Image compression
   - Battery optimization
   - Cache management

3. UX/UI
   - Smooth animations
   - Responsive design
   - Offline indicators
   - Error handling
   - Loading states

### Development & Testing
1. CI/CD
   - Flutter testing
   - Build automation
   - Version management
   - Distribution channels

2. Quality Assurance
   - Unit testing
   - Widget testing
   - Integration testing
   - Performance testing
   - Security testing

## Panduan Penggunaan

Panduan lengkap penggunaan aplikasi tersedia untuk:
1. Admin
2. Guru
3. Siswa

Setiap panduan mencakup:
- Login dan manajemen akun
- Penggunaan fitur-fitur utama
- Troubleshooting umum
- FAQ

## Kontak Support

Untuk bantuan teknis atau pertanyaan, hubungi:
- Email: support@sekolah.id
- Telepon: (021) xxx-xxxx
- Jam kerja: Senin-Jumat, 08.00-16.00 WIB

## Spesifikasi Teknis

### Teknologi Utama
- PHP 8.2+
- Laravel 11.9
- MySQL/MariaDB
- Livewire 3.5
- Filament 3.2

### Package dan Dependencies
#### Core Packages
- Laravel Fortify: Implementasi autentikasi
- Laravel Sanctum: API authentication
- Laravel Permission (Spatie): RBAC dan manajemen izin
- Laravel Backup (Spatie): Backup otomatis database dan file

#### Admin Panel & UI
- Filament: Admin panel utama
- Filament Shield: Manajemen izin berbasis UI
- Filament Map Picker: Pemilihan lokasi untuk presensi
- Filament Excel: Export/import data Excel

#### File & Data Processing
- Maatwebsite Excel: Pengolahan file Excel
- Simple Excel (Spatie): Pengolahan CSV
- Simple QRCode: Generasi QR Code
- Scramble: API documentation generator

### Struktur Aplikasi

#### Controllers

#### API Controllers
```php
app/Http/Controllers/API/
├── AttendanceController.php
│   ├── index()          // Mendapatkan daftar absensi
│   ├── store()          // Menyimpan absensi baru
│   ├── show()           // Menampilkan detail absensi
│   └── getPhotoUrl()    // Mendapatkan URL foto absensi
│
├── AuthController.php
│   ├── login()          // Login user
│   ├── logout()         // Logout user
│   └── refresh()        // Refresh token
│
├── LeaveController.php
│   ├── index()          // Mendapatkan daftar cuti
│   ├── store()          // Mengajukan cuti baru
│   ├── show()           // Menampilkan detail cuti
│   └── update()         // Mengupdate status cuti
│
├── ProfileController.php
│   ├── show()           // Menampilkan profil
│   ├── update()         // Mengupdate profil
│   └── updatePhoto()    // Mengupdate foto profil
│
└── ProfilePermissionController.php
    └── checkPermission() // Mengecek izin update profil
```

#### Admin Controllers (Filament)
```php
app/Filament/Resources/
├── AttendanceResource.php
│   └── Pages/
│       ├── ListAttendances.php
│       ├── CreateAttendance.php
│       └── EditAttendance.php
│
├── LeaveResource.php
│   └── Pages/
│       ├── ListLeaves.php
│       ├── CreateLeave.php
│       └── EditLeave.php
│
├── SettingResource.php
│   └── Pages/
│       ├── ListSettings.php
│       └── EditSetting.php
│
└── UserResource.php
    └── Pages/
        ├── ListUsers.php
        ├── CreateUser.php
        └── EditUser.php
```

### Services
```php
app/Services/
├── AttendanceService.php
│   ├── createAttendance()
│   ├── validateLocation()
│   ├── validatePhoto()
│   └── processAttendancePhoto()
│
├── AuthService.php
│   ├── attemptLogin()
│   ├── createToken()
│   └── revokeToken()
│
├── LeaveService.php
│   ├── createLeave()
│   ├── updateLeaveStatus()
│   └── calculateLeaveDays()
│
├── NotificationService.php
│   ├── sendPushNotification()
│   └── sendEmailNotification()
│
├── ProfileService.php
│   ├── updateProfile()
│   ├── updateProfilePhoto()
│   └── validateProfileData()
│
└── StorageService.php
    ├── storePhoto()
    ├── deletePhoto()
    └── generatePhotoUrl()
```

### Models
```php
app/Models/
├── Attendance.php
│   ├── user()           // Relasi ke User
│   └── attendancePhotos() // Relasi ke AttendancePhoto
│
├── AttendancePhoto.php
│   └── attendance()     // Relasi ke Attendance
│
├── Leave.php
│   ├── user()           // Relasi ke User
│   └── approver()       // Relasi ke User (approver)
│
├── Setting.php
│   └── scope: global()  // Scope untuk pengaturan global
│
└── User.php
    ├── attendances()    // Relasi ke Attendance
    ├── leaves()         // Relasi ke Leave
    ├── roles()          // Relasi ke Role (Spatie)
    └── permissions()    // Relasi ke Permission (Spatie)
```

### Request Validation
```php
app/Http/Requests/
├── AttendanceRequest.php
│   └── rules()
│       ├── photo       // required|image|max:5120
│       ├── latitude    // required|numeric
│       └── longitude   // required|numeric
│
├── LeaveRequest.php
│   └── rules()
│       ├── start_date  // required|date
│       ├── end_date    // required|date|after:start_date
│       └── reason      // required|string|max:500
│
└── ProfileUpdateRequest.php
    └── rules()
        ├── name        // required|string|max:255
        ├── email       // required|email|unique:users
        ├── phone       // required|string|max:15
        └── photo       // nullable|image|max:5120
```

### Resources (API Response)
```php
app/Http/Resources/
├── AttendanceResource.php
├── LeaveResource.php
├── ProfileResource.php
└── UserResource.php
```

### Events
```php
app/Events/
├── AttendanceCreated.php
├── LeaveStatusUpdated.php
└── ProfileUpdated.php
```

### Listeners
```php
app/Listeners/
├── SendAttendanceNotification.php
├── SendLeaveStatusNotification.php
└── UpdateProfileCache.php
```

### Jobs
```php
app/Jobs/
├── ProcessAttendancePhoto.php
├── SyncAttendanceData.php
└── GenerateAttendanceReport.php
```

### Policies
```php
app/Policies/
├── AttendancePolicy.php
├── LeavePolicy.php
└── UserPolicy.php
```

### Database Schema
```sql
-- Tabel utama
users
  ├── id
  ├── name
  ├── email
  ├── password
  ├── phone
  ├── photo
  └── timestamps

attendances
  ├── id
  ├── user_id
  ├── date
  ├── check_in
  ├── check_out
  ├── status
  ├── latitude
  ├── longitude
  └── timestamps

leaves
  ├── id
  ├── user_id
  ├── start_date
  ├── end_date
  ├── reason
  ├── status
  ├── approved_by
  └── timestamps

settings
  ├── id
  ├── key
  ├── value
  └── timestamps

-- Tabel pivot dan tambahan
attendance_photos
  ├── id
  ├── attendance_id
  ├── photo_path
  └── timestamps

model_has_roles
  ├── role_id
  ├── model_type
  └── model_id

model_has_permissions
  ├── permission_id
  ├── model_type
  └── model_id
```

### Security Features

#### Authentication
- Multi-guard authentication (web, api)
- Token-based API authentication
- Password policies
- Login throttling

#### Authorization
- Role-Based Access Control (RBAC)
- Permission-based access
- Resource policies
- Gate definitions

#### Data Protection
- Input validation
- SQL injection prevention
- XSS protection
- CSRF protection
- Rate limiting

### Logging & Monitoring
- Activity logging
- Error logging
- Login attempts
- Profile updates
- Critical actions
- Backup status

### Development Tools
- Laravel Sail: Docker development
- Laravel Pint: Code style fixer
- PHPUnit: Testing
- Collision: CLI error handling
- Faker: Test data generation

### Deployment
- Optimized autoloader
- Asset publishing
- Database migrations
- Automatic discovery
- Environment configuration

### Maintenance
- Automated backups
- Database optimization
- Cache management
- Log rotation
- Health checks

### Dependencies Mobile
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
  google_ml_kit_face_detection: ^0.9.0
  
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
```

### Struktur Proyek Mobile
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

### Implementasi Utama

#### 1. Network Client
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

  Future<dynamic> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Tambahkan token ke header
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}
```

#### 2. Face Recognition Service
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
    // Konversi CameraImage ke InputImage
    final inputImage = await _convertCameraImage(image);
    
    // Deteksi wajah
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return false;
    
    // Cek kedipan mata
    final face = faces.first;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0;
    
    return _validateLiveness(leftEyeOpen, rightEyeOpen);
  }
  
  bool _validateLiveness(double leftEye, double rightEye) {
    // Implementasi validasi kedipan mata
    const threshold = 0.2;
    return leftEye < threshold && rightEye < threshold;
  }
}
```

#### 3. Location Service
```dart
class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Layanan lokasi tidak aktif');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Izin lokasi ditolak');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  static bool isWithinRadius(LatLng point1, LatLng point2, double radius) {
    final distance = Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
    return distance <= radius;
  }
}
```

#### 4. Attendance Repository
```dart
class AttendanceRepository {
  final DioClient _client;
  final HiveInterface _hive;
  
  Future<void> submitAttendance(File photo, Position location) async {
    try {
      // Proses foto
      final processedPhoto = await ImageProcessor.processAttendancePhoto(photo);
      
      // Buat form data
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(processedPhoto.path),
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Kirim ke server
      final response = await _client.post('/api/store-attendance', data: formData);
      
      // Simpan ke cache lokal
      await _saveToLocalCache(response.data);
      
    } catch (e) {
      // Simpan ke antrian offline
      await _saveToOfflineQueue(photo, location);
      throw AttendanceException('Gagal mengirim absensi: $e');
    }
  }
  
  Future<void> _saveToLocalCache(Map<String, dynamic> data) async {
    final box = await _hive.openBox<AttendanceModel>('attendance');
    await box.add(AttendanceModel.fromJson(data));
  }
  
  Future<void> _saveToOfflineQueue(File photo, Position location) async {
    final box = await _hive.openBox<OfflineAttendance>('offline_queue');
    await box.add(OfflineAttendance(
      photoPath: photo.path,
      location: location,
      timestamp: DateTime.now(),
    ));
  }
}
```

#### 5. Background Service
```dart
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  // Inisialisasi service
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  
  // Sinkronisasi data offline
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    await syncOfflineData();
  });
  
  // Update lokasi background
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    final location = await LocationService.getCurrentLocation();
    service.invoke(
      'updateLocation',
      {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    );
  });
}

Future<void> syncOfflineData() async {
  final box = await Hive.openBox<OfflineAttendance>('offline_queue');
  final items = box.values.toList();
  
  for (final item in items) {
    try {
      await AttendanceRepository().submitAttendance(
        File(item.photoPath),
        item.location,
      );
      await box.delete(item.key);
    } catch (e) {
      LoggingService.logError(e, StackTrace.current);
    }
  }
}
```

#### 6. Security Service
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
  
  static IOSOptions _getIOSOptions() => const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    synchronizable: true,
  );
  
  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
    keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  );
}
```

### Testing

#### 1. Unit Tests
```dart
void main() {
  group('Face Detection Service Tests', () {
    late FaceDetectionService service;
    late MockFaceDetector mockDetector;
    
    setUp(() {
      mockDetector = MockFaceDetector();
      service = FaceDetectionService(detector: mockDetector);
    });
    
    test('should detect valid face', () async {
      // Arrange
      final mockImage = MockInputImage();
      when(mockDetector.processImage(mockImage))
          .thenAnswer((_) async => [MockFace()]);
          
      // Act
      final result = await service.detectLiveness(mockImage);
      
      // Assert
      expect(result, true);
    });
  });
}
```

#### 2. Widget Tests
```dart
void main() {
  group('Attendance Screen Tests', () {
    testWidgets('should show camera preview', (tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: AttendanceScreen(),
      ));
      
      // Act & Assert
      expect(find.byType(CameraPreview), findsOneWidget);
    });
    
    testWidgets('should show loading when submitting', (tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: AttendanceScreen(),
      ));
      
      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### Performa & Optimisasi

1. Image Processing
```dart
class ImageProcessor {
  static Future<File> processAttendancePhoto(File originalFile) async {
    // Kompresi
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalFile.path,
      originalFile.path.replaceAll('.jpg', '_compressed.jpg'),
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );
    
    // Watermark
    final watermarkedFile = await addWatermark(
      compressedFile!,
      DateTime.now().toString(),
    );
    
    return watermarkedFile;
  }
  
  static Future<File> addWatermark(File image, String text) async {
    final img = await decodeImageFile(image.path);
    final watermark = drawText(text, color: Colors.white);
    
    final watermarked = overlayImage(img, watermark);
    final output = File(image.path.replaceAll('.jpg', '_watermarked.jpg'));
    
    await encodeJpgFile(output.path, watermarked);
    return output;
  }
}
```

2. Caching Strategy
```dart
class CacheManager {
  static const Duration maxAge = Duration(days: 7);
  
  static Future<File?> getCachedImage(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    if (await file.exists()) {
      final stat = await file.stat();
      if (DateTime.now().difference(stat.modified) < maxAge) {
        return file;
      }
    }
    return null;
  }
  
  static Future<void> clearOldCache() async {
    await DefaultCacheManager().emptyCache();
  }
}
```

### Routes

#### Web Routes (web.php)
```php
// Authentication
Route::middleware('guest')->group(function () {
    Route::get('login', [AuthenticatedSessionController::class, 'create'])
        ->name('login');
    Route::post('login', [AuthenticatedSessionController::class, 'store']);
});

Route::middleware('auth')->group(function () {
    Route::post('logout', [AuthenticatedSessionController::class, 'destroy'])
        ->name('logout');
});

// Profile Management
Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])
        ->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])
        ->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])
        ->name('profile.destroy');
    Route::get('/profile/check-update-permission', [ProfilePermissionController::class, 'checkPermission'])
        ->name('profile.check-permission');
});

// Admin Panel (Filament)
Route::middleware([
    'auth:sanctum',
    config('filament.auth.guard'),
    'verified',
])->group(function () {
    Route::get('/admin', AdminPanelProvider::class)
        ->name('filament.admin.index');
});

// File Downloads
Route::middleware(['auth:sanctum', 'signed'])->group(function () {
    Route::get('/attendance/photo/{filename}', [AttendanceController::class, 'downloadPhoto'])
        ->name('attendance.photo.download');
    Route::get('/profile/photo/{filename}', [ProfileController::class, 'downloadPhoto'])
        ->name('profile.photo.download');
});
```

#### API Routes (api.php)
```php
// Authentication
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])
    ->middleware('auth:sanctum');
Route::post('/refresh', [AuthController::class, 'refresh'])
    ->middleware('auth:sanctum');

// Protected Routes
Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
    // Profile Management
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::post('/profile/update', [ProfileController::class, 'update']);
    Route::post('/profile/photo', [ProfileController::class, 'updatePhoto']);
    Route::get('/profile/check-update-permission', [ProfilePermissionController::class, 'checkPermission']);

    // Attendance Management
    Route::get('/attendance/today', [AttendanceController::class, 'getToday']);
    Route::get('/attendance/schedule', [AttendanceController::class, 'getSchedule']);
    Route::post('/attendance/store', [AttendanceController::class, 'store']);
    Route::get('/attendance/month/{month}/{year}', [AttendanceController::class, 'getByMonthYear']);
    Route::get('/attendance/photo/{id}', [AttendanceController::class, 'getPhoto']);
    
    // Leave Management
    Route::get('/leaves', [LeaveController::class, 'index']);
    Route::post('/leaves', [LeaveController::class, 'store']);
    Route::get('/leaves/{id}', [LeaveController::class, 'show']);
    Route::put('/leaves/{id}', [LeaveController::class, 'update']);
    
    // Settings
    Route::get('/settings', [SettingController::class, 'index']);
    Route::get('/settings/{key}', [SettingController::class, 'show']);
});
```

### Database Migrations

```php
// 2014_10_12_000000_create_users_table.php
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('email')->unique();
    $table->string('password');
    $table->string('phone')->nullable();
    $table->string('photo')->nullable();
    $table->rememberToken();
    $table->timestamps();
});

// 2014_10_12_100000_create_password_reset_tokens_table.php
Schema::create('password_reset_tokens', function (Blueprint $table) {
    $table->string('email')->primary();
    $table->string('token');
    $table->timestamp('created_at')->nullable();
});

// 2019_12_14_000001_create_personal_access_tokens_table.php
Schema::create('personal_access_tokens', function (Blueprint $table) {
    $table->id();
    $table->morphs('tokenable');
    $table->string('name');
    $table->string('token', 64)->unique();
    $table->text('abilities')->nullable();
    $table->timestamp('last_used_at')->nullable();
    $table->timestamp('expires_at')->nullable();
    $table->timestamps();
});

// 2024_01_15_000001_create_permission_tables.php
Schema::create('permissions', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('guard_name');
    $table->timestamps();
});

Schema::create('roles', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('guard_name');
    $table->timestamps();
});

Schema::create('model_has_permissions', function (Blueprint $table) {
    $table->unsignedBigInteger('permission_id');
    $table->string('model_type');
    $table->unsignedBigInteger('model_id');
    $table->primary(['permission_id', 'model_id', 'model_type']);
});

Schema::create('model_has_roles', function (Blueprint $table) {
    $table->unsignedBigInteger('role_id');
    $table->string('model_type');
    $table->unsignedBigInteger('model_id');
    $table->primary(['role_id', 'model_id', 'model_type']);
});

Schema::create('role_has_permissions', function (Blueprint $table) {
    $table->unsignedBigInteger('permission_id');
    $table->unsignedBigInteger('role_id');
    $table->primary(['permission_id', 'role_id']);
});

// 2024_01_20_000001_create_attendances_table.php
Schema::create('attendances', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->date('date');
    $table->time('check_in')->nullable();
    $table->time('check_out')->nullable();
    $table->enum('status', ['present', 'late', 'absent']);
    $table->decimal('latitude', 10, 8)->nullable();
    $table->decimal('longitude', 11, 8)->nullable();
    $table->timestamps();
});

// 2024_01_20_000002_create_attendance_photos_table.php
Schema::create('attendance_photos', function (Blueprint $table) {
    $table->id();
    $table->foreignId('attendance_id')->constrained()->onDelete('cascade');
    $table->string('photo_path');
    $table->enum('type', ['check_in', 'check_out']);
    $table->timestamps();
});

// 2024_01_25_000001_create_leaves_table.php
Schema::create('leaves', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->date('start_date');
    $table->date('end_date');
    $table->text('reason');
    $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
    $table->foreignId('approved_by')->nullable()->constrained('users');
    $table->text('rejection_reason')->nullable();
    $table->timestamps();
});

// 2024_02_01_000001_create_settings_table.php
Schema::create('settings', function (Blueprint $table) {
    $table->id();
    $table->string('key')->unique();
    $table->text('value')->nullable();
    $table->string('group')->nullable();
    $table->text('description')->nullable();
    $table->boolean('is_public')->default(false);
    $table->timestamps();
});

// 2024_02_18_162803_add_allow_profile_updates_to_settings_table.php
Schema::table('settings', function (Blueprint $table) {
    $table->boolean('allow_profile_updates')->default(true);
});

// 2024_02_10_000001_create_notifications_table.php
Schema::create('notifications', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('type');
    $table->morphs('notifiable');
    $table->text('data');
    $table->timestamp('read_at')->nullable();
    $table->timestamps();
});

// 2024_02_15_000001_create_failed_jobs_table.php
Schema::create('failed_jobs', function (Blueprint $table) {
    $table->id();
    $table->string('uuid')->unique();
    $table->text('connection');
    $table->text('queue');
    $table->longText('payload');
    $table->longText('exception');
    $table->timestamp('failed_at')->useCurrent();
});

// 2024_02_15_000002_create_jobs_table.php
Schema::create('jobs', function (Blueprint $table) {
    $table->id();
    $table->string('queue')->index();
    $table->longText('payload');
    $table->unsignedTinyInteger('attempts');
    $table->unsignedInteger('reserved_at')->nullable();
    $table->unsignedInteger('available_at');
    $table->unsignedInteger('created_at');
});
```

### Panduan Developer

### Environment Setup

1. Prasyarat Sistem
```bash
# Backend Requirements
PHP >= 8.2
Composer >= 2.5
MySQL >= 8.0
Node.js >= 18
npm >= 9.0

# Mobile Requirements
Flutter >= 3.16
Dart >= 3.2
Android Studio / VS Code
Android SDK
```

2. Environment Variables
```bash
# Backend (.env)
APP_NAME="SMKN 1 Punggelan"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sim3
DB_USERNAME=root
DB_PASSWORD=

# JWT Secret untuk API authentication
JWT_SECRET=
JWT_TTL=60
JWT_REFRESH_TTL=20160

# Storage Configuration
FILESYSTEM_DISK=local
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=
AWS_BUCKET=

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=
MAIL_FROM_NAME="${APP_NAME}"

# Push Notification
FCM_SERVER_KEY=
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=

# Mobile (.env)
API_BASE_URL=http://localhost:8000
GOOGLE_MAPS_API_KEY=
SENTRY_DSN=
```

3. Instalasi & Setup
```bash
# Clone repository
git clone https://github.com/idiarso4/sim3.git
cd sim3

# Install PHP dependencies
composer install

# Install Node.js dependencies
npm install

# Generate app key
php artisan key:generate

# Run database migrations
php artisan migrate

# Seed database dengan data awal
php artisan db:seed

# Install Flutter dependencies
cd mobile
flutter pub get

# Build assets
npm run build

# Start development server
php artisan serve
```

### Konvensi Kode

1. Penamaan
```php
// Classes menggunakan PascalCase
class UserController {}

// Methods dan variables menggunakan camelCase
public function getUserProfile() {}
$userProfile = [];

// Constants menggunakan UPPER_CASE
const MAX_LOGIN_ATTEMPTS = 5;

// Files menggunakan snake_case
create_user_table.php
user_controller.php
```

2. Dokumentasi
```php
/**
 * Membuat absensi baru dengan validasi foto dan lokasi
 *
 * @param AttendanceRequest $request Request yang sudah divalidasi
 * @return JsonResponse
 * 
 * @throws LocationException Jika lokasi di luar radius yang diizinkan
 * @throws PhotoValidationException Jika foto tidak valid atau tidak terdeteksi wajah
 * @throws StorageException Jika gagal menyimpan foto
 */
public function store(AttendanceRequest $request): JsonResponse
{
    // Implementation
}
```

3. Error Handling
```php
try {
    // Proses bisnis
} catch (LocationException $e) {
    Log::error('Location validation failed', [
        'user_id' => auth()->id(),
        'error' => $e->getMessage(),
        'coordinates' => $request->only(['latitude', 'longitude'])
    ]);
    return $this->errorResponse('Lokasi Anda di luar area yang diizinkan', 422);
} catch (Exception $e) {
    Log::error('Unexpected error', [
        'message' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
    return $this->errorResponse('Terjadi kesalahan sistem', 500);
}
```

### Workflow Development

1. Git Flow
```bash
# Feature baru
git checkout -b feature/nama-fitur
# Bug fixes
git checkout -b fix/nama-bug
# Hotfix
git checkout -b hotfix/nama-hotfix

# Sebelum merge ke main
git checkout main
git pull origin main
git checkout feature/nama-fitur
git rebase main
git push origin feature/nama-fitur --force
```

2. Code Review Checklist
- [ ] Kode mengikuti konvensi penamaan
- [ ] Dokumentasi lengkap (PHPDoc, README)
- [ ] Unit tests untuk fungsi kritis
- [ ] Error handling yang tepat
- [ ] Tidak ada hardcoded values
- [ ] Security best practices
- [ ] Performance considerations
- [ ] Mobile responsive design

3. Deployment Checklist
```bash
# 1. Backup database
php artisan backup:run

# 2. Maintenance mode
php artisan down

# 3. Pull changes
git pull origin main

# 4. Install dependencies
composer install --no-dev --optimize-autoloader
npm install --production

# 5. Clear cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 6. Run migrations
php artisan migrate --force

# 7. Build assets
npm run build

# 8. Restart services
sudo supervisorctl restart all

# 9. Exit maintenance mode
php artisan up
```

### Troubleshooting

1. Common Issues
```bash
# Issue: Permission denied pada storage
sudo chown -R www-data:www-data storage
sudo chmod -R 775 storage

# Issue: Cache issues
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Issue: Composer autoload issues
composer dump-autoload

# Issue: Node modules issues
rm -rf node_modules
npm cache clean --force
npm install
```

2. Logging
```php
// Log locations
storage/logs/laravel.log    # Laravel logs
storage/logs/queue.log      # Queue worker logs
storage/logs/scheduler.log  # Task scheduler logs

// Mobile logs
mobile/logs/                # Flutter app logs
```

3. Monitoring
```bash
# Check queue status
php artisan queue:monitor

# Check failed jobs
php artisan queue:failed

# Check server status
php artisan server:status

# Check storage usage
php artisan storage:status
```

### Security Checklist

1. API Security
- [ ] Rate limiting configured
- [ ] JWT tokens dengan expiry
- [ ] Input validation
- [ ] SQL injection prevention
- [ ] XSS protection
- [ ] CORS policy
- [ ] File upload validation

2. Mobile Security
- [ ] Certificate pinning
- [ ] Biometric authentication
- [ ] Secure storage
- [ ] Anti-screenshot protection
- [ ] Root detection
- [ ] SSL pinning
- [ ] Code obfuscation

3. Server Security
- [ ] Firewall configured
- [ ] Regular security updates
- [ ] SSL certificates
- [ ] Database backup
- [ ] File permissions
- [ ] Error reporting disabled in production
- [ ] Environment variables protected

### Performance Optimization

1. Backend
```php
// Cache Configuration
'stores' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'cache',
        'lock_connection' => 'default',
    ],
],

// Queue Configuration
'connections' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => env('REDIS_QUEUE', 'default'),
        'retry_after' => 90,
        'block_for' => null,
    ],
],
```

2. Mobile
```dart
// Image Caching
final config = CacheManagerLogic(
  maxNrOfCacheObjects: 100,
  stalePeriod: const Duration(days: 7),
);

// Background Fetch
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  // Sync data in background
}
```

3. Database
```sql
-- Indexes yang dioptimasi
CREATE INDEX idx_attendances_user_date ON attendances(user_id, date);
CREATE INDEX idx_leaves_user_status ON leaves(user_id, status);
CREATE INDEX idx_settings_key_group ON settings(key, group);
```

### Integrasi & Dependencies

1. Third Party Services
```yaml
# Payment Gateway
- Midtrans
  - Production: https://api.midtrans.com
  - Sandbox: https://api.sandbox.midtrans.com
  - Documentation: https://docs.midtrans.com

# SMS Gateway
- Twilio
  - API Base: https://api.twilio.com
  - Documentation: https://www.twilio.com/docs

# Maps
- Google Maps Platform
  - API Key configuration
  - Geocoding API
  - Places API
  - Maps SDK for Android/iOS
```

2. External APIs
```yaml
# Face Recognition
- Google ML Kit
  - Face Detection
  - Face Recognition
  - Liveness Detection

# Location Services
- Geolocator
  - GPS Tracking
  - Geofencing
  - Location Accuracy

# Push Notifications
- Firebase Cloud Messaging
  - Topic Subscription
  - Token Management
  - Notification Channels
```

### Maintenance & Updates

1. Backup Strategy
```bash
# Database backup (daily)
0 0 * * * /usr/bin/php /var/www/app1/artisan backup:run

# File backup (weekly)
0 0 * * 0 /usr/bin/rsync -av /var/www/app1/storage/app /backup/storage

# Cleanup old backups (monthly)
0 0 1 * * /usr/bin/php /var/www/app1/artisan backup:clean
```

2. Update Procedure
```bash
# 1. Check for updates
composer outdated
npm outdated
flutter pub outdated

# 2. Update dependencies
composer update
npm update
flutter pub upgrade

# 3. Test after updates
php artisan test
flutter test

# 4. Document changes
- Update CHANGELOG.md
- Update version numbers
- Update documentation
```

3. Monitoring & Alerts
```php
// Health checks
Route::get('/health', function () {
    return [
        'status' => 'ok',
        'version' => config('app.version'),
        'database' => DB::connection()->getPdo() ? 'ok' : 'error',
        'storage' => Storage::disk('local')->exists('test.txt') ? 'ok' : 'error',
        'cache' => Cache::store()->get('test-key') ? 'ok' : 'error',
        'queue' => Queue::size() < 100 ? 'ok' : 'warning'
    ];
});

// Error notifications
Log::error('Critical error', [
    'user' => auth()->user(),
    'action' => 'attendance.store',
    'error' => $exception->getMessage()
]);