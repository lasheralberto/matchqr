import 'package:flutter_html/flutter_html.dart';
import 'package:payment_tool/HomePageDesktop.dart';
import 'package:payment_tool/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:payment_tool/spreadSheetTable.dart';

class SignUpPopUp extends StatefulWidget {
  const SignUpPopUp({super.key});

  @override
  State<SignUpPopUp> createState() => _SignUpPopUpState();
}

class _SignUpPopUpState extends State<SignUpPopUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  var _password = '';
  var _confirmPassword = '';

  bool? _success;
  String? _userEmail;

  _registerUser(email, pass) async {
    if (_password != _confirmPassword) {
      _showCupertinoDialog(
          context, LoginConstants.passDoNotMatch, LoginConstants.passError);
    }

    try {
      final User? user =
          (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      ))
              .user;

      await user!.sendEmailVerification();

      FirebaseFirestore.instance.collection('users').doc().set({
        'name': user!.displayName,
        'uid': user.uid,
        'email': user.email,
        'isEmailVerified': user.emailVerified, // will also be false
        'photoUrl': user.photoURL, // will always be null
      });

      setState(() {
        _success = true;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return MyHomePageDesktop(email: user.email.toString());
          },
        ));
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _success = false;
      });
      _showCupertinoDialog(context, e.code, e.message.toString());
    } catch (e) {
      _showCupertinoDialog(context, e, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: StyleConstants.border,
      ),
      elevation: 20,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    bool _acceptPrivacyPolicy = false;

    void _tryRegister() {
      if (_formKey.currentState!.validate()) {
        if (!_acceptPrivacyPolicy) {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(16),
                height: 150, // Adjust as needed
                child: Center(
                  child: Text(
                    'Tienes que aceptar la política de privacidad.',
                    style: TextStyle(fontSize: 16), // Adjust styling as needed
                  ),
                ),
              );
            },
          );
        } else {
          _registerUser(_emailController.text, _passwordController.text);
        }
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width / 4,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.IconColor2,
        borderRadius: StyleConstants.border,
      ),
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LoginConstants.registerMe,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          InputDecoration(labelText: LoginConstants.emailBox),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return LoginConstants.enterSomeText;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: LoginConstants.passwordBox),
                      onChanged: (val) {
                        setState(() {
                          _password = val;
                        });
                      },
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return LoginConstants.enterSomeText;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: _passwordConfirmController,
                      decoration: InputDecoration(
                          labelText: LoginConstants.confirmPass),
                      onChanged: (val) {
                        _confirmPassword = val;
                      },
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return LoginConstants.enterSomeText;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return CheckboxListTile(
                          value:
                              _acceptPrivacyPolicy, // You need to define this bool variable in your state
                          onChanged: (bool? value) {
                            setState(() {
                              _acceptPrivacyPolicy = value!;
                            });
                          },
                          title: RichText(
                            text: TextSpan(
                              text: 'Aceptar ',
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Política de privacidad',
                                  style: TextStyle(
                                    decoration: TextDecoration
                                        .underline, // Underline the text
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Call your function to show the privacy policy
                                      showPrivacyPopUp(
                                          context,
                                          'Política de privacidad',
                                          PrivacyConstants.privacyText);
                                    },
                                ),
                              ],
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity
                              .leading, // Position the checkbox at the start of the tile
                        );
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 20.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: StyleConstants.border),
                          backgroundColor:
                              AppColors.IconColor, // Transparent background
                          padding:
                              const EdgeInsets.all(16.0), // Adjust button size
                        ),
                        onPressed: () async {
                          _tryRegister();
                        },
                        child: Text(
                          LoginConstants.registerMe,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_success == null
                        ? ''
                        : (_success == true
                            ? LoginConstants.registerSuccess
                            : LoginConstants.registerFail)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCupertinoDialog(context, title, content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(LoginConstants.close),
            ),
          ],
        );
      },
    );
  }
}

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onTap;
  String buttonText;
  Widget iconSymbol;

  GoogleSignInButton(
      {super.key,
      required this.onTap,
      required this.buttonText,
      required this.iconSymbol});
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _isSigningIn
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(10.0),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: StyleConstants.border,
                    ),
                  ),
                ),
                onPressed: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      widget.iconSymbol,
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          widget.buttonText,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
