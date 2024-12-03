import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trackeru/constants/errorMessages.dart';

import 'package:trackeru/route/routes.dart';
import 'package:trackeru/utilities/showErrorDialogue.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final _loginformKey = GlobalKey<FormState>();

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String errorMessage = '';
  bool isLoading = false;
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          key: _loginformKey,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24, 
                fontWeight:
                    FontWeight.bold, 
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Form(
                    key: _loginformKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 0.75 * MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: _email,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Enter your email here",
                              filled:
                                  true, 
                              fillColor:
                                  Colors.grey[200], 
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(
                                    10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 0.75 * MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: _password,
                            obscureText: !_isPasswordVisible,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter your password here",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      forgotPasswordRoute,
                      (route) => false,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      if (_loginformKey.currentState!.validate()) {
                        final email = _email.text;
                        final password = _password.text;
                        setState(() => isLoading = true);

                        try {
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          final user = FirebaseAuth.instance.currentUser;

                          if (user?.emailVerified ?? false) {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              mainRoute,
                              (route) => false,
                            );
                          } else {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              verifyRoute,
                              (route) => false,
                            );
                          }
                        } on FirebaseAuthException catch (error) {
                          if (error.message == invalidEmailErr) {
                            await showErrorDialogue(context, "Invalid Email");
                          } else if (error.message == userNotFoundErr) {
                            await showErrorDialogue(context, "User Not Found!");
                          } else if (error.message == wrongPasswordErr) {
                            await showErrorDialogue(context, "Wrong Password!");
                          } else {
                            await showErrorDialogue(context, "Unknown Error!");
                          }
                        }

                        setState(() => isLoading = false);
                      }
                    },
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
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute,
                        (route) => false,
                      );
                    },
                    child: const Text("Not registerred yet? Register here!"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
