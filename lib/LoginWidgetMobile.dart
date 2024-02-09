import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:payment_tool/HomePageDesktop.dart';
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/SignUpPage.dart';
import 'package:payment_tool/cuadraditosLanding.dart';
import 'package:payment_tool/main.dart';
import 'package:payment_tool/functions.dart';
import 'dart:math';
// Asegúrate de importar los archivos y paquetes necesarios, como AssetsImages, LoginConstants, etc.

class LoginWidgetMobile extends StatefulWidget {
  @override
  _LoginWidgetMobileState createState() => _LoginWidgetMobileState();
}

class _LoginWidgetMobileState extends State<LoginWidgetMobile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool? _success;
  late Size screenSize;
  late List<Cuadraditos> _cuadraditosList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // Aquí debes definir los métodos _loginUser y _loginUserGoogle,
  // o asegurarte de que estén disponibles en el contexto de esta clase.

  @override
  Widget build(BuildContext context) {
    var screenSizeW = MediaQuery.of(context).size.width;
    var screenSizeH = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: Container(
            height: screenSizeH / 4,
            width: screenSizeW / 4,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(AssetsImages.logoMatchQr))),
          ),
        ),
        SizedBox(
          width: screenSizeW / 1.2,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(38.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelStyle: const TextStyle(color: Colors.white),
                        labelText: LoginConstants
                            .emailBox), // Usa LoginConstants.emailBox si está disponible
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text'; // Usa LoginConstants.enterSomeText si está disponible
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelStyle: const TextStyle(color: Colors.white),
                        labelText: LoginConstants
                            .passwordBox), // Usa LoginConstants.passwordBox si está disponible
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text'; // Usa LoginConstants.enterSomeText si está disponible
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      height: 40,
                      width: 250,
                      child: OutlinedButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(10.0),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: StyleConstants.border,
                            ),
                          ),
                        ),

                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Lógica de inicio de sesión
                            await _loginUser(_emailController.text,
                                _passwordController.text);

                            ///_emailController.text,
                            //_passwordController.text)
                          }
                        },
                        child: Text(LoginConstants
                            .logInBox), // Usa LoginConstants.logInBox si está disponible
                      ),
                    ),
                  ),
                  // ... Aquí irían otros widgets de recuperación de contraseña, signup,etc ...

                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: GoogleSignInButton(
                        iconSymbol: Image(
                          image: AssetImage(AssetsImages.GoogleSignInLogo),
                          height: 25.0,
                        ),
                        buttonText: LoginConstants.loginGoogleBox,
                        onTap: () async {
                          await _loginUserGoogle();
                        },
                      ),
                    ),
                  ),
                  // Button to access the app
                  Center(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const SignUpPopUp(); // Show the SignUpPopUp dialog
                          },
                        );
                      },
                      child: Text(
                        LoginConstants.registerMe,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w200,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        recoverPass(context);
                      },
                      child: Text(
                        LoginConstants.recoverPassBox,
                        style: const TextStyle(
                            fontWeight: FontWeight.w200, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Aquí puedes definir los métodos _loginUser y _loginUserGoogle, o cualquier otra lógica necesaria.
  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hecho!'),
          content: const Text('Email enviado.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the success message popup
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void recoverPass(BuildContext context) {
    String email = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LoginConstants.emailBox),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(labelText: LoginConstants.emailBox),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 20.0,
                  backgroundColor: Colors.blueAccent, // Transparent background
                  padding: const EdgeInsets.all(16.0), // Adjust button size
                ),
                onPressed: () {
                  // Process the email or perform any action here

                  authFirebase
                      .sendPasswordResetEmail(email: email)
                      .then((value) {
                    showSuccessDialog(context);
                  });
                  Navigator.of(context).pop(); // Close the popup
                },
                child: Text(
                  LoginConstants.send,
                  style: TextStyle(color: ColorConstants.colorButtons),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void setFirebaseUser(dysplayName, uid, email, isEmailVer, photourl) async {
    await FirebaseFirestore.instance.collection('users').doc().set({
      'name': dysplayName,
      'uid': uid,
      'email': email,
      'isEmailVerified': isEmailVer, // will also be false
      'photoUrl': photourl, // will always be null
    });
  }

  _loginUser(email, pass) async {
    try {
      final firebaseGo = (await authFirebase.signInWithEmailAndPassword(
        email: email,
        password: pass,
      ));
      var user = firebaseGo.user;

      FirebaseFirestore.instance.collection('users').doc().set({
        'name': user!.displayName,
        'uid': user.uid,
        'email': user.email,
        'isEmailVerified': user.emailVerified, // will also be false
        'photoUrl': user.photoURL, // will always be null
      });

      setState(() {
        _success = true;
        Navigator.pushNamed(context, AppRoutes.home, arguments: email);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => MyHomePageDesktop(email: email)),
        // );
      });
    } on FirebaseAuthException catch (e) {
      _showCupertinoDialog(context, e.message, e.code);

      setState(() {
        _success = false;
      });
    }
  }

  _loginUserGoogle() async {
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await authFirebase.signInWithPopup(authProvider);

        user = userCredential.user;
        Navigator.pushReplacementNamed(context, AppRoutes.home,
            arguments: user!.email as String);
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await authFirebase.signInWithCredential(credential);

          user = userCredential.user;

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePageDesktop(
                      email: user?.email as String,
                    )),
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // ...
          } else if (e.code == 'invalid-credential') {
            // ...
          } else if (e.code == 'firebase_auth/popup-closed-by-user') {
            _showCupertinoDialog(context, e.message, e.code);
          }
        } catch (e) {
          // ...
        }
      }
    }
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
