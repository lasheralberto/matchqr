import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppRoutes {
  static const String home = '/home';
  static const String signUp = '/signUp';
  static const String signIn = '/signIn';
  static const String landing = '/landing';
  static const String successPayment = '/successPayment';
  static const String failedPayment = '/paymentFailed';
}

class AppColors {
  static const Color tileColor = Colors.white70;
  static const Color backgroundCard = Colors.white;
  static const Color buttonColor = Colors.white70;
  static const Color IconColor = Color.fromARGB(220, 75, 111, 230);
  static const Color IconColor2 = Color.fromARGB(220, 177, 240, 62);
}

class ColorConstants {
  static Color colortheme = Colors.white;
  static Color colorAppBar = Colors.white;
  static Color colorCard = Colors.white;
  static Color colorHeaders = Colors.white;
  static Color colorTexts = Colors.white;
  static Color colorButtons = Colors.white;
}

class AssetsImages {
  static String noDataQrBackground = '/images/ops.png';
  static String noDataQrAdmin = '/images/bored.png';
  static String tennisLogoBall =
      'images/landing_images/matchqrLogo.png'; //'images/tenis2.png';
  static String AppBarInkWizLogo = '/images/s2.png';
  static String GoogleSignInLogo = "/images/g_logo.png";
  static String BookGifLandingPage =
      'https://media.giphy.com/media/u00DkhlFRgkei3d3jG/giphy.gif';
  static String LandingPageBackgroundAsset = '/images/qr.png';
  static String LandingPageBackgroundWallpaper = '/images/qr_wallpap.png';
  static String logoMatchQr = 'images/landing_images/matchqrLogo.png';
  static String stripeLogo = 'images/stripe_pay.png';
  static String linkedinlogo = 'images/landing_images/linkedinlogo.png';
  static String xlogo = 'images/landing_images/xlogo.png';
}

class ApiKeys {
  static String GoogleAuthSignIn =
      '824902523000-220rkjn19j20un2f1ss2r389u9so6m8j.apps.googleusercontent.com';
}

class StyleConstants {
  static BorderRadius border = BorderRadius.circular(10.0);
  static int mobileSize = 1372;
  static double elevation = 20.0;
  static Size logoQrSize = Size(45, 45);
}

class PayConstants {
  static String publishable_key = 'pk_live_36swzHfwDCLVNpFHwkPODUK9';
  static String pub_key_test = 'pk_test_a5UTLjkFh4BO6GZlTakE4EpN';
  static String private_key =
      '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';
  static String price_id = 'price_1NyJ3KFS1UGHVPAZL8GjuTO0';
}

class AppUrl {
  static String localhost = 'http://localhost:59815';
  //static String AzureBaseUrl = 'https://doogiapp.azurewebsites.net/';
  static String AzureBaseUrl = 'https://gcloudmatchqr-bbwapl73qa-nw.a.run.app/';
  static String xUrl = 'https://twitter.com/MatchQr';
}

// La solución inteligente para tu club de pádel.
class LoginConstants {
  static String landingSlogan =
      "Facilita los pagos, fortalece la gestión en tu club.";
  static String emailBox = 'Email';
  static String passRecover = 'Recuperación de contraseña';
  static String passwordBox = 'Contraseña';
  static String confirmPass = 'Confirmar contraseña';
  static String forgotPasswordBox = 'Olvidé mi contraseña';
  static String signUpBoxBox = 'Registrarme';
  static String logInBox = 'Iniciar sesión';
  static String logOut = 'Cerrar sesión';
  static String recoverPassBox = 'Recuperar contraseña';
  static String loginGoogleBox = 'Iniciar sesión con Google';
  static String enterSomeText = 'El campo está vacío';
  static String registerMe = 'Registrarme';
  static String send = 'Enviar';
  static String close = 'Cerrar';
  static String passError = 'Error en contraseña';
  static String passDoNotMatch = 'Las contraseñas no coinciden';
  static String registerSuccess = 'Registrado correctamente';
  static String registerFail = 'Registro fallido';
  static String recoverPassSent = 'Te hemos enviado un correo electrónico';
  static String recoverPassFail = 'Fallido';
}

class LandingPageColors {
  static Color colorCards = const Color.fromARGB(255, 7, 2, 31);
}

