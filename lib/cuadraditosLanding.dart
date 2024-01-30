import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:payment_tool/LoginWidget.dart';
import 'package:payment_tool/LoginWidgetMobile.dart';
import 'package:payment_tool/functions.dart';
import 'package:payment_tool/constants.dart';

class CuadraditosLanding extends StatefulWidget {
  const CuadraditosLanding({Key? key}) : super(key: key);

  @override
  _CuadraditosLandingState createState() => _CuadraditosLandingState();
}

class _CuadraditosLandingState extends State<CuadraditosLanding>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  late Size screenSize;
  late List<Cuadraditos> _cuadraditosList;
  late DateTime lastUpdateTime;

  // ... dentro de la clase _CuadraditosLandingState ...

  late AnimationController _textAnimationController;
  String _displayedText = "";
  final String _fullText = LoginConstants.landingSlogan;
  int _textIndex = 0;
  Timer? _textTimer;

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return screenSize.width > 600
        ? Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Parte izquierda con scroll
                Expanded(
                  flex: 1, // Ajusta la proporción si es necesario
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomPaint(
                            painter:
                                CuadradoPainter(cuadrados: _cuadraditosList),
                            isComplex: true,
                            child: SizedBox(
                              height: screenSize.height /
                                  2, // Ajusta según la altura de tu CustomPaint
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _displayedText,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 28.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        // Aquí puedes añadir más widgets que se desplazarán con el scroll
                        const Row(
                          // runAlignment: WrapAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 200,
                                  child: Card(
                                    color: AppColors.IconColor,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(
                                            Icons.qr_code_rounded,
                                            color: AppColors.IconColor2,
                                          ),
                                          title: Text(
                                            'Genera QR de pago para tus pistas',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 200,
                                  child: Card(
                                      color: AppColors.IconColor,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(
                                                Icons.wallet,
                                                color: AppColors.IconColor2,
                                              ),
                                              title: Text(
                                                'Monitorea la facturación de tus pistas',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ])),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 200,
                                  child: Card(
                                      color: AppColors.IconColor,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(
                                                Icons.album,
                                                color: AppColors.IconColor2,
                                              ),
                                              title: Text(
                                                'Gestiona devoluciones con un click',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ])),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Parte derecha fija
                SizedBox(
                  width: screenSize.width * 0.4,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration:
                          const BoxDecoration(color: AppColors.IconColor),
                      child: LoginWidget(),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: AppColors.IconColor, body: LoginWidgetMobile());
  }

  void _startTextAnimation(String text) {
    int index = 0;
    _textTimer =
        Timer.periodic(const Duration(milliseconds: 30), (Timer timer) {
      if (mounted) {
        setState(() {
          _displayedText = text.substring(0, index);
          if (index >= text.length)
            timer.cancel();
          else
            index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    screenSize =
        const Size(400, 400); // Valor inicial, se actualizará en build.

    // Define las posiciones objetivo para formar la palabra "MATCHQR"
    final positions = calculateLetterPositions("MATCHQR", screenSize);

    _cuadraditosList = List.generate(
        positions.length,
        (index) => Cuadraditos(
            screenSize: screenSize,
            position: Offset(
                Random().nextInt(screenSize.width.toInt()).toDouble(),
                Random().nextInt(screenSize.height.toInt()).toDouble()),
            velocity: Offset.zero));

    for (int i = 0; i < positions.length; i++) {
      _cuadraditosList[i].target = positions[i];
    }

    lastUpdateTime = DateTime.now();

    _ticker = createTicker((elapsed) {
      final now = DateTime.now();
      final dt = now.difference(lastUpdateTime).inMilliseconds / 700.0;
      lastUpdateTime = now;

      for (final particle in _cuadraditosList) {
        particle.update(dt, screenSize);
      }
      setState(() {});
    });
    _ticker.start();

    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Simulamos la finalización de la animación de los cuadraditos
    // con un Future.delayed
    Future.delayed(const Duration(seconds: 2), () {
      // Después de 3 segundos, comienza la animación de texto
      _startTextAnimation(LoginConstants.landingSlogan);
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();

    _ticker.dispose();
    super.dispose();
  }
}

class Cuadraditos {
  Offset position;
  Offset velocity;
  Offset? target;
  var screenSize;

  Cuadraditos(
      {required this.position,
      required this.velocity,
      required this.screenSize});

  void update(double dt, Size size) {
    if (target != null) {
      final direction = target! - position;
      final distance = direction.distance;

      if (distance < 1) {
        position = target!;
      } else {
        // Lerp para suavizar el movimiento
        position = Offset.lerp(position, target!,
            0.05)!; // Ajusta el factor de lerp según sea necesario
      }
    } else {
      // Movimiento normal
      position += velocity * dt;
    }
  }
}

class CuadradoPainter extends CustomPainter {
  final List<Cuadraditos> cuadrados;
  CuadradoPainter({required this.cuadrados});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;

    for (final particle in cuadrados) {
      canvas.drawCircle(particle.position, 3.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CuadradoPainter oldDelegate) {
    return true;
  }
}
