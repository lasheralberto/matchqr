//Importaciones externas

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chat_gpt_api/app/model/data_model/completion/completion.dart';
import 'package:chat_gpt_api/app/model/data_model/completion/completion_request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:payment_tool/LineChartWidgets.dart';
import 'package:payment_tool/filterChipGroups.dart';
import 'package:payment_tool/main.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:fl_chart/fl_chart.dart';

//Importaciones locales
import 'package:payment_tool/commonWidgets.dart';
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/functions.dart';

class QRAdminPanel extends StatefulWidget {
  final String userEmail;
  String group;
  var selectedDate;
  Function(List<dynamic>) onDataLoaded;

  QRAdminPanel(
      {Key? key,
      required this.userEmail,
      required this.group,
      required this.selectedDate,
      required this.onDataLoaded})
      : super(key: key);

  @override
  _QRAdminPanelState createState() => _QRAdminPanelState();
}

class _QRAdminPanelState extends State<QRAdminPanel> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSizeW = MediaQuery.of(context).size.width;
    var screenSizeH = MediaQuery.of(context).size.height;
    var screenSize = MediaQuery.of(context).size;
    var snapshotDataTextPredictionInput;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 13,
          ),
          SizedBox(
            width: screenSizeW > 1000 ? screenSizeW * 0.40 : screenSizeW * 0.98,
            height:
                screenSizeW > 1000 ? screenSizeH * 0.80 : screenSizeH * 0.95,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: StyleConstants.border // Esquinas redondeadas
                  ),
              color: AppColors.IconColor3,
              // elevation: StyleConstants.elevation,
              child: Column(
                children: [
                  FilterChipsGroups(
                      userEmail: widget.userEmail,
                      onGroupSelected: (group) {
                        setState(() {
                          widget.group = group;
                        });
                      }),
                  SizedBox(
                    height: screenSizeW > 1000
                        ? screenSizeH * 0.40
                        : screenSizeH * 0.80,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: getFirestoreStream(
                            widget.userEmail, widget.group, _firestore),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: Text(
                              'Cargando..',
                              style: TextStyle(color: Colors.white),
                            ));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Image.asset(
                                        AssetsImages.noDataQrAdmin)),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Esperando nuestras pistas..',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ));
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var qrData = snapshot.data!.docs[index];
                              var qrDataMap = qrData.data();

                              snapshotDataTextPredictionInput =
                                  snapshot.data!.docs.toString();

                              num totalToGet;
                              num totalFacturado;
                              int totalConteo = 0;

                              String fechaActual =
                                  '${widget.selectedDate.day.toString().padLeft(2, '0')}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.year}';

                              if (qrDataMap
                                  .containsKey('time_court_intervals')) {
                                var timeCourtIntervals =
                                    qrDataMap['time_court_intervals']
                                        as Map<String, dynamic>;

                                // Verifica si existe la fecha deseada en time_court_intervals
                                if (timeCourtIntervals
                                    .containsKey(fechaActual)) {
                                  var intervalosParaFecha =
                                      timeCourtIntervals[fechaActual];
                                  totalConteo = intervalosParaFecha.length;
                                  // Aquí puedes trabajar con los intervalos para la fecha deseada
                                } else {
                                  print(
                                      'No se encontraron intervalos para la fecha $fechaActual');
                                }
                              } else {
                                print(
                                    'No se encontraron time_court_intervals en el documento');
                              }

                              if (qrDataMap.containsKey('payment_history') &&
                                  qrDataMap['payment_history'] != null) {
                                // El campo payment_history existe y no es nulo
                                double totalPagado = 0.00;
                                List<dynamic> paymentHistory =
                                    qrDataMap['payment_history'];

                                DateTime startOfDay = DateTime(
                                    widget.selectedDate.year,
                                    widget.selectedDate.month,
                                    widget.selectedDate.day);
                                DateTime endOfDay = DateTime(
                                    widget.selectedDate.year,
                                    widget.selectedDate.month,
                                    widget.selectedDate.day,
                                    23,
                                    59,
                                    59);

                                for (var payment in paymentHistory) {
                                  widget.onDataLoaded(paymentHistory);
                                  DateTime createdDate =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          payment['session_data']['created'] *
                                              1000);

                                  if (createdDate
                                          .isAtSameMomentAs(startOfDay) ||
                                      (createdDate.isAfter(startOfDay) &&
                                          createdDate.isBefore(endOfDay))) {
                                    if (payment['session_data']['isRefunded'] ==
                                        false) {
                                      totalPagado += (payment['session_data']
                                              ['amount_total']) /
                                          100 as double;
                                    }
                                  }
                                }

                                totalToGet = totalConteo *
                                    (qrDataMap['price'][fechaActual] ?? 0);
                                totalFacturado = totalPagado;

                                // Aquí puedes realizar operaciones con paymentHistory
                              } else {
                                // El campo payment_history no existe o es nulo
                                // Maneja la situación según sea necesario

                                num price;

                                // Verifica si qrDataMap['price'] ya es un número.
                                if (qrDataMap['price'][fechaActual] is num) {
                                  // Si ya es un número, úsalo directamente.
                                  price = qrDataMap['price'][fechaActual];
                                } else {
                                  // Si no es un número, intenta parsearlo como tal.
                                  price = num.tryParse(qrDataMap['price']
                                              [fechaActual]
                                          .toString()) ??
                                      0;
                                }

                                totalToGet = totalConteo * price;
                                totalFacturado = 0;
                              }

                              return GestureDetector(
                                onTap: () {
                                  showInfoMatchesPopUp(
                                      context,
                                      qrData,
                                      widget.userEmail,
                                      widget.selectedDate,
                                      screenSize);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds:
                                          500), // Duración de la animación
                                  curve:
                                      Curves.easeInOut, // Curva de la animación
                                  decoration: BoxDecoration(
                                      borderRadius: StyleConstants.border,
                                      color: AppColors.IconColor3),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Card(
                                      // elevation: StyleConstants.elevation,
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: StyleConstants
                                                .border), // Esquinas redondeadas

                                        title: Text(qrData['prod_name']),
                                        subtitle: Text(qrData['prod_desc']),
                                        tileColor: AppColors.tileColor,
                                        trailing: screenSizeW > 1000
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                              'Facturados: $totalFacturado de $totalToGet €'),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      ProgressBar(
                                                        value: (totalFacturado /
                                                            totalToGet),
                                                        backgroundColor:
                                                            Colors.blueGrey,
                                                        gradient:
                                                            const LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Colors.greenAccent,
                                                            Colors.green,
                                                            Colors.lightGreen,
                                                            Colors
                                                                .lightGreenAccent
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : screenSizeW > 1000
                                                ? Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  'Facturados: $totalFacturado de $totalToGet €'),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          ProgressBar(
                                                            value:
                                                                (totalFacturado /
                                                                    totalToGet),
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                            gradient:
                                                                const LinearGradient(
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                              colors: [
                                                                Colors
                                                                    .greenAccent,
                                                                Colors.green,
                                                                Colors
                                                                    .lightGreen,
                                                                Colors
                                                                    .lightGreenAccent
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}

void showRefundMsg(BuildContext context, text) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),
        height: 200, // Define la altura de tu Bottom Sheet aquí.
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(text),
              ElevatedButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      );
    },
  );
}

