import 'package:flutter/material.dart';
import 'package:trackeru/components/locationMainsreen.dart';
import 'package:trackeru/route/routes.dart';
import 'package:trackeru/views/Register_view.dart';
import 'package:trackeru/views/forgotPassword.dart';
import 'package:trackeru/views/homepage_view.dart';
import 'package:trackeru/views/login_view.dart';
import 'package:trackeru/views/setting_view.dart';
import 'package:trackeru/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'TrackerU',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 9, 52, 131),
      ),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      verifyRoute: (context) => const VerifyEmailView(),
      mainRoute: (context) => const MainScreen(),
      forgotPasswordRoute: (context) => const ForgotPasswordView(),
      SettingsScreen: (context) => const SettingView(),
    },
  ));
}
