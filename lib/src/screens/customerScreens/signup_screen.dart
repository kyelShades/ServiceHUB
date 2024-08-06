import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicehub/src/screens/customerScreens/home_screen.dart';
import 'package:servicehub/src/screens/customerScreens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  String? errorMessage;
  bool _agreedToTOS = false;

  Future<void> registerUser() async {
    // ----Error handling----
    if (_controllerUsername.text.isEmpty) {
      setState(() {
        errorMessage = 'Username is required';
      });
      return;
    }

    if (_controllerEmail.text.isEmpty) {
      setState(() {
        errorMessage = 'Email is required';
      });
      return;
    }

    if (_controllerPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Password is required';
      });
      return;
    }

    if (_controllerConfirmPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Confirm password is required';
      });
      return;
    }

    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (!_agreedToTOS) {
      setState(() {
        errorMessage = 'You must agree to the terms and conditions';
      });
      return;
    }
  //---------------ends--------------------


    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      User? user = userCredential.user;

      // Store additional user information in Firestore
      await FirebaseFirestore.instance.collection('customers').doc(user?.uid).set({
        'username': _controllerUsername.text,
        'email': _controllerEmail.text,
      });

      // Navigate to HomeScreen upon successful registration
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 50.0),
              const Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30.0),

              //------this displays the error message------------//
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              //-------------end-------------------------------//

              // -----Form Start-----------------//
              SizedBox(height: 10.0),
              TextField(
                controller: _controllerUsername,
                decoration: InputDecoration(
                  labelText: 'Username',
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
              SizedBox(height: 12.0),
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
              SizedBox(height: 12.0),
              TextField(
                controller: _controllerPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                obscureText: true,
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _controllerConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
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
                obscureText: true,
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Checkbox(
                    activeColor: Colors.blue,
                    value: _agreedToTOS,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreedToTOS = value ?? false;
                      });
                    },
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreedToTOS = !_agreedToTOS;
                        });
                      },
                      child: Text(
                        'Agree to terms and conditions',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: registerUser,
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Button color
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),

              // ------- form end --------------//


              SizedBox(height: 12.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14.0,
                  ),
                ),
              ),
              SizedBox(height: 50.0),

            ],
          ),
        ),
      ),
    );
  }
}
