// Importaciones del sistema Dart
import 'dart:async';
import 'dart:io';

// Importaciones de paquetes externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:payment_tool/TimeSlotSelectionCard.dart';
import 'package:payment_tool/ParticlesBackground.dart';
import 'package:payment_tool/SlidingPanelCrearQr.dart';
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
  TextEditingController prodNameController = TextEditingController();
  TextEditingController prodDescController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController anyLinkController = TextEditingController();
  TextEditingController groupController = TextEditingController();

  final _controllerSideBar =
      SidebarXController(selectedIndex: 1, extended: true);

  DateTime? selectedDate;
  int tabSelected = 2;
  bool _estaDescargando = false;
  String? urlImage;
  bool isLoaded = false;
  String? groupSelected;

  late List<dynamic> dataPaymentsDataForCsv;
  late List<dynamic> dataPaymentsDataForCsvOnDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    dataPaymentsDataForCsv = [];
  }

  @override
  Widget build(BuildContext context) {
    var screenSizeW = MediaQuery.of(context).size.width;
    return Scaffold(
        drawer: SidebarXCustom(
          controller: _controllerSideBar,
        ),
        backgroundColor: ColorConstants.colortheme,
        appBar: CustomAppBar(title: '', hasTitle: false),
        body: SlidingUpPanel(
          backdropColor: AppColors.IconColor,
          collapsed: Center(
              child: Container(
            decoration: BoxDecoration(
              color: AppColors
                  .IconColor, // Un color que contraste con AppColors.IconColor
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // Cambios de posición de la sombra
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              weight: 50.0,
              color: Colors.white,
            ),
          )),
          color: ColorConstants.colorAppBar,
          minHeight: 40,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
          panel: SlidingPanelQR(
            email: widget.email,
            prodNameController: prodNameController,
            prodDescControlller: prodDescController,
            groupController: groupController,
          ),
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
                      child: Container(
                    color: AppColors.backgroundCard,
                    alignment: Alignment.center,
                    child: screenSizeW < StyleConstants.mobileSize
                        ? Wrap(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                            item['session_data']['created'] *
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              screenSizeW > StyleConstants.mobileSize
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _estaDescargando
                                                ? const CircularProgressIndicator()
                                                : InkWell(
                                                    child: const Icon(
                                                        Icons
                                                            .downloading_rounded,
                                                        weight: 20.0),
                                                    onTap: () async {
                                                      await filtrarYDescargarCSV(
                                                          dataPaymentsDataForCsv,
                                                          selectedDate);
                                                    },
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
                                        QRGroupsView(
                                          userEmail: widget.email,
                                          onGroupSelected: (group) {
                                            setState(() {
                                              groupSelected = group;
                                            });
                                          },
                                        ),
                                        QRLatestTransView(
                                            userEmail: widget.email,
                                            group: groupSelected.toString())
                                      ],
                                    )
                                  : const SizedBox.shrink(),
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
                                            item['session_data']['created'] *
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
                                      return item as Map<String, dynamic>;
                                    } else {
                                      return {};
                                    }
                                  }).toList();

                                  // Tu lógica para añadir los datos a dataPaymentsDataForCsv
                                  // Suponiendo que dataPaymentsDataForCsv es List<Map<String, dynamic>>
                                  //dataPaymentsDataForCsv.addAll(nuevosDatos);
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
                          ),
                  ));

                default:
                  return const Center(child: Text('Página no encontrada'));
              }
            },
            animation: _controllerSideBar,
            // child:
          ),
        ));
  }

  void clearControllers() {
    prodDescController.clear();
    prodNameController.clear();
    priceController.clear();
    anyLinkController.clear();
    groupController.clear();
  }

  @override
  void dispose() {
    prodDescController.dispose();
    prodNameController.dispose();
    priceController.dispose();
    anyLinkController.dispose();
    groupController.dispose();
    super.dispose();
  }
}
