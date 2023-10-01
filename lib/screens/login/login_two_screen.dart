import 'package:flutter/material.dart';
import 'package:insurify/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';

import 'package:insurify/providers/theme_provider.dart';
import 'package:insurify/screens/components/startup_screen_heading.dart';
import 'package:insurify/screens/components/build_bottom_buttons.dart';
import 'package:insurify/screens/login/login_one_screen.dart';

class LoginTwoScreen extends StatefulWidget {
  const LoginTwoScreen({Key? key}) : super(key: key);

  @override
  LoginTwoScreenState createState() => LoginTwoScreenState();
}

class LoginTwoScreenState extends State<LoginTwoScreen> {
  late ThemeProvider themeProvider;
  String otp = '';
  TextEditingController otpController = TextEditingController();
  final int digitCount = 4;

  void updateOtpValue() {
    otp = otpController.text;
    if (otp.length == digitCount) {
      submitOtp(context, otp);
    } else {}
  }

  List<dynamic> jsonData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void submitOtp(BuildContext context, String otp) {
    if (otp == '1111') {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: Container(
                color: Colors.transparent,
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: themeProvider.themeColors["primary"],
          content: Text(
            'Wrong OTP, please try again',
            style: TextStyle(
              color: themeProvider.themeColors["white"],
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
          action: SnackBarAction(
            backgroundColor: themeProvider.themeColors["buttonOne"],
            label: 'OK',
            textColor: themeProvider.themeColors["white"],
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);

    final defaultPinTheme = PinTheme(
      width: 55,
      height: 55,
      margin: const EdgeInsets.only(top: 30),
      textStyle: TextStyle(
          fontSize: 20,
          color: themeProvider.themeColors["white"],
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: themeProvider.themeColors["buttonOne"],
        borderRadius: BorderRadius.circular(10),
      ),
    );
    final double height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    // width variable of screen
    final double width =
        MediaQuery.of(context).size.width - MediaQuery.of(context).padding.left;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: Image.asset(
                  themeProvider.themeIconPaths["smallLogo"]!,
                  height: 38,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 31, right: 31),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.125),
                      buildStartUpScreenHeading(context, 'Login'),
                      SizedBox(height: height * 0.075),
                      Text(
                        "Verify your phone number",
                        style: TextStyle(
                          color: themeProvider.themeColors["white"],
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      Pinput(
                        length: digitCount,
                        defaultPinTheme: defaultPinTheme,
                        controller: otpController,
                        onChanged: (value) {
                          updateOtpValue();
                        },
                      ),
                      SizedBox(height: height * 0.05),
                      Text(
                        "Didn't receive an OTP?",
                        style: TextStyle(
                          color: themeProvider.themeColors["white"],
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: height * 0.025),
                      Text(
                        "RESEND OTP",
                        style: TextStyle(
                          color: themeProvider.themeColors["white"],
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: 'Inter',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 31,
                left: 31,
                right: 31,
                child: buildBackAndNextButtons(
                  context,
                  width,
                  const LoginOneScreen(),
                  const Placeholder(),
                  () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
