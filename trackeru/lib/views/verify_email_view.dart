import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trackeru/route/routes.dart';
import 'package:trackeru/utilities/Utils.dart';
import 'dart:async';

import 'package:trackeru/views/homepage_view.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  Timer? _timer;
  int _countdown = 60; // Initial countdown time in seconds
  late String _timestamp;
  bool _isEmailSent = false;
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!_isEmailVerified) {
      sendEmailVerification();

      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the view is disposed
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (_isEmailVerified) {
      _timer?.cancel();
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
          _timestamp = formatTime(_countdown);
        } else {
          _timer?.cancel();
          _timestamp = 'Resend email';
        }
      });
    });
    _timestamp = formatTime(_countdown);
  }

  String formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      setState(() {
        _isEmailSent = true;

        Utils.showSnackbar(
          context,
          "Verification Email Sent! Please, check your email and verify",
          Colors.green,
        );
        _countdown = 60;
        startTimer();
      });
    } catch (e) {
      Utils.showSnackbar(context, e.toString(), Colors.red);
    }
  }

  Future<void> resendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.sendEmailVerification();
    // ignore: use_build_context_synchronously
    Utils.showSnackbar(
      context,
      "Verification Email Resent! Please, check your email and verify",
      Colors.green,
    );
    _countdown = 60;
    startTimer();
  }

  @override
  Widget build(BuildContext context) => _isEmailVerified
      ? const HomePage()
      : Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Please, verify your email first!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isEmailSent)
                  GestureDetector(
                    onTap: sendEmailVerification,
                    child: Text(
                      "Verify Email",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: _countdown > 0 ? null : resendEmailVerification,
                    child: Text(
                      _timestamp,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                // const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoute,
                      (_) => false,
                    );
                  },
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        );
}


// GestureDetector(
//                     child: Text(
//                       "Forgot Password?",
//                       style: TextStyle(
//                         decoration: TextDecoration.underline,
//                         color: Theme.of(context).colorScheme.secondary,
//                       ),
//                     ),
//                     onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
//                       forgotPasswordRoute,
//                       (route) => false,
//                     ),
//                   ),