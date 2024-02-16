import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:payment_tool/HomePageDesktop.dart';
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/SignUpPage.dart';
import 'package:payment_tool/contactForm.dart';
import 'package:payment_tool/main.dart';
import 'package:payment_tool/recoverPass.dart';
import 'package:payment_tool/spreadSheetTable.dart';
import 'package:url_launcher/url_launcher.dart';

// Asegúrate de importar los archivos y paquetes necesarios, como AssetsImages, LoginConstants, etc.

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool? _success = false;

  // Aquí debes definir los métodos _loginUser y _loginUserGoogle,
  // o asegurarte de que estén disponibles en el contexto de esta clase.

  @override
  Widget build(BuildContext context) {
    var screenSizeW = MediaQuery.of(context).size.width;
    var screenSizeH = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: screenSizeH / 10,
          width: screenSizeW / 10,
          decoration: BoxDecoration(
              image:
                  DecorationImage(image: AssetImage(AssetsImages.logoMatchQr))),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: screenSizeW / 2,
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
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        labelStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
                              MaterialStateProperty.all(AppColors.IconColor2),
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
                          }
                        },
                        child: Text(
                          LoginConstants.logInBox,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w400),
                        ), // Usa LoginConstants.logInBox si está disponible
                      ),
                    ),
                  ),
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return RecoverPassWidget(); // Show the SignUpPopUp dialog
                          },
                        );
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
        const SizedBox(
          height: 10,
        ),
        buildFooter()
      ],
    );
  }

  Widget buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                /* Navegar a la página de política de privacidad */
              },
              child: GestureDetector(
                child: const Text('Política de Privacidad'),
                onTap: () {
                  showPrivacyPopUp(context, 'Política de privacidad',
                      PrivacyConstants.privacyText);
                },
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                /* Navegar a la página de términos y condiciones */
                showLicensePage(context: context);
              },
              child: const Text('Términos y Condiciones'),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return const ContactForm();
                  },
                );
              },
              child: const Text('Contacto'),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // InkWell(
            //   onTap: (){
            //     launchUrl()
            //   },
            //   child: SizedBox(
            //       height: 35,
            //       width: 35,
            //       child: Image.asset(AssetsImages.linkedinlogo)),
            // ),
            // SizedBox(
            //   width: 10,
            // ),
            InkWell(
              onTap: () {
                launchUrl(Uri.parse(AppUrl.xUrl));
              },
              child: SizedBox(
                  height: 25,
                  width: 25,
                  child: Image.asset(AssetsImages.xlogo)),
            ),
          ],
        ),
        TextButton(
          child: Text(
            '© 2024 MatchQR',
            style: TextStyle(fontWeight: FontWeight.w200),
          ),
          onPressed: () {},
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

  void setFirebaseUser(dysplayName, uid, email, isEmailVer, photourl) async {
    await FirebaseFirestore.instance.collection('users').doc().set({
      'name': dysplayName,
      'uid': uid,
      'email': email,
      'isEmailVerified': isEmailVer, // will also be false
      'photoUrl': photourl, // will always be null
    });
  }

  Future<void> _loginUser(String email, String pass) async {
    try {
      // Intento de inicio de sesión con Firebase Auth
      final UserCredential firebaseGo =
          await authFirebase.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      User? user = firebaseGo.user;

      // Verificar si user no es null y si el correo electrónico ha sido verificado
      if (user != null) {
        if (user.emailVerified) {
          // Si el correo está verificado, proceder con la lógica de la aplicación
          FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'Usuario sin nombre',
            'uid': user.uid,
            'email': user.email,
            'isEmailVerified': user.emailVerified,
            'photoUrl': user.photoURL ?? 'URL de foto por defecto',
          });

          setState(() {
            _success = true;
            Navigator.pushNamed(context, AppRoutes.home, arguments: email);
          });
        } else {
          // Si el correo no está verificado, notificar al usuario y potencialmente cerrar la sesión
          await authFirebase
              .signOut(); // Cerrar la sesión si el correo no está verificado
          _showCupertinoDialog(
              context,
              "Por favor, verifica tu correo electrónico para continuar.",
              "Correo no verificado");

          setState(() {
            _success = false;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      _showCupertinoDialog(
          context, e.message ?? "Ocurrió un error desconocido.", e.code);

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
