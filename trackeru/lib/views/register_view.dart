import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trackeru/constants/errorMessages.dart';
import 'package:trackeru/route/routes.dart';
import 'package:trackeru/utilities/emailValidator.dart';
import 'package:trackeru/utilities/passwordValidator.dart';
import 'package:trackeru/utilities/showErrorDialogue.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final _registerformKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String errorMessage = '';
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          key: _registerformKey,
          children: [
            const Text(
              'SignUp',
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
                    key: _registerformKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 0.75 * MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: _email,
                            validator: validateEmail,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Enter your email here",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide.none, // Remove the border
                                borderRadius: BorderRadius.circular(
                                    10), // Set border radius
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, // Adjust the vertical padding
                                horizontal: 16, // Adjust the horizontal padding
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 0.75 * MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: _password,
                            validator: validatePassword,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 0.75 * MediaQuery.of(context).size.width,
                    child: TextFormField(
                      validator: confirmValidatePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: !_isConfirmPasswordVisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: "Confirm your password",
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
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      if (_registerformKey.currentState!.validate()) {
                        final email = _email.text;
                        final password = _password.text;
                        setState(() => isLoading = true);

                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            verifyRoute,
                            (route) => false,
                          );
                        } on FirebaseAuthException catch (error) {
                          if (error.message == userExistedErr) {
                            await showErrorDialogue(
                                context, 'Email is already registered.');
                          } else {
                            showErrorDialogue(context, error.code);
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
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (route) => false,
                      );
                    },
                    child: const Text("Already registerred? Login here!"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? confirmValidatePassword(String? value) {
    if (value != null && value.isEmpty) {
      return 'Confirm password is required, please enter';
    }
    if (value != _password.text) {
      return 'Confirm password does not match';
    }
    return null;
  }
}
