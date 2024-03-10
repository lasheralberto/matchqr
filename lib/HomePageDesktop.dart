// Importaciones del sistema Dart
import 'dart:async';
import 'dart:io';

// Importaciones de paquetes externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:payment_tool/LatestTransactWidget.dart';
import 'package:payment_tool/LineChartWidgets.dart';
import 'package:payment_tool/TimeSlotSelectionCard.dart';
import 'package:payment_tool/ParticlesBackground.dart';
import 'package:payment_tool/SlidingPanelCrearQr.dart';
import 'package:payment_tool/filterChipGroups.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:fade_out_particle/fade_out_particle.dart';

// Importaciones locales
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/custoAppBar.dart';
import 'package:payment_tool/functions.dart';
import 'package:payment_tool/qrAdminPanel.dart';
import 'package:payment_tool/qrCards.dart';
import 'package:payment_tool/ButtonsAdminPanel.dart';
import 'package:payment_tool/SideBarMenu.dart';

import 'pagos_text_fields.dart';

class MyHomePageDesktop extends StatefulWidget {
  String email;
  MyHomePageDesktop({Key? key, required this.email}) : super(key: key);

  @override
  _MyHomePageDesktopState createState() => _MyHomePageDesktopState();
}

class _MyHomePageDesktopState extends State<MyHomePageDesktop>
    with TickerProviderStateMixin {
  TextEditingController priceController = TextEditingController();
  TextEditingController anyLinkController = TextEditingController();

  final _controllerSideBar =
      SidebarXController(selectedIndex: 1, extended: true);
  bool? _estaDescargando;
  DateTime? selectedDate;
  int tabSelected = 2;
  String? urlImage;
  bool isLoaded = false;
  String? groupSelected;
  int tabSelectedPanel = 1;

  late List<dynamic> dataPaymentsDataForCsv;
  late List<dynamic> dataPaymentsDataForCsvOnDate;
  late List<Widget> listOfCardWidgets;
  final PageController _pageController = PageController(
    initialPage: 1,
    viewportFraction: 0.4, // Ajusta este valor según tus necesidades
  );

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    dataPaymentsDataForCsv = [];
    _estaDescargando = false;
    listOfCardWidgets = cardPageView(context, widget.email);
  }

  @override
  Widget build(BuildContext context) {
    var screenSizeW = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: SidebarXCustom(
          controller: _controllerSideBar,
        ),
        //backgroundColor: ColorConstants.colortheme,
        appBar: CustomAppBar(title: '', hasTitle: false),
        body: AnimatedBuilder(
          builder: (context, child) {
            switch (_controllerSideBar.selectedIndex) {
              case 0:
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    QRCards(mail: widget.email, mode: tabSelected),
                  ],
                ));

              case 1:
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        // color: AppColors.backgroundCard,
                        alignment: Alignment.center,
                        child: screenSizeW < StyleConstants.mobileSize
                            ? Wrap(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          DateSelector(
                                            initialDate: DateTime.now(),
                                            onDateSelected: (p0) {
                                              setState(() {
                                                selectedDate = p0;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),

                                  QRAdminPanel(
                                    userEmail: widget.email,
                                    group: groupSelected.toString(),
                                    selectedDate: selectedDate,
                                    onDataLoaded: (p0) {
                                      var nuevosDatos =
                                          p0.map<Map<String, dynamic>>((item) {
                                        // Convertir el tiempo Unix a DateTime
                                        var itemDate =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                item['session_data']
                                                        ['created'] *
                                                    StyleConstants.mobileSize);

                                        // Formatear ambas fechas a 'dd/mm/yyyy'
                                        var formattedItemDate =
                                            "${itemDate.day.toString().padLeft(2, '0')}/${itemDate.month.toString().padLeft(2, '0')}/${itemDate.year}";
                                        var formattedSelectedDate =
                                            "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}";

                                        // Comparar las fechas formateadas
                                        if (formattedItemDate ==
                                            formattedSelectedDate) {
                                          dataPaymentsDataForCsv.add(item);
                                          return item as Map<String, dynamic>;
                                        } else {
                                          return {};
                                        }
                                      }).toList();
                                    },
                                  ),

                                  screenSizeW > StyleConstants.mobileSize
                                      ? TimeSlotSelectionCard(
                                          email: widget.email,
                                          group: groupSelected.toString(),
                                          dateSelected: selectedDate,
                                        )
                                      : const SizedBox.shrink(),

                                  ///Implementar nueva clase PaymentHistory aqui
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  screenSizeW > StyleConstants.mobileSize
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(height: 87),
                                            QRLatestTransView(
                                                userEmail: widget.email,
                                                group: groupSelected.toString())
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                  const SizedBox(
                                    width: 10,
                                  ),

                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _estaDescargando == true
                                              ? const CircularProgressIndicator()
                                              : GestureDetector(
                                                  onTap: () async {
                                                    await filtrarYDescargarCSV(
                                                        dataPaymentsDataForCsv,
                                                        selectedDate);
                                                  },
                                                  child: Card(
                                                      color:
                                                          AppColors.IconColor2,
                                                      //elevation:
                                                      // StyleConstants.elevation,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: Icon(
                                                          Icons
                                                              .downloading_rounded,
                                                          color: Colors.white,
                                                          weight: 20.0,
                                                        ),
                                                      )),
                                                ),
                                          DateSelector(
                                            initialDate: DateTime.now(),
                                            onDateSelected: (p0) {
                                              setState(() {
                                                selectedDate = p0;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      QRAdminPanel(
                                        userEmail: widget.email,
                                        group: groupSelected.toString(),
                                        selectedDate: selectedDate,
                                        onDataLoaded: (p0) {
                                          var nuevosDatos = p0
                                              .map<Map<String, dynamic>>(
                                                  (item) {
                                            // Convertir el tiempo Unix a DateTime
                                            var itemDate = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    item['session_data']
                                                            ['created'] *
                                                        1000);

                                            // Formatear ambas fechas a 'dd/mm/yyyy'
                                            var formattedItemDate =
                                                "${itemDate.day.toString().padLeft(2, '0')}/${itemDate.month.toString().padLeft(2, '0')}/${itemDate.year}";
                                            var formattedSelectedDate =
                                                "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}";

                                            // Comparar las fechas formateadas
                                            if (formattedItemDate ==
                                                formattedSelectedDate) {
                                              dataPaymentsDataForCsv.add(item);
                                              return item
                                                  as Map<String, dynamic>;
                                            } else {
                                              return {};
                                            }
                                          }).toList();
                                        },
                                      ),
                                    ],
                                  ),
                                  screenSizeW > StyleConstants.mobileSize
                                      ? TimeSlotSelectionCard(
                                          email: widget.email,
                                          group: groupSelected.toString(),
                                          dateSelected: selectedDate,
                                        )
                                      : const SizedBox.shrink(),

                                  ///Implementar nueva clase PaymentHistory aqui
                                ],
                              ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 1.0,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: listOfCardWidgets.length,
                          itemBuilder: (context, index) {
                            return listOfCardWidgets[index];
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 200,
                      )
                    ],
                  ),
                );

              default:
                return const Center(child: Text('Página no encontrada'));
            }
          },
          animation: _controllerSideBar,
          // child:
        ),
      ),
    );
  }
}
