import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:servicehub/auth.dart';
import 'package:servicehub/src/screens/signup_screen.dart';
import 'package:servicehub/src/screens/vendorScreens/vendor_login.dart';

import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? errorMessage;
  bool keepSignedIn = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      // Navigate to the home screen on successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.code == 'user-not-found'
            ? 'Account does not exist. Please sign up.'
            : e.message;
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
                SizedBox(height: 80),
                Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter your email and password to Log in',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 15),
                if (errorMessage != null)
                  Text(
                    'Enter correct email and password',
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 10),
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
                SizedBox(height: 16),
                TextField(
                  controller: _controllerPassword,
                  decoration: InputDecoration(
                    labelText: 'password',
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
                SizedBox(height: 5),
                Row(
                  children: [
                    Checkbox(
                      value: keepSignedIn,
                      onChanged: (bool? value) {
                        setState(() {
                          keepSignedIn = value ?? false;
                        });
                      },
                    ),
                    Text('Keep me signed in', style: TextStyle(fontWeight: FontWeight.normal)),


                  ],
                ),
                SizedBox(height: 24),

                SizedBox(height: 1),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: signInWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // foreground (text) color
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Change the border radius here
                      ),
                    ),
                    child: Text('Login'),

                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: Text('Forgot Password'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    textStyle: TextStyle(fontWeight: FontWeight.normal)

                  ),
                ),
                SizedBox(height: 8),
                Divider(color: Colors.black12,),
                SizedBox(height: 10),
                Text('Don\'t have an account?', style: TextStyle(fontWeight: FontWeight.normal),),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: Text('Create an account'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                      textStyle: TextStyle(fontWeight: FontWeight.normal)

                  ),
                ),
                SizedBox(height: 8),
                TextButton(

                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => VendorLoginScreen()),
                    );
                  },
                  child: Text('Log in to vendor account'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                      textStyle: TextStyle(fontWeight: FontWeight.normal)

                  ),
                ),
                Text(
                  'By clicking continue, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
