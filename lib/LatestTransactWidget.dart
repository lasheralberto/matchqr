
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:payment_tool/constants.dart';

import 'functions.dart';

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500), // Duración de la animación
      curve: Curves.easeInOut, // Curva de la animación
      height: MediaQuery.of(context).size.height * 0.82,
      width: MediaQuery.of(context).size.height * 0.4,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: StyleConstants.border // Esquinas redondeadas
            ),
        color: AppColors.IconColor3,
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
              height: MediaQuery.of(context).size.height * 0.75,
              width: MediaQuery.of(context).size.height * 0.4,
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
                        pathBackgroundColor: Colors.white);
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
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(datetime.toString()),
                                      FittedBox(
                                        fit: BoxFit
                                            .contain, // Ajusta el tamaño del widget al tamaño de su contenido
                                        child: CircleAvatar(
                                          radius: 28, // Tamaño del círculo
                                          backgroundColor: AppColors
                                              .IconColor2, // Color de fondo del círculo
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              (sessionsList[index]['session'][
                                                                  'session_data']
                                                              ['amount_total'] /
                                                          100)
                                                      .toStringAsFixed(2) +
                                                  '€',
                                              style: const TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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