class TextFieldsTexts {
  static const IntroTextField = 'Nombre de la pista';
  static const IdeaTextField = 'Descripción de la pista';
  static const GroupTextField = 'Grupo';
  static const priceText = 'Precio €';
  static const anyLinkTextField = 'Url/Texto';
  static const PagosTab = 'Pagos';
  static const DonacionCheckBox = 'El usuario decide cuánto pagar';
  static const urlTab = 'Url/Texto';
  static const WifiTab = 'WiFi';
  static const WifiName = 'Nombre de la red';
  static const WifiPass = 'Contraseña';
  static const WifiSecurity = 'Tipo de seguridad WiFi';
  static String qrOptionsStyle = 'Abrir Opciones';
  static String subidaMass = 'Generación masiva';
  static String privacyPolicy = 'Política de privacidad';
  static String generarQR = 'Generar QR';
  static String personalizarQR = 'Personalizar';
  static String nodataQR = '¡Vamos! Añade unos QR aquí.';
}

List<String> wifiSecTypes = ['WPA', 'WPA2', 'WPA3', 'WEP', 'NONE'];

Map<String, String> typesOfInsertMap = {
  'url': 'Enlace',
  'donation': 'Donación',
  'wifi': 'Credenciales WiFi',
  'fixprice': 'Pago',
  'checkOutNormal': 'Pago'
};

List<String> shapesQR = <String>['Cuadrado', 'Redondo'];

Map<String, QrEyeShape> selectedShapeQR = {
  'Cuadrado': QrEyeShape.square,
  'Redondo': QrEyeShape.circle
};

Map<String, QrDataModuleShape> selectedShapeDataQr = {
  'Cuadrado': QrDataModuleShape.square,
  'Redondo': QrDataModuleShape.circle
};

class PrivacyConstants {
  static String privacyText = '''Última actualización: 19/12/2023

En matchqr.es, respetamos su privacidad y estamos comprometidos con la protección de su información personal. Esta política de privacidad explica cómo recopilamos, utilizamos y compartimos su información personal en relación con los servicios proporcionados por nuestra aplicación matchqr, que le permite generar códigos QR para diversos propósitos.

Información que Recopilamos

-Información de Pago: Al generar códigos QR para pagos, utilizamos Stripe para procesar transacciones. No almacenamos datos de tarjetas de crédito en nuestros servidores.


Uso de la Información

La información recopilada se utiliza para:

-Generar el código QR solicitado.
-Facilitar las transacciones de pago a través de Stripe.
-Mejorar nuestros servicios y soporte al cliente.

No vendemos, alquilamos ni compartimos su información personal con terceros, excepto como se describe en esta política de privacidad o en conexión con nuestros servicios. La información de pago es procesada por Stripe y está sujeta a su propia política de privacidad.

Seguridad de la Información

En matchqr.es, consideramos la seguridad de su información personal como una prioridad máxima. Implementamos una variedad de medidas de seguridad para proteger sus datos personales contra el acceso no autorizado, la alteración, la divulgación o la destrucción.
Uso de Tecnología de Google (Firebase): Utilizamos Firebase, una plataforma de Google, para el almacenamiento y transmisión segura de datos. Firebase proporciona una infraestructura sólida y segura con medidas de seguridad integradas para garantizar la protección de sus datos.
Transmisión Segura: La información transmitida a través de nuestra aplicación se realiza mediante tecnologías de encriptación y transmisión segura como HTTPS, que encripta la información entre su dispositivo y nuestros servidores.
Almacenamiento Seguro de Datos: Los datos almacenados en Firebase se protegen mediante técnicas avanzadas de encriptación y medidas de seguridad administradas por Google. Esto incluye el uso de firewalls, controles de acceso, y monitoreo constante para prevenir y detectar cualquier actividad sospechosa.
Controles de Acceso: Implementamos controles de acceso estrictos para garantizar que solo el personal autorizado pueda acceder a su información personal cuando sea necesario para proporcionar nuestros servicios.
Auditorías y Mejoras Continuas: Realizamos auditorías regulares de nuestras prácticas y sistemas de seguridad. Nos comprometemos a mejorar continuamente nuestras medidas de seguridad en respuesta a las amenazas y desafíos cambiantes en seguridad de la información.
A pesar de nuestras medidas de seguridad, es importante tener en cuenta que ninguna medida de seguridad es infalible. Mientras nos esforzamos por proteger su información personal, no podemos garantizar su seguridad absoluta. En el improbable caso de una violación de seguridad que afecte sus datos personales, nos comprometemos a informarle y a tomar las acciones necesarias de acuerdo con las leyes y regulaciones aplicables.

Cambios a Esta Política de Privacidad

Nos reservamos el derecho a modificar esta política de privacidad en cualquier momento. Si hacemos cambios, los publicaremos en nuestra aplicación y actualizaremos la fecha de "última actualización" al principio de la política de privacidad.

Contacto

Si tiene preguntas o preocupaciones sobre nuestra política de privacidad o prácticas, por favor contacte a matchqrapp@gmail.com.
Al utilizar matchqr, usted acepta la recopilación y uso de su información personal como se describe en esta política de privacidad. ''';
}
