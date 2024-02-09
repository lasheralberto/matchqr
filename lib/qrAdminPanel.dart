//Importaciones externas

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:fl_chart/fl_chart.dart';

//Importaciones locales
import 'package:payment_tool/commonWidgets.dart';
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/functions.dart';

class QRAdminPanel extends StatefulWidget {
  final String userEmail;
  final String group;
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
// Variable para almacenar el grupo

  Stream<QuerySnapshot<Map<String, dynamic>>>? _getFirestoreStream() {
    if (widget.group == "null" || widget.group == "Todos los grupos") {
      // Si widget.group es nulo, busca los grupos disponibles en la base de datos
      return _firestore
          .collection('users_paylinks')
          .doc(widget.userEmail)
          .collection('qrCodes')
          .snapshots();
    } else {
      return _firestore
          .collection('users_paylinks')
          .doc(widget.userEmail)
          .collection('qrCodes')
          .where('group', isEqualTo: widget.group)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSizeW = MediaQuery.of(context).size.width;
    var screenSizeH = MediaQuery.of(context).size.height;
    var screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: screenSizeW > 1000 ? screenSizeW * 0.40 : screenSizeW * 0.98,
            height:
                screenSizeW > 1000 ? screenSizeH * 0.60 : screenSizeH * 0.95,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: StyleConstants.border // Esquinas redondeadas
                  ),
              color: AppColors.IconColor,
              elevation: StyleConstants.elevation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _getFirestoreStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Text(
                        'Cargando..',
                        style: TextStyle(color: Colors.white),
                      ));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 200,
                              width: 200,
                              child: Image.asset(AssetsImages.noDataQrAdmin)),
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

                        num totalToGet;
                        num totalFacturado;
                        int totalConteo = 0;

                        String fechaActual =
                            '${widget.selectedDate.day.toString().padLeft(2, '0')}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.year}';

                        if (qrDataMap.containsKey('time_court_intervals')) {
                          var timeCourtIntervals =
                              qrDataMap['time_court_intervals']
                                  as Map<String, dynamic>;

                          // Verifica si existe la fecha deseada en time_court_intervals
                          if (timeCourtIntervals.containsKey(fechaActual)) {
                            var intervalosParaFecha =
                                timeCourtIntervals[fechaActual];
                            totalConteo = intervalosParaFecha.length;
                            // Aquí puedes trabajar con los intervalos para la fecha deseada
                            print(intervalosParaFecha);
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
                                    payment['session_data']['created'] * 1000);

                            if (createdDate.isAtSameMomentAs(startOfDay) ||
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
                            price = num.tryParse(qrDataMap['price'][fechaActual]
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
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: StyleConstants.border,
                                color: AppColors.IconColor),
                            child: Card(
                                color: AppColors.tileColor, // Fondo blanco
                                elevation:
                                    4, // Sombra ligera para resaltar la tarjeta
                                margin: const EdgeInsets.all(
                                    8), // Margen alrededor de la tarjeta

                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Card(
                                    elevation: StyleConstants.elevation,
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
                                              : const SizedBox.shrink(),
                                    ),
                                  ),
                                )),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  LineChartTotalFact(
                    datastream: _getFirestoreStream(),
                    lastNRegistros: 150,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Total Facturación QR (€)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                children: [
                  LineChartCount(
                    datastream: _getFirestoreStream(),
                    lastNRegistros: 150,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text('Nº de pagos QR',
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

void showInfoMatchesPopUp(
    BuildContext context, data, email, selectDate, screenSize) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: StyleConstants.border,
        ), // Hace que el diálogo sea redondeado
        child: Container(
          height: screenSize.height * 0.85,
          width: screenSize.width * 0.8,
          color: AppColors.IconColor,
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
                            var timeslots =
                                snapshot.data!.docs[0]['time_court_intervals'];

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
                            Map<String, List<dynamic>> groupedTransactions = {};
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
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          child: Card(
                                            color: containsRefund == true
                                                ? Colors.red
                                                : AppColors.tileColor,
                                            elevation: StyleConstants.elevation,
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
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    transaction['session_data']
                                                            ['customer_details']
                                                        ['name'],
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  const Spacer(),
                                                  screenSize.width > 1000
                                                      ? IconButton.outlined(
                                                          tooltip:
                                                              'Devolver pago',
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
                                                              .replay_circle_filled_rounded))
                                                      : const SizedBox.shrink()
                                                ],
                                              ),
                                              subtitle: Wrap(
                                                children: [
                                                  Text(
                                                    (transaction['session_data']
                                                                [
                                                                'amount_total'] /
                                                            100)
                                                        .toStringAsFixed(2),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    getCurrencySymbol(
                                                        transaction[
                                                                'session_data']
                                                            ['currency']),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Text(
                                                    datetime.toString(),
                                                    overflow: TextOverflow.fade,
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
                              child:
                                  Text('No hay historial de pagos disponible.'),
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
  );
}

class PaymentHistoryDialog extends StatefulWidget {
  final String email;
  final Function(dynamic) onRowPressed;

  PaymentHistoryDialog({required this.email, required this.onRowPressed});

  @override
  _PaymentHistoryDialogState createState() => _PaymentHistoryDialogState();
}

class _PaymentHistoryDialogState extends State<PaymentHistoryDialog> {
  String findTimeSlot(int unixTimestamp, List<String> timeSlots) {
    // Convertir el timestamp Unix a DateTime
    DateTime targetTime =
        DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

    for (var slot in timeSlots) {
      List<String> times = slot.split('-');
      DateTime startTime = DateTime(
          targetTime.year,
          targetTime.month,
          targetTime.day,
          int.parse(times[0].split(':')[0]),
          int.parse(times[0].split(':')[1]));
      DateTime endTime = DateTime(
          targetTime.year,
          targetTime.month,
          targetTime.day,
          int.parse(times[1].split(':')[0]),
          int.parse(times[1].split(':')[1]));

      // Verifica si la hora está en la franja horaria actual
      if ((targetTime.isAfter(startTime) ||
              targetTime.isAtSameMomentAs(startTime)) &&
          targetTime.isBefore(endTime)) {
        return slot;
      }
    }

    return "Hora no está en ninguna franja horaria";
  }

  String formatUnixTimestamp(int timestamp) {
    // Convertir a milisegundos
    int timestampInMilliseconds = timestamp * 1000;

    // Crear objeto DateTime
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestampInMilliseconds);

    // Formatear la fecha y hora en el formato DD-MM-YYYY HH:MM:SS
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  String getCurrencySymbol(String ticker) {
    switch (ticker.toLowerCase()) {
      case 'eur':
        return '€';
      case 'dollar':
        return '\$';
      default:
        return ticker;
    }
  }

  void _handleRowPressed(dynamic rowData) {
    widget.onRowPressed(rowData);
    Navigator.of(context).pop(); // Cierra el diálogo después de notificar
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            "Nombre del Producto", // Reemplaza con el nombre correcto
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Card(
              elevation: StyleConstants.elevation,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getDataFirestoreMatch(
                    widget.email, "acc_id"), // Reemplaza con tu función Future
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var document =
                        snapshot.data!.docs[0].data() as Map<String, dynamic>;
                    if (document.containsKey('payment_history') &&
                        document['payment_history'].isNotEmpty) {
                      var customerDetails =
                          document['payment_history'] as List<dynamic>;

                      var timeslots = document['time_court_intervals'];

                      return ListView.builder(
                        itemCount: customerDetails.length,
                        itemBuilder: (context, index) {
                          var detail = customerDetails[index]['session_data'];

                          return Card(
                            color: Colors.white,
                            elevation: 4,
                            margin: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: StyleConstants.border,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      detail['customer_details']['name'],
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      (detail['amount_total'] / 100)
                                          .toStringAsFixed(2),
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      getCurrencySymbol(detail['currency']),
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                                subtitle: ListTile(
                                  title: Text(
                                    formatUnixTimestamp(detail['created']),
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  subtitle: Text(findTimeSlot(
                                      detail['created'], timeslots)),
                                ),
                                trailing: IconButton(
                                  icon:
                                      const Icon(Icons.remove_red_eye_rounded),
                                  onPressed: () {
                                    _handleRowPressed(detail);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No hay historial de pagos disponible.',
                          overflow: TextOverflow.fade,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            child: const Text("Cerrar"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}

class QRGroupsView extends StatefulWidget {
  final String userEmail;
  Function(String group)? onGroupSelected;
  QRGroupsView(
      {Key? key, required this.userEmail, required this.onGroupSelected})
      : super(key: key);

  @override
  _QRGroupsViewState createState() => _QRGroupsViewState();
}

class _QRGroupsViewState extends State<QRGroupsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedGroup;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.height * 0.5,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: StyleConstants.border, // Esquinas redondeadas
        ),
        color: AppColors.IconColor,
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            const Text(
              'Grupos',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users_paylinks')
                    .doc(widget
                        .userEmail) // Accede al documento específico por el email
                    .collection(
                        'qrCodes') // Accede a la subcolección 'qrCodes' bajo ese documento
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Text('Cargando..'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text(
                      'No hay grupos disponibles.',
                      style: TextStyle(color: Colors.white),
                    ));
                  }

                  // Crear una lista de grupos únicos
                  var groups;

                  groups = snapshot.data!.docs
                      .map((doc) => doc['group'] as String)
                      .toSet()
                      .toList();

                  groups.add('Todos los grupos');

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: groups[index] == selectedGroup
                            ? Colors.blueGrey
                            : Colors.white, // Fondo blanco
                        elevation: 4, // Sombra ligera para resaltar la tarjeta
                        margin: const EdgeInsets.all(
                            8), // Margen alrededor de la tarjeta
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              StyleConstants.border, // Esquinas redondeadas
                        ),

                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                StyleConstants.border, // Esquinas redondeadas
                          ),
                          tileColor: groups[index] == selectedGroup
                              ? Colors.blueGrey
                              : Colors.white,
                          title: Text(
                            groups[index] == '' ? 'Sin grupo' : groups[index],
                            style: TextStyle(
                                fontWeight: groups[index] == selectedGroup
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: groups[index] == selectedGroup
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          onTap: () {
                            setState(() {
                              selectedGroup =
                                  groups[index]; // Actualiza la selección
                            });

                            widget.onGroupSelected!(groups[index]);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRLatestTransView extends StatefulWidget {
  final String userEmail;
  final String group;
  QRLatestTransView({Key? key, required this.userEmail, required this.group})
      : super(key: key);

  @override
  _QRLatestTransViewState createState() => _QRLatestTransViewState();
}

class _QRLatestTransViewState extends State<QRLatestTransView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedGroup;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _getFirestoreStream() {
    if (widget.group == "null" || widget.group == 'Todos los grupos') {
      return _firestore
          .collection('users_paylinks')
          .doc(widget.userEmail)
          .collection('qrCodes')
          .snapshots();
    } else {
      return _firestore
          .collection('users_paylinks')
          .doc(widget.userEmail)
          .collection('qrCodes')
          .where('group', isEqualTo: widget.group)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.50,
      width: MediaQuery.of(context).size.height * 0.5,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: StyleConstants.border // Esquinas redondeadas
            ),
        color: AppColors.IconColor,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Últimas transacciones',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFirestoreStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingIndicator(
                        indicatorType: Indicator.ballPulse,

                        /// Required, The loading type of the widget
                        colors: [Colors.white],

                        /// Optional, The color collections
                        strokeWidth: 2,

                        /// Optional, The stroke of the line, only applicable to widget which contains line
                        backgroundColor: Colors.white,

                        /// Optional, Background of the widget
                        pathBackgroundColor: Colors.white

                        /// Optional, the stroke backgroundColor
                        );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text(
                      'Aún no hay transacciones.',
                      style: TextStyle(color: Colors.white),
                    ));
                  }

                  List<Map<String, dynamic>> sessionsList =
                      getSessionDataListFromSnapshot(snapshot.data!);

                  // Ordenar la lista en orden descendente por la marca de tiempo Unix
                  sessionsList.sort((a, b) {
                    return b['session']['session_data']['created']
                        .compareTo(a['session']['session_data']['created']);
                  });

                  return ListView.builder(
                    itemCount: sessionsList.length,
                    itemBuilder: (context, index) {
                      // Convertir el timestamp Unix a DateTime
                      DateTime targetTime = DateTime.fromMillisecondsSinceEpoch(
                          sessionsList[index]['session']['session_data']
                                  ['created'] *
                              1000);

                      var datetim = DateTime(
                          targetTime.year,
                          targetTime.month,
                          targetTime.day,
                          targetTime.hour,
                          targetTime.minute,
                          targetTime.second);

                      var datetime =
                          DateFormat('dd/MM/yyyy HH:mm:ss').format(datetim);

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 10,
                                color: AppColors.tileColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: StyleConstants
                                        .border // Esquinas redondeadas
                                    ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: StyleConstants.border,
                                  ),
                                  tileColor: AppColors.tileColor,
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        sessionsList[index]['session']
                                                    ['session_data']
                                                ['customer_details']['name']
                                            .toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        sessionsList[index]['pista'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w200,
                                            color: Colors.black),
                                      )
                                    ],
                                  ),
                                  subtitle: ListTile(
                                    title: Text(
                                      (sessionsList[index]['session']
                                                          ['session_data']
                                                      ['amount_total'] /
                                                  100)
                                              .toStringAsFixed(2) +
                                          '€',
                                    ),
                                    subtitle: Text(datetime.toString()),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final dataStream; // Reemplaza con tu stream de datos

  LineChartWidget({required this.dataStream});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Facturación QR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.height * 0.4,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: StyleConstants.border, // Esquinas redondeadas
            ),
            child: StreamBuilder(
              stream: dataStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Center(
                          child: Text(
                              'Error: ${snapshot.error}'))); // Mostrar mensaje de error
                }

                if (snapshot.connectionState == ConnectionState.done ||
                    snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data.docs.isNotEmpty) {
                    final tusDatos = snapshot.data.docs;
                    List<FlSpot> dataPoints =
                        getLineChartData(snapshot.data.docs, 10)
                            .map((data) => data['punto'] as FlSpot)
                            .toList();

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 1.70,
                        child: LineChart(
                          LineChartData(
                            titlesData: const FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            backgroundColor: AppColors.tileColor,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(
                              show: false,
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.tileColor.withOpacity(0.2),
                                  width: 4,
                                ),
                                left: const BorderSide(
                                  color: Colors.transparent,
                                ),
                                right: const BorderSide(
                                  color: Colors.transparent,
                                ),
                                top: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                color: AppColors.IconColor,
                                spots: dataPoints,
                                // otras configuraciones para LineChartBarData...
                              ),
                            ],
                            // otras configuraciones para LineChartData...
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                } else {
                  return const Center(
                    child: Text('Error'),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LineChartTotalFact extends StatefulWidget {
  var datastream;
  var lastNRegistros;

  LineChartTotalFact({
    super.key,
    required this.datastream,
    required this.lastNRegistros,
    Color? gradientColor1,
    Color? gradientColor2,
    Color? gradientColor3,
    Color? indicatorStrokeColor,
  })  : gradientColor1 = gradientColor1 ?? Colors.white,
        gradientColor2 =
            gradientColor2 ?? const Color.fromRGBO(114, 142, 235, 1),
        gradientColor3 = gradientColor3 ?? AppColors.IconColor,
        indicatorStrokeColor = indicatorStrokeColor ?? Colors.black;

  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;

  @override
  State<LineChartTotalFact> createState() => _LineChartTotalFactState();
}

class _LineChartTotalFactState extends State<LineChartTotalFact> {
  Widget bottomTitleWidgets(
      double value, fechas, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.pink,
      fontFamily: 'Digital',
      fontSize: 18 * chartWidth / 500,
    );
    if (value < 0 || value >= fechas.length) {
      return Container();
    }

    // Formatear la fecha según sea necesario, aquí un ejemplo simple
    DateTime fecha = fechas[value.toInt()];
    String text =
        DateFormat('d/M').format(fecha); // Usar el formato que prefieras

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.height * 0.4,
      child: Card(
          color: AppColors.IconColor2,
          shape: RoundedRectangleBorder(
            borderRadius: StyleConstants.border, // Esquinas redondeadas
          ),
          elevation: StyleConstants.elevation,
          child: AspectRatio(
            aspectRatio: 2.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return StreamBuilder(
                  stream: widget.datastream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.data.docs.isNotEmpty) {
                      // Aquí se convierten los datos del snapshot en allSpots

                      List<FlSpot> allSpots = getLineChartData(
                              snapshot.data.docs, widget.lastNRegistros)
                          .map((data) => data['punto'] as FlSpot)
                          .toSet()
                          .toList();

                      List<dynamic> allDates = getLineChartData(
                              snapshot.data.docs, widget.lastNRegistros)
                          .map((data) => data['fecha'])
                          .toSet()
                          .toList();

                      var spotsLen = allSpots.length;
                      List<int> showingTooltipOnSpots = [];

                      int lenSpot = 0;
                      while (lenSpot < spotsLen) {
                        var spot = allSpots[lenSpot];
                        if (spot.y > 0) {
                          showingTooltipOnSpots.add(lenSpot);
                        }
                        lenSpot += 1;
                      }

                      final lineBarsData = [
                        LineChartBarData(
                          isStrokeCapRound: true,
                          isStepLineChart: true,
                          showingIndicators: showingTooltipOnSpots,
                          spots: allSpots,
                          isCurved: true,
                          barWidth: 4,
                          shadow: const Shadow(
                            blurRadius: 8,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                widget.gradientColor1.withOpacity(0.4),
                                widget.gradientColor2.withOpacity(0.4),
                                widget.gradientColor3.withOpacity(0.4),
                              ],
                            ),
                          ),
                          dotData: const FlDotData(show: false),
                          gradient: LinearGradient(
                            colors: [
                              widget.gradientColor1,
                              widget.gradientColor2,
                              widget.gradientColor3,
                            ],
                            stops: const [0.1, 0.4, 0.9],
                          ),
                        ),
                      ];

                      final tooltipsOnBar = lineBarsData[0];

                      return LineChart(
                        LineChartData(
                          showingTooltipIndicators:
                              showingTooltipOnSpots.map((index) {
                            return ShowingTooltipIndicators([
                              LineBarSpot(
                                tooltipsOnBar,
                                lineBarsData.indexOf(tooltipsOnBar),
                                tooltipsOnBar.spots[index],
                              ),
                            ]);
                          }).toList(),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            handleBuiltInTouches: false,
                            touchCallback: (FlTouchEvent event,
                                LineTouchResponse? response) {
                              if (response == null ||
                                  response.lineBarSpots == null) {
                                return;
                              }
                              if (event is FlTapUpEvent) {
                                final spotIndex =
                                    response.lineBarSpots!.first.spotIndex;
                                setState(() {
                                  if (showingTooltipOnSpots
                                      .contains(spotIndex)) {
                                    showingTooltipOnSpots.remove(spotIndex);
                                  } else {
                                    showingTooltipOnSpots.add(spotIndex);
                                  }
                                });
                              }
                            },
                            mouseCursorResolver: (FlTouchEvent event,
                                LineTouchResponse? response) {
                              if (response == null ||
                                  response.lineBarSpots == null) {
                                return SystemMouseCursors.basic;
                              }
                              return SystemMouseCursors.click;
                            },
                            getTouchedSpotIndicator: (LineChartBarData barData,
                                List<int> spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  const FlLine(
                                    color: Colors.pink,
                                  ),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                      radius: 6,
                                      color: lerpGradient(
                                        barData.gradient!.colors,
                                        barData.gradient!.stops!,
                                        percent / 100,
                                      ),
                                      strokeWidth: 2,
                                      strokeColor: widget.indicatorStrokeColor,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.pink,
                              tooltipRoundedRadius: 6,
                              getTooltipItems:
                                  (List<LineBarSpot> lineBarsSpot) {
                                return lineBarsSpot.map((lineBarSpot) {
                                  return LineTooltipItem(
                                    lineBarSpot.y.toString(),
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: lineBarsData,
                          minY: 0,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              axisNameWidget:
                                  Container(), // Vacío para no mostrar nada
                              axisNameSize:
                                  0, // Tamaño cero para el nombre del eje
                              sideTitles: const SideTitles(
                                showTitles:
                                    false, // No mostrar títulos en los ejes superiores
                                reservedSize:
                                    0, // Tamaño reservado cero para los títulos de los ejes
                              ),
                            ),
                            topTitles: AxisTitles(
                              axisNameWidget:
                                  Container(), // Vacío para no mostrar nada
                              axisNameSize:
                                  0, // Tamaño cero para el nombre del eje
                              sideTitles: const SideTitles(
                                showTitles:
                                    false, // No mostrar títulos en los ejes superiores
                                reservedSize:
                                    0, // Tamaño reservado cero para los títulos de los ejes
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget:
                                  Container(), // Vacío para no mostrar nada
                              axisNameSize:
                                  0, // Tamaño cero para el nombre del eje
                              sideTitles: SideTitles(
                                showTitles:
                                    true, // Habilitar la visualización de títulos en el eje inferior
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < allDates.length) {
                                    var fecha = allDates[index];
                                    String formattedDate = DateFormat('d/M')
                                        .format(fecha); // Formato de fecha
                                    return Transform.rotate(
                                      angle: -45 *
                                          3.1415927 /
                                          180, // Rotar -45 grados (en radianes)
                                      child: Text(
                                        formattedDate,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 10),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                                reservedSize:
                                    45, // Aumentar el espacio reservado para los títulos
                              ),
                            ),
                            rightTitles: AxisTitles(
                              axisNameWidget:
                                  Container(), // Vacío para no mostrar nada
                              axisNameSize:
                                  0, // Tamaño cero para el nombre del eje
                              sideTitles: const SideTitles(
                                showTitles:
                                    false, // No mostrar títulos en los ejes superiores
                                reservedSize:
                                    0, // Tamaño reservado cero para los títulos de los ejes
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.white10,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Aún no hay datos.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                );
              }),
            ),
          )),
    );
  }
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

List<Map<String, dynamic>> getLineChartDataCount(
    List<dynamic> paymentHistoryDocuments, int nRegistros) {
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
            sessionData['isRefunded'] == false) {
          allRecords.add(sessionData);
        }
      }
    }
  }

  // Ordenar por 'created' y tomar los últimos nRegistros
  allRecords.sort((a, b) => a['created'].compareTo(b['created']));
  List<Map<String, dynamic>> lastRecords = allRecords.take(nRegistros).toList();

  // Procesar los últimos nRegistros para el conteo de transacciones
  Map<DateTime, int> countPorDia = {};
  for (var record in lastRecords) {
    DateTime createdDate =
        DateTime.fromMillisecondsSinceEpoch(record['created'] * 1000);
    DateTime fechaSinHora =
        DateTime(createdDate.year, createdDate.month, createdDate.day);
    countPorDia.update(fechaSinHora, (existingCount) => existingCount + 1,
        ifAbsent: () => 1);
  }

  // Crear lista de mapas con fechas y puntos
  List<Map<String, dynamic>> fechaYpuntos = [];
  int index = 0;
  countPorDia.forEach((fecha, count) {
    fechaYpuntos.add({
      'fecha': fecha,
      'punto': FlSpot(index.toDouble(), count.toDouble()),
    });
    index++;
  });

  return fechaYpuntos;
}

class LineChartCount extends StatefulWidget {
  var datastream;
  var lastNRegistros;

  LineChartCount({
    super.key,
    required this.datastream,
    required this.lastNRegistros,
    Color? gradientColor1,
    Color? gradientColor2,
    Color? gradientColor3,
    Color? indicatorStrokeColor,
  })  : gradientColor1 = gradientColor1 ?? AppColors.IconColor,
        gradientColor2 =
            gradientColor2 ?? const Color.fromARGB(255, 123, 150, 240),
        gradientColor3 = gradientColor3 ?? Colors.white,
        indicatorStrokeColor = indicatorStrokeColor ?? Colors.black;

  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;

  @override
  _LineChartCountState createState() => _LineChartCountState();
}

class _LineChartCountState extends State<LineChartCount> {
  Widget bottomTitleWidgets(
      double value, fechas, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.pink,
      fontFamily: 'Digital',
      fontSize: 18 * chartWidth / 500,
    );
    if (value < 0 || value >= fechas.length) {
      return Container();
    }

    // Formatear la fecha según sea necesario, aquí un ejemplo simple
    DateTime fecha = fechas[value.toInt()];
    String text =
        DateFormat('d/M').format(fecha); // Usar el formato que prefieras

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.height * 0.4,
      child: Card(
          color: AppColors.IconColor2,
          shape: RoundedRectangleBorder(
            borderRadius: StyleConstants.border, // Esquinas redondeadas
          ),
          elevation: StyleConstants.elevation,
          child: AspectRatio(
            aspectRatio: 2.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return StreamBuilder(
                  stream: widget.datastream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                          child: Center(
                              child: Text(
                                  'Error: ${snapshot.error}'))); // Mostrar mensaje de error
                    }

                    if (snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.data!.docs.isNotEmpty) {
                        // Aquí se convierten los datos del snapshot en allSpots

                        List<FlSpot> allSpots = getLineChartDataCount(
                                snapshot.data.docs, widget.lastNRegistros)
                            .map((data) => data['punto'] as FlSpot)
                            .toList();

                        List<dynamic> allDates = getLineChartDataCount(
                                snapshot.data.docs, widget.lastNRegistros)
                            .map((data) => data['fecha'])
                            .toList();

                        var spotsLen = allSpots.length;
                        List<int> showingTooltipOnSpots = [];
                        int lenSpot = 0;
                        while (lenSpot < spotsLen) {
                          var spot = allSpots[lenSpot];
                          if (spot.y > 0) {
                            showingTooltipOnSpots.add(lenSpot);
                          }
                          lenSpot +=
                              1; // Incrementa lenSpot después de usarlo para acceder a la lista
                        }

                        final lineBarsData = [
                          LineChartBarData(
                            showingIndicators: showingTooltipOnSpots,
                            spots: allSpots,
                            isCurved: true,
                            barWidth: 4,
                            shadow: const Shadow(
                              blurRadius: 8,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  widget.gradientColor1.withOpacity(0.4),
                                  widget.gradientColor2.withOpacity(0.4),
                                  widget.gradientColor3.withOpacity(0.4),
                                ],
                              ),
                            ),
                            dotData: const FlDotData(show: false),
                            gradient: LinearGradient(
                              colors: [
                                widget.gradientColor1,
                                widget.gradientColor2,
                                widget.gradientColor3,
                              ],
                              stops: const [0.1, 0.4, 0.9],
                            ),
                          ),
                        ];

                        final tooltipsOnBar = lineBarsData[0];

                        return LineChart(
                          LineChartData(
                            showingTooltipIndicators:
                                showingTooltipOnSpots.map((index) {
                              return ShowingTooltipIndicators([
                                LineBarSpot(
                                  tooltipsOnBar,
                                  lineBarsData.indexOf(tooltipsOnBar),
                                  tooltipsOnBar.spots[index],
                                ),
                              ]);
                            }).toList(),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: false,
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return;
                                }
                                if (event is FlTapUpEvent) {
                                  final spotIndex =
                                      response.lineBarSpots!.first.spotIndex;
                                  setState(() {
                                    if (showingTooltipOnSpots
                                        .contains(spotIndex)) {
                                      showingTooltipOnSpots.remove(spotIndex);
                                    } else {
                                      showingTooltipOnSpots.add(spotIndex);
                                    }
                                  });
                                }
                              },
                              mouseCursorResolver: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return SystemMouseCursors.basic;
                                }
                                return SystemMouseCursors.click;
                              },
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    const FlLine(
                                      color: Colors.pink,
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 8,
                                        color: lerpGradient(
                                          barData.gradient!.colors,
                                          barData.gradient!.stops!,
                                          percent / 100,
                                        ),
                                        strokeWidth: 2,
                                        strokeColor:
                                            widget.indicatorStrokeColor,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.pink,
                                tooltipRoundedRadius: 6,
                                getTooltipItems:
                                    (List<LineBarSpot> lineBarsSpot) {
                                  return lineBarsSpot.map((lineBarSpot) {
                                    return LineTooltipItem(
                                      lineBarSpot.y.toString(),
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: lineBarsData,
                            minY: 0,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameWidget:
                                    Container(), // Vacío para no mostrar nada
                                axisNameSize:
                                    0, // Tamaño cero para el nombre del eje
                                sideTitles: const SideTitles(
                                  showTitles:
                                      false, // No mostrar títulos en los ejes superiores
                                  reservedSize:
                                      0, // Tamaño reservado cero para los títulos de los ejes
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget:
                                    Container(), // Vacío para no mostrar nada
                                axisNameSize:
                                    0, // Tamaño cero para el nombre del eje
                                sideTitles: SideTitles(
                                  showTitles:
                                      true, // Habilitar la visualización de títulos en el eje inferior
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < allDates.length) {
                                      var fecha = allDates[index];
                                      String formattedDate = DateFormat('d/M')
                                          .format(fecha); // Formato de fecha
                                      return Transform.rotate(
                                        angle: -45 *
                                            3.1415927 /
                                            180, // Rotar -45 grados (en radianes)
                                        child: Text(
                                          formattedDate,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10),
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                  reservedSize:
                                      45, // Aumentar el espacio reservado para los títulos
                                ),
                              ),
                              topTitles: AxisTitles(
                                axisNameWidget:
                                    Container(), // Vacío para no mostrar nada
                                axisNameSize:
                                    0, // Tamaño cero para el nombre del eje
                                sideTitles: const SideTitles(
                                  showTitles:
                                      false, // No mostrar títulos en los ejes superiores
                                  reservedSize:
                                      0, // Tamaño reservado cero para los títulos de los ejes
                                ),
                              ),
                              rightTitles: AxisTitles(
                                axisNameWidget:
                                    Container(), // Vacío para no mostrar nada
                                axisNameSize:
                                    0, // Tamaño cero para el nombre del eje
                                sideTitles: const SideTitles(
                                  showTitles:
                                      false, // No mostrar títulos en los ejes superiores
                                  reservedSize:
                                      0, // Tamaño reservado cero para los títulos de los ejes
                                ),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.white10,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'Aún no hay datos.',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: Text('Error'),
                      );
                    }
                  },
                );
              }),
            ),
          )),
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
