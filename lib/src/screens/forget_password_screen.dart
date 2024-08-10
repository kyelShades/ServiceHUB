import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _controllerEmail = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  Future<void> sendPasswordResetEmail() async {
    if (_controllerEmail.text.isEmpty) {
      setState(() {
        errorMessage = 'Email is required';
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _controllerEmail.text);
      setState(() {
        isLoading = false;
        errorMessage = 'Password reset link has been sent to your email.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email.';
        } else {
          errorMessage = 'Failed to send reset email. Please try again later.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),

                // Add the image above the title
                Image.asset(
                  'assets/sh_icon.png',  // Path to your image asset
                  height: 100.0,          // Set the height as needed
                ),
                SizedBox(height: 20.0),   // Space between the image and the title
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email to receive a password reset link',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 15),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: TextStyle(color: errorMessage!.contains('Password reset link') ? Colors.green : Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controllerEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.black12), // Normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  cursorColor: Colors.blue,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendPasswordResetEmail,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // foreground (text) color
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Change the border radius here
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text('Send Reset Link'),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back to Login'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    textStyle: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
