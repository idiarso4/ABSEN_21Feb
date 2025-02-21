import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/attendance.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  final _connectivity = Connectivity();
  int _currentIndex = 0;
  User? _user;
  Attendance? _todayAttendance;
  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _setupConnectivityListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((result) async {
      final wasOffline = _isOffline;
      final isNowOffline = result == ConnectivityResult.none;
      
      if (mounted) {
        setState(() => _isOffline = isNowOffline);
      }

      if (wasOffline && !isNowOffline) {
        // Connection restored - sync data
        await _syncData();
      }
    });
  }

  Future<void> _syncData() async {
    if (!mounted) return;

    setState(() => _isRefreshing = true);
    
    try {
      // Check connectivity first
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Tidak ada koneksi internet');
      }

      // Try to sync pending attendances
      await _apiService.syncPendingAttendances();
      
      // Reload all data
      await _loadInitialData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disinkronkan')),
        );
      }
    } catch (e) {
      print('Error syncing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal sinkronisasi: ${e.toString()}'),
            action: SnackBarAction(
              label: 'COBA LAGI',
              onPressed: _syncData,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOffline = connectivityResult == ConnectivityResult.none;

      if (mounted) {
        setState(() => _isOffline = isOffline);
      }

      // Try to load user info
      try {
        final userInfo = await _apiService.getUserInfo();
        if (mounted && userInfo['success'] == true && userInfo['data'] != null) {
          setState(() => _user = User.fromJson(userInfo['data']));
        }
      } catch (e) {
        print('Error loading user info: $e');
        // If offline, try to get cached user data
        if (isOffline) {
          final prefs = await SharedPreferences.getInstance();
          final cachedUserData = prefs.getString('cached_user_data');
          if (cachedUserData != null) {
            try {
              final userData = jsonDecode(cachedUserData);
              if (mounted) {
                setState(() => _user = User.fromJson(userData));
              }
            } catch (e) {
              print('Error loading cached user data: $e');
            }
          }
        }
      }

      // Then try to load attendance if we have user data
      if (_user != null) {
        try {
          final response = await _apiService.getTodayAttendance();
          if (mounted && response['success'] == true && response['data'] != null) {
            setState(() => _todayAttendance = Attendance.fromJson(response['data']));
          }
        } catch (e) {
          print('Error loading attendance: $e');
          // If offline, try to get cached attendance data
          if (isOffline) {
            final prefs = await SharedPreferences.getInstance();
            final cachedAttendanceData = prefs.getString('cached_attendance_data');
            if (cachedAttendanceData != null) {
              try {
                final attendanceData = jsonDecode(cachedAttendanceData);
                if (mounted) {
                  setState(() => _todayAttendance = Attendance.fromJson(attendanceData));
                }
              } catch (e) {
                print('Error loading cached attendance data: $e');
              }
            }
          }
        }
      }

    } catch (e) {
      print('Error in load initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUserInfo() async {
    if (!mounted) return;
    
    try {
      final userInfo = await _apiService.getUserInfo();
      if (mounted) {
        setState(() => _user = User.fromJson(userInfo));
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _loadTodayAttendance() async {
    if (!mounted) return;
    
    try {
      final response = await _apiService.getTodayAttendance();
      if (response['success'] == true && response['data'] != null) {
        if (mounted) {
          setState(() => _todayAttendance = Attendance.fromJson(response['data']['attendance']));
        }
      }
    } catch (e) {
      print('Error loading attendance: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _apiService.clearToken();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 32,
              ),
              const SizedBox(width: 8),
              const Text('SMKN 1 PUNGGELAN'),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_time_outlined),
              selectedIcon: Icon(Icons.access_time),
              label: 'Absensi',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            if (_isOffline)
              Container(
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.orange.shade900,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mode Offline',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Menggunakan data tersimpan',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isRefreshing)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange.shade900,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _syncData,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.orange.shade50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'COBA LAGI',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (_isLoading && _user != null)
              LinearProgressIndicator(
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadInitialData,
                child: _isLoading && _user == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Memuat data...'),
                          ],
                        ),
                      )
                    : _buildPageContent(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageContent() {
    final List<Widget> pages = [
      _buildDashboardPage(),
      _buildAttendancePage(),
      _buildProfilePage(),
    ];

    return pages[_currentIndex];
  }

  Widget _buildDashboardPage() {
    final now = DateTime.now();
    final today = DateFormat('dd MMM yyyy').format(now);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Profile Section
        Row(
          children: [
            Hero(
              tag: 'profile-photo',
              child: CircleAvatar(
                radius: 25,
                backgroundImage: _user?.photo != null
                    ? NetworkImage(_user!.photo!)
                    : null,
                child: _user?.photo == null
                    ? const Icon(Icons.person, size: 25)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.name ?? 'Pengguna',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Product Manager',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Today's Date and Attendance Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Today • $today',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAttendanceTimeCard(
                      'CHECK IN',
                      _todayAttendance?.checkIn,
                      Icons.login_rounded,
                      onTap: _todayAttendance?.checkIn == null
                          ? () => Navigator.pushNamed(
                              context,
                              '/attendance',
                              arguments: {'type': 'check_in'},
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAttendanceTimeCard(
                      'CHECK OUT',
                      _todayAttendance?.checkOut,
                      Icons.logout_rounded,
                      onTap: _todayAttendance?.checkIn != null &&
                              _todayAttendance?.checkOut == null
                          ? () => Navigator.pushNamed(
                              context,
                              '/attendance',
                              arguments: {'type': 'check_out'},
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Actions Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildQuickActionButton(
              icon: Icons.access_time_rounded,
              label: 'Attendance',
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            _buildQuickActionButton(
              icon: Icons.event_note_rounded,
              label: 'Leave',
              onPressed: () => Navigator.pushNamed(context, '/leave'),
            ),
            _buildQuickActionButton(
              icon: Icons.task_rounded,
              label: 'Tasks',
              onPressed: () => Navigator.pushNamed(context, '/tasks'),
            ),
            _buildQuickActionButton(
              icon: Icons.more_horiz_rounded,
              label: 'More',
              onPressed: () => _showMoreOptions(),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Recent Activity Section
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                'Attendance Recorded',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '2 hours ago',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
              ),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTimeCard(String title, String? time, IconData icon, {VoidCallback? onTap}) {
    final bool hasTime = time != null;
    final formattedTime = hasTime ? DateFormat('HH:mm').format(DateTime.parse(time)) : '--:--';
    
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: hasTime ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasTime ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Schedule'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/schedule');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mosque),
            title: const Text('Prayer Times'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/prayer');
            },
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Internship'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/internship');
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('QR Code'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/qr-code');
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Locations'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/locations');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendancePage() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Absensi Hari Ini',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Divider(height: 32),
                    if (_todayAttendance != null) ...[
                      _buildAttendanceInfo('Masuk', _todayAttendance?.checkIn),
                      const SizedBox(height: 16),
                      _buildAttendanceInfo('Pulang', _todayAttendance?.checkOut),
                      const SizedBox(height: 16),
                      _buildAttendanceStatus(_todayAttendance?.status ?? 'Belum Absen'),
                    ] else
                      const Text('Belum ada catatan absensi hari ini'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _todayAttendance?.checkIn == null
                  ? () => Navigator.pushNamed(
                      context,
                      '/attendance',
                      arguments: {'type': 'check_in'},
                    )
                  : null,
              icon: const Icon(Icons.login),
              label: const Text('Absen Masuk'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                disabledBackgroundColor: Colors.grey.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _todayAttendance?.checkIn != null && 
                        _todayAttendance?.checkOut == null
                  ? () => Navigator.pushNamed(
                      context,
                      '/attendance',
                      arguments: {'type': 'check_out'},
                    )
                  : null,
              icon: const Icon(Icons.logout),
              label: const Text('Absen Pulang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                disabledBackgroundColor: Colors.grey.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              children: [
                Hero(
                  tag: 'profile-photo',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _user?.photo != null
                        ? NetworkImage(_user!.photo!)
                        : null,
                    child: _user?.photo == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _user?.name ?? 'Memuat...',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  _user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                if (_user?.role != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _user!.role,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileMenuItem(
                  icon: Icons.edit,
                  title: 'Edit Profil',
                  subtitle: 'Perbarui informasi profil Anda',
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                ),
                _buildProfileMenuItem(
                  icon: Icons.lock,
                  title: 'Ganti Password',
                  subtitle: 'Ubah password akun Anda',
                  onTap: () => Navigator.pushNamed(context, '/change-password'),
                ),
                _buildProfileMenuItem(
                  icon: Icons.history,
                  title: 'Riwayat Absensi',
                  subtitle: 'Lihat riwayat absensi Anda',
                  onTap: () => Navigator.pushNamed(context, '/attendance-history'),
                ),
                _buildProfileMenuItem(
                  icon: Icons.notifications,
                  title: 'Notifikasi',
                  subtitle: 'Atur pengingat absensi',
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
                const Divider(height: 32),
                _buildProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  subtitle: 'Keluar dari aplikasi',
                  onTap: _logout,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive 
      ? Theme.of(context).colorScheme.error
      : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: color != null 
            ? color.withOpacity(0.7)
            : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildAttendanceInfo(String label, String? time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          time != null ? DateFormat('HH:mm').format(DateTime.parse(time)) : 'Belum Absen',
          style: TextStyle(
            color: time != null ? Colors.green : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceStatus(String status) {
    Color statusColor;
    String displayStatus;
    
    switch (status.toLowerCase()) {
      case 'present':
        statusColor = Colors.green;
        displayStatus = 'Hadir';
        break;
      case 'late':
        statusColor = Colors.orange;
        displayStatus = 'Terlambat';
        break;
      case 'absent':
        statusColor = Colors.red;
        displayStatus = 'Tidak Hadir';
        break;
      default:
        statusColor = Colors.grey;
        displayStatus = 'Belum Absen';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Status'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            displayStatus,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
} 