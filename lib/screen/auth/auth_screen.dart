import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:totoki/firebase_options.dart';
import 'package:totoki/screen/deckwelcome.dart';
import 'package:totoki/screen/mainscreen.dart/mainnavigation.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String? _messageErr;
  bool _isLoading = false;

  Color teal = Colors.teal;
  Color color2 = Color(0x00407076);

  Future<void> SumbitAuthForm() async {
    setState(() {
      _isLoading = true;
      _messageErr = null;
    });
    try {
      if (_isLogin) {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
      );
        } on FirebaseAuthException catch (error) {
      setState(() {
        _messageErr = error.message;
      });
    } catch (e) {
      setState(() {
        _messageErr = "have a err $e";
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: teal,
        title: Title(
          color: const Color.fromARGB(255, 118, 155, 155),
          child: Text(_isLogin ? "Login" : "Sign Up"),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(label: Text("Email")),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(label: Text("Password")),
            ),
            SizedBox(height: 20),
            Text(
              _messageErr != null ? "There are error in authentic process" : "",
              style: TextStyle(fontSize: 20.0, color: teal),
            ),
            _isLoading
                ? CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainNavigation(),
                            ),
                          );
                        },
                        child: Text("Guest"),
                      ),
                      ElevatedButton(
                        onPressed: SumbitAuthForm,
                        style: ElevatedButton.styleFrom(backgroundColor: teal),
                        child: Text(
                          _isLogin ? "Login" : "Sign Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                _isLogin
                    ? "First time here? Sign Up"
                    : "Already have a account? Log in",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
