import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class AnimatedCuadradosText extends StatefulWidget {
  @override
  _AnimatedCuadradosTextState createState() => _AnimatedCuadradosTextState();
}

class _AnimatedCuadradosTextState extends State<AnimatedCuadradosText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Size screenSize;
  late DateTime lastUpdateTime;
  late Timer _textTimer;

  late List<Cuadraditos> _cuadraditosList;
  late String _displayedText = "";

  @override
  void initState() {
    super.initState();
    screenSize = const Size(400, 400);
    lastUpdateTime = DateTime.now();

    final positions = calculateLetterPositions("MATCHQR", screenSize);

    _cuadraditosList = List.generate(
      positions.length,
      (index) => Cuadraditos(
        screenSize: screenSize,
        position: Offset(
          Random().nextInt(screenSize.width.toInt()).toDouble(),
          Random().nextInt(screenSize.height.toInt()).toDouble(),
        ),
        velocity: Offset.zero,
      ),
    );

    for (int i = 0; i < positions.length; i++) {
      _cuadraditosList[i].target = positions[i];
    }

    _controller = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: screenSize.width,
    )..addListener(() {
        setState(() {});
      });

    _startTextAnimation("MATCHQR");
  }

  @override
  void dispose() {
    _controller.dispose();
    _textTimer.cancel();
    super.dispose();
  }

  void _startTextAnimation(String text) {
    int index = 0;
    _textTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond.dx);
      },
      child: Stack(
        children: [
          CustomPaint(
            painter: CuadradoPainter(
              cuadrados: _cuadraditosList,
              onTick: () {
                setState(() {});
              },
            ),
          ),
          Positioned(
            top: screenSize.height * 0.5,
            left: screenSize.width * 0.1,
            child: Text(
              _displayedText,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _runAnimation(double velocity) {
    final simulation = SpringSimulation(
      SpringDescription(
        mass: 1,
        stiffness: 1,
        damping: 1,
      ),
      _controller.value,
      screenSize.width, // end position
      velocity,
    );

    _controller.animateWith(simulation);
  }
}

class Cuadraditos {
  Offset position;
  Offset velocity;
  Offset? target;
  var screenSize;

  Cuadraditos({
    required this.position,
    required this.velocity,
    required this.screenSize,
  });

  void update(double dt, Size size) {
    if (target != null) {
      final direction = target! - position;
      final distance = direction.distance;

      if (distance < 1) {
        position = target!;
      } else {
        // Lerp para suavizar el movimiento
        position = Offset.lerp(position, target!, 0.05)!;
      }
    } else {
      // Movimiento normal
      position += velocity * dt;
    }
  }
}

class CuadradoPainter extends CustomPainter {
  final List<Cuadraditos> cuadrados;
  final Function()? onTick;
  double t = 0.0;
  int startTime = DateTime.now().millisecondsSinceEpoch;

  CuadradoPainter({required this.cuadrados, this.onTick});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue]; // Cambiar a tus colores deseados
    final paint = Paint()..color = Color.lerp(colors[0], colors[1], t)!;
    for (final particle in cuadrados) {
      canvas.drawCircle(particle.position, 6.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CuadradoPainter oldDelegate) {
    return true;
  }
}

List<Offset> calculateLetterPositions(String text, Size screenSize) {
  // Aquí deberías implementar la lógica para calcular las posiciones de las letras
  // Según la longitud del texto y el tamaño de la pantalla
  // Por simplicidad, lo dejaremos como una lista de posiciones aleatorias por ahora
  final Random random = Random();
  final List<Offset> positions = [];
  final double step = screenSize.width / (text.length + 1);
  for (int i = 1; i <= text.length; i++) {
    positions.add(Offset(step * i, random.nextDouble() * screenSize.height));
  }
  return positions;
}
