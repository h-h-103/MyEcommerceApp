import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myecommerceapp/presentation/widget/custombuttonauth.dart';
import 'package:myecommerceapp/presentation/widget/customlogoauth.dart';
import 'package:myecommerceapp/presentation/widget/textformfield.dart';
import 'package:myecommerceapp/providers/auth_providers.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = await ref
          .read(authNotifierProvider.notifier)
          .loginWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'email-not-verified':
          errorMessage = 'Please verify your email before logging in.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      _showErrorDialog("Login Error", errorMessage);
    } catch (e) {
      _showErrorDialog(
        "Error",
        "An unexpected error occurred: ${e.toString()}",
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final user = await ref
          .read(authNotifierProvider.notifier)
          .loginWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      _showErrorDialog(
        "Google Sign-In Error",
        "Failed to sign in with Google: ${e.toString()}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 50),
                    const CustomLogoAuth(),
                    const SizedBox(height: 20),
                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    CustomTextForm(
                      hinttext: "Enter Your Email",
                      mycontroller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextForm(
                      hinttext: "Enter Your Password",
                      mycontroller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/forgot-password");
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButtonAuth(
                      title: "Login",
                      onPressed: _loginWithEmail,
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      onPressed: _loginWithGoogle,
                      color: Colors.red,
                      textColor: Colors.white,
                      child: const Text("Continue with Google"),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/register");
                      },
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Don't have an account? ",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
