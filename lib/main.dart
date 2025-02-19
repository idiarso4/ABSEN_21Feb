import 'package:absen_smkn1_punggelan/app/presentation/login/login_screen.dart';
import 'package:absen_smkn1_punggelan/core/di/dependency.dart';
import 'package:absen_smkn1_punggelan/core/widget/error_app_widget.dart';
import 'package:absen_smkn1_punggelan/core/widget/loading_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:absen_smkn1_punggelan/core/helper/notification_helper.dart';
import 'package:provider/provider.dart';
import 'package:absen_smkn1_punggelan/app/presentation/profile/profile_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  await initDependency();
  await NotificationHelper.initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileNotifier()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
        home: Scaffold(
          body: LoginScreen(),
        ),
      ),
    );
  }
}