void showInfoMatchesPopUp(
    BuildContext context, data, email, selectDate, screenSize) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return Dialog(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: StyleConstants.border,
          ), // Hace que el diálogo sea redondeado
          child: Container(
            height: screenSize.height * 0.85,
            width: screenSize.width * 0.8,
            color: AppColors.IconColor3,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  data['prod_name'],
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Card(
                      elevation: StyleConstants.elevation,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            StyleConstants.border, // Esquinas redondeadas
                      ),
                      color: AppColors.tileColor,
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: getDataFirestoreMatch(email, data['acc_id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 20,
                              width: 20,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            var document = snapshot.data!.docs[0].data();

                            String fechaDeseada = formatearFecha(selectDate);

                            if (document.containsKey('payment_history') &&
                                document['payment_history'].isNotEmpty) {
                              var timeslots = snapshot.data!.docs[0]
                                  ['time_court_intervals'];

                              var intervalosEnFecha = timeslots[fechaDeseada];

                              List<String> intervalosSeleccionados =
                                  obtenerIntervalosConX(intervalosEnFecha);
                              var customerDetails = snapshot.data!.docs[0]
                                  ['payment_history'] as List<dynamic>;

                              //para filtrar por fecha
                              List<dynamic> customerDetailsInDate = [];

                              DateTime startOfDay = DateTime(selectDate.year,
                                  selectDate.month, selectDate.day);
                              DateTime endOfDay = DateTime(selectDate.year,
                                  selectDate.month, selectDate.day, 23, 59, 59);

                              for (var payment in customerDetails) {
                                DateTime createdDate =
                                    DateTime.fromMillisecondsSinceEpoch(payment[
                                            'session_data']['created'] *
                                        1000); // Asegúrate de que la conversión de timestamp sea correcta

                                if (createdDate.isAtSameMomentAs(startOfDay) ||
                                    (createdDate.isAfter(startOfDay) &&
                                        createdDate.isBefore(endOfDay))) {
                                  customerDetailsInDate.add(payment);
                                }
                              }

                              // Agrupar transacciones por franja horaria
                              Map<String, List<dynamic>> groupedTransactions =
                                  {};
                              for (var detail in customerDetailsInDate) {
                                String timeslot = findTimeSlot(
                                    detail['session_data']['created'],
                                    intervalosSeleccionados);
                                groupedTransactions
                                    .putIfAbsent(timeslot, () => [])
                                    .add(detail);
                              }

                              // Mostrar los grupos en la UI
                              return ListView.builder(
                                itemCount: groupedTransactions.keys.length,
                                itemBuilder: (context, index) {
                                  String timeslot =
                                      groupedTransactions.keys.elementAt(index);
                                  List<dynamic> transactions =
                                      groupedTransactions[timeslot]!;

                                  return ExpansionTile(
                                    initiallyExpanded: true,
                                    title: Text(
                                      timeslot,
                                      overflow: TextOverflow.fade,
                                    ),
                                    children: transactions.map((transaction) {
                                      var dateEpoch =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              transaction['session_data']
                                                      ['created'] *
                                                  1000);

                                      var datetim = DateTime(
                                          dateEpoch.year,
                                          dateEpoch.month,
                                          dateEpoch.day,
                                          dateEpoch.hour,
                                          dateEpoch.minute,
                                          dateEpoch.second);

                                      var datetime =
                                          DateFormat('dd/MM/yyyy HH:mm:ss')
                                              .format(datetim);

                                      //comprobar si es un pago devuelto
                                      bool containsRefund =
                                          transaction['session_data']
                                                      ['isRefunded'] ==
                                                  true
                                              ? true
                                              : false;

                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: Card(
                                              color: containsRefund == true
                                                  ? Colors.red
                                                  : AppColors.tileColor,
                                              elevation:
                                                  StyleConstants.elevation,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      StyleConstants.border
                                                  // Esquinas redondeadas
                                                  ),
                                              child: ListTile(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: StyleConstants
                                                      .border, // Esquinas redondeadas
                                                ),
                                                tileColor: AppColors.tileColor,
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  //mainAxisAlignment:
                                                  //    MainAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        transaction['session_data']
                                                                [
                                                                'customer_details']
                                                            ['name'],
                                                        maxLines:
                                                            1, // Limita el texto a una sola línea
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Flexible(
                                                      child: IconButton(
                                                          tooltip:
                                                              'Devolver pago',
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            primary: Colors
                                                                .white, // Cambia el color de fondo al color blanco
                                                            onPrimary: Colors
                                                                .blue, // Cambia el color del texto al azul
                                                            elevation:
                                                                2, // Añade una sombra al botón
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8), // Redondea las esquinas
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .blue), // Añade un borde azul alrededor del botón
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            int returnCode =
                                                                await refundPayment(
                                                                    transaction[
                                                                            'session_data']
                                                                        [
                                                                        'payment_intent']);

                                                            if (returnCode ==
                                                                200) {
                                                              // Obtener el mapa 'session_data' de la transacción
                                                              Map<String,
                                                                      dynamic>
                                                                  sessionData =
                                                                  transaction[
                                                                      'session_data'];

                                                              // Añadir el nuevo campo 'isRefunded' con el valor true
                                                              sessionData[
                                                                      'isRefunded'] =
                                                                  true;

                                                              await updatePaymentIntent(
                                                                  email,
                                                                  transaction[
                                                                          'session_data']
                                                                      [
                                                                      'payment_intent'],
                                                                  sessionData);

                                                              showRefundMsg(
                                                                  context,
                                                                  'Pago devuelto');
                                                            } else {
                                                              showRefundMsg(
                                                                  context,
                                                                  'Error al devolver el pago');
                                                            }
                                                          },
                                                          icon: const Icon(Icons
                                                              .replay_circle_filled_rounded)),
                                                    )
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        (transaction['session_data']
                                                                        [
                                                                        'amount_total'] /
                                                                    100)
                                                                .toStringAsFixed(
                                                                    2) +
                                                            ' ' +
                                                            getCurrencySymbol(
                                                                transaction[
                                                                        'session_data']
                                                                    [
                                                                    'currency']),
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        datetime.toString(),
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                // Agregar aquí más detalles si es necesario
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                child: Text(
                                    'No hay historial de pagos disponible.'),
                              );
                            }
                          }
                        },
                      )),
                ),
                const SizedBox(height: 15),
                CustomCloseButton(buttonText: 'Cerrar')
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Lerps between a [LinearGradient] colors, based on [t]
Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  if (colors.isEmpty) {
    throw ArgumentError('"colors" is empty.');
  } else if (colors.length == 1) {
    return colors[0];
  }

  if (stops.length != colors.length) {
    stops = [];

    /// provided gradientColorStops is invalid and we calculate it here
    colors.asMap().forEach((index, color) {
      final percent = 1.0 / (colors.length - 1);
      stops.add(percent * index);
    });
  }

  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s];
    final rightStop = stops[s + 1];
    final leftColor = colors[s];
    final rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}

