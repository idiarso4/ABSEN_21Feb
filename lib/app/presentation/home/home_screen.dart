import 'dart:math';
import 'package:absen_smkn1_punggelan/app/module/entity/attendance.dart';
import 'package:absen_smkn1_punggelan/app/presentation/detail_attendance/detail_attendance_screen.dart';
import 'package:absen_smkn1_punggelan/app/presentation/face_recognition/face_recognition_screen.dart';
import 'package:absen_smkn1_punggelan/app/presentation/home/home_notifier.dart';
import 'package:absen_smkn1_punggelan/app/presentation/login/login_screen.dart';
import 'package:absen_smkn1_punggelan/app/presentation/profile/profile_screen.dart';
import 'package:absen_smkn1_punggelan/core/constant/quotes.dart';
import 'package:absen_smkn1_punggelan/core/helper/date_time_helper.dart';
import 'package:absen_smkn1_punggelan/core/helper/dialog_helper.dart';
import 'package:absen_smkn1_punggelan/core/helper/global_helper.dart';
import 'package:absen_smkn1_punggelan/core/helper/shared_preferences_helper.dart';
import 'package:absen_smkn1_punggelan/core/widget/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:absen_smkn1_punggelan/app/module/entity/quote.dart';

class HomeScreen extends AppWidget<HomeNotifier> {
  final Color primaryOrange = Color.fromRGBO(243, 154, 0, 0.988);
  final Color secondaryOrange = Color.fromRGBO(255, 167, 38, 1);
  final Color bgLight = Colors.white;
  final Color textDark = Color.fromRGBO(33, 33, 33, 1);
  final Color textGrey = Colors.grey;

  QuoteModel getRandomQuote() {
    final random = Random();
    final quote = motivationalQuotes[random.nextInt(motivationalQuotes.length)];
    return QuoteModel(
      text: quote.text,
      author: quote.author,
    );
  }

  Widget _quoteWidget() {
    final quote = getRandomQuote();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryOrange.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${quote.text}"',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "- ${quote.author}",
            style: TextStyle(
              fontSize: 12,
              color: textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget bodyBuild(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => notifier.init(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _headerWithCalendar(context),
              _quoteWidget(),
              _todayAttendanceCard(context),
              _activitySection(context),
              _thisMonthLayout(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerWithCalendar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: bgLight,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _onPressProfile(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryOrange.withOpacity(0.1),
                      child: Icon(Icons.person, color: primaryOrange),
                    ),
                    SizedBox(width: 12),
                    Text(
                      notifier.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _onPressEditNotification(context),
                    icon: Icon(Icons.notifications_outlined),
                    color: primaryOrange,
                  ),
                  IconButton(
                    onPressed: () => _onPressLogout(context),
                    icon: Icon(Icons.logout),
                    color: primaryOrange,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          _weekCalendarView(context),
        ],
      ),
    );
  }

  Widget _weekCalendarView(BuildContext context) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      final date = now.subtract(Duration(days: now.weekday - 1 - index));
      return date;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((date) {
        final isToday = date.day == now.day;
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isToday ? primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                DateTimeHelper.formatDateTime(dateTime: date, format: 'E'),
                style: TextStyle(
                  color: isToday ? Colors.white : textGrey,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  color: isToday ? Colors.white : textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _todayAttendanceCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kehadiran Hari Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _attendanceTime(
                'Masuk',
                notifier.attendanceToday?.startTime ?? '-',
                Icons.login,
              ),
              SizedBox(width: 20),
              _attendanceTime(
                'Pulang',
                notifier.attendanceToday?.endTime ?? '-',
                Icons.logout,
              ),
            ],
          ),
          SizedBox(height: 16),
          if (!notifier.isLeaves)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onPressCreateAttendance(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Presensi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _attendanceTime(String label, String time, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryOrange, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activitySection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_city, color: primaryOrange, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lokasi Kantor',
                            style: TextStyle(
                              fontSize: 12,
                              color: textGrey,
                            ),
                          ),
                          Text(
                            notifier.schedule?.office.name ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, color: primaryOrange, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jadwal Absensi',
                            style: TextStyle(
                              fontSize: 12,
                              color: textGrey,
                            ),
                          ),
                          Text(
                            notifier.schedule?.shift.name ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistik Kehadiran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _onPressSeeAll(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: primaryOrange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _activityStat('28', 'Total Hari'),
              _activityStat('0', 'Terlambat'),
              _activityStat('0', 'Tidak Hadir'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityStat(String value, String label) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryOrange,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _thisMonthLayout(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryOrange,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Presensi Sebulan\nTerakhir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _onPressSeeAll(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Tgl',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Datang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Pulang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.2), height: 20),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: notifier.listAttendanceThisMonth.length,
            itemBuilder: (context, index) {
              final item = notifier.listAttendanceThisMonth[
                  notifier.listAttendanceThisMonth.length - index - 1];
              return _itemThisMonth(context, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _itemThisMonth(BuildContext context, AttendanceEntity item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              DateTimeHelper.formatDateTimeFromString(
                dateTimeString: item.date!,
                formar: 'dd\nMMM',
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.startTime,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.endTime,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onPressCreateAttendance(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceRecognitionScreen(),
        ));
    notifier.init();
  }

  _onPressEditNotification(BuildContext context) async {
    DialogHelper.showBottomDialog(
        context: context,
        title: "Edit waktu notifikasi",
        content: DropdownMenu<int>(
            initialSelection: notifier.timeNotification,
            onSelected: (value) => _onSaveEditNotification(context, value!),
            dropdownMenuEntries: notifier.listEditNotification));
  }

  _onPressLogout(BuildContext context) async {
    await SharedPreferencesHelper.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
      (route) => false,
    );
  }

  _onPressSeeAll(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailAttendanceScreen(),
        ));
  }

  _onSaveEditNotification(BuildContext context, int param) {
    Navigator.pop(context);
    notifier.saveNotificationSetting(param == 1);
  }

  _onPressProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(),
      ),
    );
  }
}
