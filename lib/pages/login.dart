import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'firebase.dart';
import 'user_session.dart';

void main() async {
  runApp(const LoginScreen());
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'g0tchaApp',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GotchaRider Login Page'),
        ),
        body: const LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserSession _userSession = UserSession();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final String phoneNumber = _phoneNumberController.text;
      final String password = _passwordController.text;
      // Validate inputs
      if (phoneNumber.length != 11 || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid inputs. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final DocumentSnapshot? userDocument =
          await FirebaseService.instance.validateUser(phoneNumber, password);
      print(userDocument);
      if (userDocument != null && userDocument.exists) {
        Map<String, dynamic>? userData =
            userDocument.data() as Map<String, dynamic>?;
        if (userData != null) {
          await _userSession.signInSession(phoneNumber, userData);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User/Password did not match. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                Uri.encodeFull("https://i.ibb.co/PDMxtXX/gotcha2024.jpg"),
                scale: 5.0,
              ),
              radius: 120,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 11,
              textInputAction:
                  TextInputAction.next, // allows keyboard to go to next field
              decoration: const InputDecoration(
                labelText: 'Cellphone Number',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _loginUser();
                if (_isLoading) {
                  await _userSession.checkSession().then((isLoggedIn) {
                    setState(() {});
                    if (isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomeScreen(
                              currentUserSessionData:
                                  _userSession.currentUserSessionData),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Failed Logged in for - ${_phoneNumberController.text}.')),
                      );
                    }
                  });
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