List<FlSpot> getCountOfMatchesPerHour(List<dynamic> paymentHistoryDocuments) {
  Map<int, double> totalPorHora = {}; // Mapa para almacenar la suma por hora

  for (var document in paymentHistoryDocuments) {
    Map<String, dynamic> payment = document.data() as Map<String, dynamic>;

    if (payment.containsKey('payment_history') &&
        payment['payment_history'] != null) {
      var paymentHistoryList = payment['payment_history'] as List<dynamic>;

      for (var paymentDetail in paymentHistoryList) {
        Map<String, dynamic> sessionData =
            paymentDetail['session_data'] as Map<String, dynamic>;

        if (sessionData.containsKey('created') &&
            sessionData.containsKey('amount_total')) {
          DateTime createdDate = DateTime.fromMillisecondsSinceEpoch(
              sessionData['created'] * 1000);
          double amount = sessionData['amount_total'] / 100 as double;

          int hour = createdDate.hour; // Obtener la hora

          // Verificar si ya existe una suma para esa hora en el mapa
          if (totalPorHora.containsKey(hour)) {
            totalPorHora[hour] = totalPorHora[hour]! + amount;
          } else {
            totalPorHora[hour] = amount;
          }
        }
      }
    }
  }

  List<FlSpot> spots = [];
  totalPorHora.forEach((hour, total) {
    spots.add(FlSpot(hour.toDouble(), total));
  });

  return spots;
}

