import 'dart:html';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:payment_tool/HomePageDesktop.dart';
import 'package:payment_tool/SuccessPaymentPage.dart';
import 'package:payment_tool/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:payment_tool/cuadraditosLanding.dart';
import 'package:payment_tool/initialLanding.dart';
import 'firebase_options.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:chat_gpt_api/chat_gpt.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: ApiKeys.GoogleAuthSignIn,
);
GoogleAuthProvider authProviderGoogle = GoogleAuthProvider();
FirebaseAuth authFirebase = FirebaseAuth.instance;

final chatGpt = ChatGPT.builder(
  token: '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',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const useHashUrlStrategy =
      bool.fromEnvironment('ENABLE_HASH_URL_STRATEGY', defaultValue: false);
  if (!useHashUrlStrategy) {
    setUrlStrategy(const HashUrlStrategy());
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isDesktop;
  @override
  void initState() {
    super.initState();

    if (window.screen!.width! < 768) {
      isDesktop = false;
      // Add your mobile-specific code here
    } else {
      isDesktop = true;
      // Add your desktop-specific code here
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.IconColor, // Set the primary color to blue
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Color de fondo de la AppBar
          elevation: 0, // Sin sombra en la AppBar
          iconTheme: IconThemeData(
              color: Colors.black), // Color de los iconos en la AppBar
          titleTextStyle: TextStyle(
              color: Colors.black), // Estilo del texto del título en la AppBar
        ),

        fontFamily: 'Roboto', // Use Google's Roboto font
      ),
      //initialRoute: AppRoutes.landing,
      //home: const LandingPageInit(), //const LandingPage(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case AppRoutes.home:
            final String email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => MyHomePageDesktop(email: email),
            );
          case AppRoutes.signIn:
            return MaterialPageRoute(
              builder: (context) => const CuadraditosLanding(),
            );
          case AppRoutes.landing:
            return MaterialPageRoute(
                builder: (context) =>
                    const CuadraditosLanding() //LandingPageInit(),
                );
          case AppRoutes.successPayment:
            return MaterialPageRoute(
              builder: (context) => const SuccessPaymentPage(),
            );
          case AppRoutes.failedPayment:
            return MaterialPageRoute(
              builder: (context) => const FailedPaymentPage(),
            );
          default:
            // Aquí puedes manejar rutas desconocidas o mostrar una página de error
            return MaterialPageRoute(
              builder: (context) => const CuadraditosLanding(),
            );
        }
      },
    );
  }
}

class UnknownRoutePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página No Encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '404',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lo sentimos, la página que buscas no existe.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
