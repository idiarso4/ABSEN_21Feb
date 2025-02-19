import 'package:absen_smkn1_punggelan/app/presentation/home/home_screen.dart';
import 'package:absen_smkn1_punggelan/app/presentation/login/login_notifier.dart';
import 'package:absen_smkn1_punggelan/core/helper/global_helper.dart';
import 'package:absen_smkn1_punggelan/core/widget/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class LoginScreen extends AppWidget<LoginNotifier, void, void> {
  @override
  void checkVariableAfterUi(BuildContext context) {
    if (notifier.isLoged) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    }
  }

  @override
  Widget bodyBuild(BuildContext context) {
    final Color primaryOrange = Color.fromRGBO(243, 154, 0, 0.988);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo_sekolah.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  'Selamat datang kembali 👋',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'di PRESENSI SKANSAPUNG',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                // Form fields
                TextField(
                  controller: notifier.emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: primaryOrange),
                    hintText: 'Email Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: notifier.passwordController,
                  obscureText: !notifier.isShowPassword,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: primaryOrange),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        notifier.isShowPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: primaryOrange,
                      ),
                      onPressed: _showHidePassword,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: primaryOrange,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onPressLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Or continue with social account',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/images/google_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  label: Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showHidePassword() {
    notifier.isShowPassword = !notifier.isShowPassword;
  }

  _onPressLogin(BuildContext context) {
    notifier.login();
  }
}
