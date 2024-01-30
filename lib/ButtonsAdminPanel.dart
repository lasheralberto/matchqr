import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/functions.dart';

class ButtonMinutesByMatch extends StatefulWidget {
  final Function(String) onUpdate; // Añade esta línea
  String accId;
  String email;
  var fechadeseada;

  ButtonMinutesByMatch(
      {required this.onUpdate,
      required this.accId,
      required this.email,
      required this.fechadeseada});

  @override
  State<ButtonMinutesByMatch> createState() => _ButtonMinutesByMatchState();
}

class _ButtonMinutesByMatchState extends State<ButtonMinutesByMatch> {
  // Añade esta línea
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users_paylinks')
          .doc(widget.email)
          .collection('qrCodes')
          .doc(widget.accId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        // Obtiene los datos del documento
        var data = snapshot.data!.data() as Map<String, dynamic>;
        int tiempoMinutos;
        // Verifica si el campo 'time_court_intervals' existe en el documento
        var fechaDeseada = formatearFecha(widget.fechadeseada);
        
        if (data.containsKey('tiempoMinutos')) {
          var dateMap = data['tiempoMinutos'] as Map<String, dynamic>;
          if (dateMap.containsKey(fechaDeseada)) {
            tiempoMinutos = data['tiempoMinutos'][fechaDeseada];
          } else {
            tiempoMinutos = 90;
          }
        } else {
          tiempoMinutos = 90;
        }

        return ElevatedButton(
          onPressed: () async {
            final result = await _showIntervalPopup(context);
            widget.onUpdate(result.toString());
            print("El valor devuelto es: $result");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.IconColor,
            shape: RoundedRectangleBorder(
              borderRadius: StyleConstants.border,
            ),
          ),
          child: Text('$tiempoMinutos min',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize.large.value)),
        );
      },
    );
  }

  Future<String?> _showIntervalPopup(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                StyleConstants.border, // Bordes redondeados del pop-up
          ),
          title: const Text(
            'Tiempo por partido',
            style: TextStyle(color: Colors.black), // Estilo del título
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "En minutos",
              border: OutlineInputBorder(
                borderRadius: StyleConstants.border, // Bordes del TextField
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.blue, // Color del texto del botón
              ),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Tiempo'),
            ),
          ],
        );
      },
    );
  }
}

class IntervalPopupPriceButton extends StatefulWidget {
  final Function(int) onPriceUpdate;
  String email;
  String accId;
  var datetime;

  IntervalPopupPriceButton(
      {required this.onPriceUpdate,
      required this.email,
      required this.accId,
      required this.datetime});

  @override
  State<IntervalPopupPriceButton> createState() =>
      _IntervalPopupTimeButtonState();
}

class _IntervalPopupTimeButtonState extends State<IntervalPopupPriceButton> {
  // Añade esta línea
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users_paylinks')
          .doc(widget.email)
          .collection('qrCodes')
          .doc(widget.accId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        // Obtiene los datos del documento
        var data = snapshot.data!.data() as Map<String, dynamic>;
        var fechadeseada = formatearFecha(widget.datetime);
        int price = int.tryParse(data['price'][fechadeseada].toString()) ??
            (data['price'][fechadeseada] is num
                ? (data['price'][fechadeseada] as num).toInt()
                : 0);

        return ElevatedButton(
          onPressed: () async {
            final result = await _showPricePopup(context);
            widget.onPriceUpdate(int.parse(result.toString()));
            print("El valor devuelto es: $result");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.IconColor,
            shape: RoundedRectangleBorder(
              borderRadius: StyleConstants.border,
            ),
          ),
          child: Text('$price €',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize.large.value)),
        );
      },
    );
  }

  Future<String?> _showPricePopup(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                StyleConstants.border, // Bordes redondeados del pop-up
          ),
          title: const Text(
            'Precio por partido',
            style: TextStyle(color: Colors.black), // Estilo del título
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "En euros",
              border: OutlineInputBorder(
                borderRadius: StyleConstants.border, // Bordes del TextField
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.blue, // Color del texto del botón
              ),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}

class DateSelector extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(picked); // Llama al callback con la nueva fecha
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: Card(
          color: AppColors.IconColor2,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormat('dd-MM-yyyy').format(selectedDate),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
