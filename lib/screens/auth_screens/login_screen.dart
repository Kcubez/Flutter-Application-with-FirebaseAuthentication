import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/auth.dart';
// import '../../widgets/password_text_form_field.dart';
import '../task_screen/task_list.dart';
import './registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginInProgress = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'lib/images/galaxy-ray.png',
                  fit: BoxFit.contain,
                  height: 120,
                ),
                const SizedBox(height: 24),
                const Text(
                  'WELCOME',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'user@gmail.com',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                            child: Icon(
                              _isObscure ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter password.';
                          } else if (value!.length < 8) {
                            return 'Password must be at least 8 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _isLoginInProgress
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            loginUser(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black, // Background color
                          onPrimary: Colors.white, // Text color
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoginInProgress
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                            : const Text('Login'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (cntxt) =>
                                  const RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text('Create'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    setState(() {
      _isLoginInProgress = true;
    });

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        _isLoginInProgress = false;
      });

      log(userCredential.user.toString());

      if (userCredential.user?.emailVerified == false) {
        showToastMessage(
          'Please verify your account.',
          color: Colors.red,
          actionLabel: 'SEND',
          action: () async {
            await userCredential.user?.sendEmailVerification();
            showToastMessage(
              'Verification URL is sent to your email.',
              color: Colors.green,
            );
          },
        );
      } else if (userCredential.user?.emailVerified == true) {
        log('login success');
        final UserModel user = UserModel(
          userEmail: email,
          userId: userCredential.user!.uid,
        );
        await UserAuth().saveUserAuth(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Success'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (cntxt) => const TaskScreen()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code.contains('user-not-found') ||
          e.code.contains('wrong-password')) {
        showToastMessage(
          'E-mail or Password is incorrect!',
          color: Colors.red,
        );
      }
      else {
        showToastMessage('E-mail or Password is incorrect!', color: Colors.red);
      }
    } catch (e) {
      showToastMessage(e.toString(), color: Colors.red);
    }

    setState(() {
      _isLoginInProgress = false;
    });
  }

  void showToastMessage(
      String content, {
        Color color = Colors.green,
        VoidCallback? action,
        String? actionLabel,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(content),
        action: actionLabel == null
            ? null
            : SnackBarAction(
          onPressed: () {
            if (action != null) {
              action();
            }
          },
          label: actionLabel,
          textColor: Colors.white,
          backgroundColor: Colors.black38,
        ),
      ),
    );
  }
}