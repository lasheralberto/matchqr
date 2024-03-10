import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:payment_tool/AnimationLogin.dart' as an;
import 'package:payment_tool/LoginWidget.dart';
import 'package:payment_tool/LoginWidgetMobile.dart';
import 'package:payment_tool/functions.dart';
import 'package:payment_tool/constants.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
  late AnimationController _textAnimationController;
  String _displayedText = "";
  String _displayedTextSlogan = "";
  String _displayedTextSlogan2 = "";
  int _textIndex = 0;
  Timer? _textTimer;
  PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.5);
  double _currentPage = 1;
  double _currentOffset = 0;
  int secondsForEveryText = 2;

  double _getCardScale(int pageIndex) {
    // Calcula la escala en función de la distancia entre la página actual y la página seleccionada
    double distance = (_currentPage - pageIndex).abs();
    return 1 - (distance * 0.4);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return screenSize.width > 600
        ? Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parte izquierda con scroll
                SizedBox(
                  width: screenSize.width / 2,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: CustomPaint(
                            painter:
                                CuadradoPainter(cuadrados: _cuadraditosList),
                            isComplex: true,
                            willChange: true,
                            child: SizedBox(
                              height: screenSize.height /
                                  2.2, // Ajusta según la altura de tu CustomPaint
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(_displayedText,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22.0,
                                  color: Colors.black38,
                                  fontWeight: FontWeight.values.last,
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Parte derecha fija
                Container(
                  width: screenSize.width * 0.4,
                  decoration: const BoxDecoration(
                    color: AppColors.IconColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.elliptical(30.0, 90.0),
                        bottomLeft: Radius.elliptical(30.0, 90.0)),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: LoginWidget(),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: AppColors.IconColor, body: LoginWidgetMobile());
  }

  Future<void> _startTextAnimation(String text, Function(String) updateText) {
    int index = 0;

    return Future<void>.delayed(const Duration(milliseconds: 20), () {
      Timer.periodic(const Duration(milliseconds: 20), (Timer timer) {
        if (mounted) {
          setState(() {
            updateText(text.substring(0, index));
            if (index >= text.length) {
              timer.cancel();
            } else {
              index++;
            }
          });
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    screenSize = const Size(800, 400); // Tamaño inicial
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });

    final positions = calculateLetterPositions("MATCHQR", screenSize);

    _cuadraditosList = List.generate(
      positions.length,
      (index) => Cuadraditos(
        screenSize: screenSize,
        position: Offset(
          positions[index].dx, // X se mantiene constante
          -10, // Empezar arriba de la pantalla
        ),
        velocity: const Offset(0, 20), // Velocidad inicial hacia abajo
      ),
    );

    // Establecer objetivos para los cuadrados (pelotas)
    for (int i = 0; i < positions.length; i++) {
      _cuadraditosList[i].target = positions[i];
    }

    lastUpdateTime = DateTime.now();

    _ticker = createTicker((elapsed) {
      final now = DateTime.now();
      final dt = now.difference(lastUpdateTime).inMilliseconds / 50.0;
      lastUpdateTime = now;

      for (final particle in _cuadraditosList) {
        particle.update(dt, screenSize);
      }
      setState(() {});
    });
    _ticker.start();

    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Simulamos la finalización de la animación de los cuadraditos
    // con un Future.delayed
    Future.delayed(Duration(seconds: secondsForEveryText), () async {
      // Después de 2 segundos, comienza la animación de texto
      // Llamada a la función
      await _startTextAnimation(LoginConstants.landingSlogan, (p0) {
        _displayedText = p0;
      });
    });
  }
}

class Cuadraditos {
  Offset position;
  Offset velocity;
  Offset? target;
  bool reachedTarget = false; // Indica si el cuadrado ha alcanzado su objetivo
  double bounceFactor = -0.9; // Factor de rebote
  var screenSize;
  List<Offset> gridPositions = [];

  Cuadraditos({
    required this.position,
    required this.velocity,
    required this.screenSize,
  }) {
    _generateGridPositions();
    _shuffleGridPositions();
  }

  // Genera una cuadrícula de posiciones uniformes dentro del área objetivo
  void _generateGridPositions() {
    const cellSize = 30; // Tamaño de celda
    final cols = screenSize.width ~/ cellSize;
    final rows = screenSize.height ~/ cellSize;

    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        final x = (j * cellSize).toDouble();
        final y = (i * cellSize).toDouble();
        gridPositions.add(Offset(x, y));
      }
    }
  }

  // Aleatoriza las posiciones dentro de la cuadrícula
  void _shuffleGridPositions() {
    gridPositions.shuffle();
  }

  // Método para generar la posición inicial aleatoria y converger hacia el objetivo
  void update(double dt, Size size) {
    if (target != null && !reachedTarget) {
      final direction = target! - position;
      final distance = direction.distance;

      if (distance < 1) {
        position = target!;
        reachedTarget = true; // Indicar que ha alcanzado el objetivo
      } else {
        // Lógica para converger hacia el objetivo
        position = Offset.lerp(position, target!, 0.05)!;
      }
    } else if (position != target && !reachedTarget) {
      // Generar movimiento aleatorio antes de converger hacia el objetivo
      if (gridPositions.isNotEmpty) {
        position = gridPositions.removeAt(0);
      }
    }
  }
}

class CuadradoPainter extends CustomPainter {
  final List<Cuadraditos> cuadrados;
  final Function()?
      onTick; // Función para notificar sobre cada tick de animación
  double t = 0.0; // Variable de tiempo para controlar la interpolación de color
  int startTime =
      DateTime.now().millisecondsSinceEpoch; // Tiempo de inicio de la animación

  CuadradoPainter({required this.cuadrados, this.onTick}) {
    // Inicializar el ticker para actualizar la variable de tiempo
    Ticker((elapsed) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      t = (currentTime - startTime) %
          1000 /
          1000; // Actualizar t cada 3 segundos
      // Notificar a través de la función proporcionada en cada tick de animación
      if (onTick != null) {
        onTick!();
      }
    }).start();
  }
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [AppColors.IconColor, AppColors.IconColor2];

    for (int i = 0; i < cuadrados.length; i++) {
      final particle = cuadrados[i];
      Paint paint;
      if (i > 57) {
        paint = Paint()..color = Color.lerp(colors[1], colors[1], t)!;
      } else {
        paint = Paint()..color = Color.lerp(colors[0], colors[0], t)!;
      }

      canvas.drawCircle(particle.position, 6.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CuadradoPainter oldDelegate) {
    return true;
  }
}

class MyCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;

  const MyCardWidget({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 220,
      child: Card(
        color: Colors.blueGrey, // Cambia el color según sea necesario
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Icon(icon,
                color: Colors.white), // Cambia el color según sea necesario
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
