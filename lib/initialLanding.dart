import 'package:flutter/material.dart';

import 'package:payment_tool/constants.dart';
import 'package:payment_tool/contactForm.dart';

class LandingPageInit extends StatefulWidget {
  const LandingPageInit({super.key});

  @override
  _LandingPageInitState createState() => _LandingPageInitState();
}

class _LandingPageInitState extends State<LandingPageInit>
    with SingleTickerProviderStateMixin {
  late AnimationController
      _animationController; // Usar 'late' para inicialización tardía
  late Animation<double>
      _opacityAnimation; // Usar 'late' para inicialización tardía
  late Animation<Alignment> _rightImageAnimation;
  late Animation<Alignment> _leftImageAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _scrollController.addListener(() {
      setState(() {
        _scrollPosition = _scrollController.position.pixels;
      });
    });

    // Animaciones para las imágenes
    _leftImageAnimation = Tween<Alignment>(
      begin: Alignment.centerLeft,
      end: Alignment.center,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rightImageAnimation = Tween<Alignment>(
      begin: Alignment.centerRight,
      end: Alignment.center,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildImageCard(String imagePath) {
    return SizedBox(
      height: 300,
      width: 450,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: const EdgeInsets.all(10),
        child: Image.asset(
          imagePath,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget buildTextsSeccion1() {
    return const Column(
      children: [
        Text(
          'Tu herramienta de gestión de códigos QR',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          'Genera y organiza, todo en un sólo lugar',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.normal, color: Colors.white),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget buildTextsSeccion2() {
    return const Column(
      children: [
        Text('Genera y personaliza tus QR de forma sencilla con Excel',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text('Posibilidad de generación masiva de QR',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w200,
                color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // sección 1
                SizedBox(
                  width: double.infinity,
                  child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                  '/images/landing_images/landing1.jpg'))),
                      child: Column(children: [
                        const SizedBox(height: 10),
                        buildTextsSeccion1(),
                        AnimatedBuilder(
                            animation: _rightImageAnimation,
                            builder: (context, child) {
                              return Align(
                                  widthFactor: 0.9,
                                  alignment: _leftImageAnimation.value,
                                  child: buildImageCard(
                                      'images/landing_images/landing_show_app.png'));
                            })
                      ])),
                ),
                //sección 2
                SizedBox(
                  width: double.infinity,
                  height: 550,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                  '/images/landing_images/landing2.jpg'))),
                      child: Column(children: [
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.signIn);
                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (c) {
                            //   return const LandingPage();
                            // }));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Color de fondo
                            foregroundColor: Colors.grey, // Color al presionar
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Borde redondeado
                            ),
                            elevation: 5, // Sombra del botón
                            textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          child: const Text(
                            'Empezar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        buildTextsSeccion2(),

                        const SizedBox(
                          height: 40,
                        ),

                        ///sección 2: Excel imagen
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Column(
                                children: [],
                              ),
                              SizedBox(
                                height: 300,
                                width: 500,
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 5,
                                  margin: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    'images/landing_images/landing_show_excel.png',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  ),
                ),
                // sección 3
                SizedBox(
                  width: double.infinity,
                  height: 500,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/landing_images/landing3.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Alinea las tarjetas horizontalmente en el centro
                        children: [
                          Card(
                            color: LandingPageColors.colorCards,
                            child: const SizedBox(
                              width: 200,
                              height: 100,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.payment_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Pagos",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            color: LandingPageColors.colorCards,
                            child: const SizedBox(
                              width: 200,
                              height: 100,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.web_sharp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Cualquier URL o texto",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            color: LandingPageColors.colorCards,
                            child: const SizedBox(
                              width: 200,
                              height: 100,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wifi,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("WiFi",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //sección 4:Politica de privacidad

                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/landing_images/landing2.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Alinea las tarjetas horizontalmente en el centro
                        children: [
                          GestureDetector(
                            child: const Text('Política de privacidad'),
                            onTap: () {
                              _showPrivacyPolicy(context);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            child: const Text('Acerca de'),
                            onTap: () {
                              _showAbout(context);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            child: const Text('Contacto'),
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (c) {
                                    return const ContactForm();
                                  });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAbout(BuildContext context) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        context: context,
        builder: (BuildContext bc) {
          return const SingleChildScrollView(
              child: AboutDialog(
            applicationName: 'qrtogo.es',
            applicationVersion: 'v 1.0',
          ));
        });
  }

  Future<void> _showPrivacyPolicy(BuildContext context) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        context: context,
        builder: (BuildContext bc) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(PrivacyConstants.privacyText),
            ),
          );
        });
  }
}