List<Map<String, dynamic>> getLineChartData(
    List<dynamic> paymentHistoryDocuments, nRegistros) {
  // Recolectar todos los registros relevantes
  List<Map<String, dynamic>> allRecords = [];
  for (var document in paymentHistoryDocuments) {
    Map<String, dynamic> payment = document.data() as Map<String, dynamic>;
    if (payment.containsKey('payment_history') &&
        payment['payment_history'] != null) {
      var paymentHistoryList = payment['payment_history'] as List<dynamic>;
      for (var paymentDetail in paymentHistoryList) {
        Map<String, dynamic> sessionData =
            paymentDetail['session_data'] as Map<String, dynamic>;
        if (sessionData.containsKey('created') &&
            sessionData.containsKey('amount_total') &&
            sessionData['isRefunded'] == false) {
          allRecords.add(sessionData);
        }
      }
    }
  }

  // Ordenar por 'created' y tomar los últimos 10 registros
  allRecords.sort((a, b) => a['created'].compareTo(b['created']));
  List<Map<String, dynamic>> lastTenRecords =
      allRecords.take(nRegistros).toList();

  // Procesar los últimos 10 registros
  Map<DateTime, double> totalPorDia = {};
  for (var record in lastTenRecords) {
    DateTime createdDate =
        DateTime.fromMillisecondsSinceEpoch(record['created'] * 1000);
    double amount = record['amount_total'] / 100 as double;
    DateTime fechaSinHora =
        DateTime(createdDate.year, createdDate.month, createdDate.day);
    totalPorDia.update(
        fechaSinHora, (existingAmount) => existingAmount + amount,
        ifAbsent: () => amount);
  }

  // Crear lista de mapas con fechas y puntos
  List<Map<String, dynamic>> fechaYpuntos = [];
  int index = 0;
  totalPorDia.forEach((fecha, total) {
    fechaYpuntos.add({
      'fecha': fecha,
      'punto': FlSpot(index.toDouble(), total),
    });
    index++;
  });

  return fechaYpuntos;
}

