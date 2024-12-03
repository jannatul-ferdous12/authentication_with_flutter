import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:trackeru/route/routes.dart';
import 'package:trackeru/utilities/Utils.dart';
import 'package:trackeru/utilities/emailValidator.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final emailController = TextEditingController();
  final _resetPasswordFormKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendPasswordResetEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final userCredential =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (userCredential.isNotEmpty) {
        // User exists in the Firebase database
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        // ignore: use_build_context_synchronously
        Utils.showSnackbar(context, "Password Reset Email Sent!", Colors.green);

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (_) => false,
        );
      } else {
        // ignore: use_build_context_synchronously
        Utils.showSnackbar(context, "Email not exist!", Colors.red);
      }
    } on FirebaseAuthException catch (e) {
      Utils.showSnackbar(context, e.toString(), Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Form(
                    key: _resetPasswordFormKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 0.75 * MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: emailController,
                            enableSuggestions: false,
                            autocorrect: false,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              hintText: 'Enter your email',
                            ),
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: sendPasswordResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(
                        0.75 * MediaQuery.of(context).size.width,
                        0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    },
                    child: const Text("Go Back"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
