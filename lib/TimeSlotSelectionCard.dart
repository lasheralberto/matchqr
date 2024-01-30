import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:payment_tool/ButtonsAdminPanel.dart';
import 'package:payment_tool/HomePageDesktop.dart';
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/functions.dart';

class TimeSlotSelectionCard extends StatefulWidget {
  final String email;
  final String group;
  var dateSelected;

  TimeSlotSelectionCard(
      {Key? key,
      required this.email,
      required this.group,
      required this.dateSelected})
      : super(key: key);

  @override
  _TimeSlotSelectionCardState createState() => _TimeSlotSelectionCardState();
}

class _TimeSlotSelectionCardState extends State<TimeSlotSelectionCard> {
  List<Pista> pistas = [];
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _getFirestoreStream() {
    if (widget.group == "null" || widget.group == 'Todos los grupos') {
      return _firestore
          .collection('users_paylinks')
          .doc(widget.email)
          .collection('qrCodes')
          .snapshots();
    } else {
      return _firestore
          .collection('users_paylinks')
          .doc(widget.email)
          .collection('qrCodes')
          .where('group', isEqualTo: widget.group)
          .snapshots();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          const Text(
            'Horarios y precios',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _getFirestoreStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Text(
                  'Cargando..',
                  style: TextStyle(color: Colors.white),
                ));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text(
                  'No hay horarios disponibles.',
                  style: TextStyle(color: Colors.white),
                ));
              } else {
                // Parsear los datos y actualizar las listas de intervalos en las pistas
                var docs = snapshot.data!.docs;
                pistas = docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var accId = doc.id;
                  var nombrePista = data['prod_name'] as String;
                  var timeInterval = data['tiempoMinutos'];

                  Map<String, String> intervalosSeleccionados = {};

                  // Verifica si el campo 'time_court_intervals' existe en el documento
                  String fechaDeseada =
                      '${widget.dateSelected.day.toString().padLeft(2, '0')}-${widget.dateSelected.month.toString().padLeft(2, '0')}-${widget.dateSelected.year}';
                  Map<String, String> intervalosParaFechaDeseada = {};

// Verifica si el campo 'time_court_intervals' existe en el documento
                  if (data.containsKey('time_court_intervals')) {
                    var timeCourtIntervals =
                        data['time_court_intervals'] as Map<String, dynamic>;

                    // Verifica si existe la fecha deseada en time_court_intervals
                    if (timeCourtIntervals.containsKey(fechaDeseada)) {
                      intervalosParaFechaDeseada =
                          timeCourtIntervals[fechaDeseada]
                              .cast<String, String>();
                      // Ahora intervalosParaFechaDeseada contiene los intervalos para la fecha deseada
                    } else {
                      print(
                          'No se encontraron intervalos para la fecha $fechaDeseada');
                    }
                  } else {
                    print(
                        'No se encontraron time_court_intervals en el documento');
                  }

                  var intervalos =
                      generateTimeIntervals(timeInterval[fechaDeseada]);

                  return Pista(
                    accId: accId,
                    email: widget.email,
                    nombre: nombrePista,
                    intervalos: intervalos,
                    intervalosSeleccionados: intervalosParaFechaDeseada,
                    onUpdateIntervalos: updateIntervalosSeleccionados,
                    dateSelected: widget.dateSelected,
                    onUpdateTimeInterval: (String valor) {
                      setState(() {
                        timeInterval = int.parse(valor);
                      });
                    },
                  );
                }).toList();

                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              StyleConstants.border // Esquinas redondeadas
                          ),
                      color: AppColors.IconColor,
                      elevation: 4.0,
                      margin: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: pistas.map((pista) {
                            return pista;
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Función para actualizar los intervalos seleccionados en Firestore
  void onUpdateIntervalos(String email, String accId, String fecha,
      Map<String, String> intervalos) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    var docRef = _firestore
        .collection('users_paylinks')
        .doc(email)
        .collection('qrCodes')
        .doc(accId);

    String fieldToUpdate = 'time_court_intervals.$fecha';
    await docRef.update({fieldToUpdate: intervalos});
  }

  // Función para generar intervalos de tiempo
  List<String> generateTimeIntervals(timeInterval) {
    if (timeInterval == null) {
      timeInterval = 90;
    }
    List<String> intervals = [];
    DateTime startTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 8, 0); // Inicio a las 08:00 am
    DateTime endTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 23, 0); // Fin a las 23:00 pm

    while (startTime.isBefore(endTime)) {
      String interval =
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}-";
      startTime = startTime.add(
          Duration(minutes: timeInterval)); // Incrementa 90 minutos (1.5 horas)
      interval +=
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
      intervals.add(interval);
    }

    return intervals;
  }
}

class Pista extends StatefulWidget {
  final String accId;
  final String email;
  final String nombre;
  final List<String> intervalos;
  final Map<String, String> intervalosSeleccionados;
  var dateSelected;
  final Function(String, String, String, Map<String, String>)
      onUpdateIntervalos;
  final Function(String valor) onUpdateTimeInterval;

  Pista(
      {required this.accId,
      required this.email,
      required this.nombre,
      required this.intervalos,
      required this.intervalosSeleccionados,
      required this.onUpdateIntervalos,
      required this.onUpdateTimeInterval,
      required this.dateSelected})
      : super(key: Key(accId)); // Utilizar accId como clave única

  @override
  _PistaState createState() => _PistaState();
}

class _PistaState extends State<Pista> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: AppColors.tileColor,
      title: Text(
        widget.nombre,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: IntervalPopupPriceButton(
                email: widget.email,
                accId: widget.accId,
                datetime: widget.dateSelected,
                onPriceUpdate: (newPrice) {
                  updatePrice(widget.email, widget.accId, newPrice,
                      widget.dateSelected);
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Center(
              child: ButtonMinutesByMatch(
                email: widget.email,
                accId: widget.accId,
                fechadeseada: widget.dateSelected,
                onUpdate: (p0) async {
                  widget.onUpdateTimeInterval(p0);
                  await updateCourtTime(widget.email, widget.accId,
                      int.parse(p0), widget.dateSelected);

                  Map<String, String> intervalosParaElDia =
                      generateTimeIntervals(widget.dateSelected, int.parse(p0));

                  await updateIntervalosSeleccionados(widget.email,
                      widget.accId, widget.dateSelected, intervalosParaElDia);
                },
              ),
            ),
          ],
        ),
        Column(
          children: List.generate(widget.intervalos.length, (index) {
            return CheckboxListTile(
              title: Text(widget.intervalos[index]),
              value: widget.intervalosSeleccionados
                  .containsKey(widget.intervalos[index]),
              onChanged: (value) async {
                setState(() {
                  if (value!) {
                    widget.intervalosSeleccionados[widget.intervalos[index]] =
                        'X';
                  } else {
                    widget.intervalosSeleccionados
                        .remove(widget.intervalos[index]);
                  }
                });

                String fechaDeseada = formatearFecha(widget.dateSelected);

                await widget.onUpdateIntervalos(widget.email, widget.accId,
                    fechaDeseada, widget.intervalosSeleccionados);
              },
            );
          }),
        )
      ],
    );
  }
}
