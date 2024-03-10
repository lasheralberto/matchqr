
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:payment_tool/constants.dart';

import 'functions.dart';

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