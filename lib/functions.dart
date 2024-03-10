import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:chat_gpt_api/app/model/data_model/completion/completion.dart';
import 'package:chat_gpt_api/app/model/data_model/completion/completion_request.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:payment_tool/LineChartWidgets.dart';
import 'package:payment_tool/main.dart';
import 'constants.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter

Stream<List<String>> getDataGroups(String email) {
  return FirebaseFirestore.instance
      .collection('users_paylinks')
      .doc(email) // Accede al documento específico basado en el email
      .collection('qrCodes') // Accede a la subcolección 'qrCodes'
      .snapshots()
      .map((snapshot) {
    // Extrae los grupos de cada documento QR
    var groups = snapshot.docs
        .map((doc) => doc.data()['group'].toString())
        .toSet() // Usa Set para eliminar duplicados
        .toList(); // Convierte el Set en una lista
    // Retorna una lista única de grupos
    return groups;
  });
}

Future<void> deleteUsersWithEmail(
    BuildContext context, String email, String group) async {
  String borradoStr;

  if (group == 'All') {
    borradoStr =
        '¿Estás seguro de que quieres borrar todos los QR?. Esta acción es irreversible.';
  } else {
    borradoStr =
        '¿Estás seguro de que quieres borrar los QR del grupo $group?. Esta acción es irreversible.';
  }

  bool confirm = await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: Text(borradoStr),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(dialogContext)
                .pop(false), // No procede con el borrado
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () =>
                Navigator.of(dialogContext).pop(true), // Procede con el borrado
          ),
        ],
      );
    },
  );

  if (confirm) {
    var firestore = FirebaseFirestore.instance;
    DocumentReference userDocRef =
        firestore.collection('users_paylinks').doc(email);
    CollectionReference qrCodesRef = userDocRef.collection('qrCodes');

    QuerySnapshot snapshot;
    if (group == 'All') {
      snapshot = await qrCodesRef.get();
    } else {
      snapshot = await qrCodesRef.where('group', isEqualTo: group).get();
    }

    if (snapshot.docs.isEmpty) {
      return;
    }

    WriteBatch batch = firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  } else {
    // Navigator.pop(context);
  }
}

Future<void> updatePaymentIntent(
    String userId, String paymentIntentId, Map<String, dynamic> newData) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference userDocRef =
      firestore.collection('users_paylinks').doc(userId);
  CollectionReference qrCodesRef = userDocRef.collection('qrCodes');

  try {
    // Obtener todos los documentos en la subcolección 'qrCodes'
    QuerySnapshot snapshot = await qrCodesRef.get();

    // Iterar sobre cada documento en 'qrCodes'
    for (var doc in snapshot.docs) {
      // Obtener los datos del documento
      Map<String, dynamic> qrCodeData = doc.data() as Map<String, dynamic>;

      // Verificar si 'payment_history' existe y contiene el payment_intent específico
      if (qrCodeData.containsKey('payment_history')) {
        List<dynamic> paymentHistory =
            List<dynamic>.from(qrCodeData['payment_history']);

        int indexToUpdate = paymentHistory.indexWhere((payment) =>
            payment['session_data']['payment_intent'] == paymentIntentId);

        if (indexToUpdate != -1) {
          // Recupera el documento completo
          var docSnapshot = await doc.reference.get();
          if (docSnapshot.exists) {
            var data = docSnapshot.data() as Map<String, dynamic>;

            // Modifica el campo específico en el array
            List<dynamic> paymentHistory = data['payment_history'];
            if (indexToUpdate < paymentHistory.length) {
              paymentHistory[indexToUpdate]['session_data']['isRefunded'] =
                  true;

              paymentHistory[indexToUpdate]['session_data']['amount_total'] =
                  (paymentHistory[indexToUpdate]['session_data']
                          ['amount_total']) *
                      -1;

              paymentHistory[indexToUpdate]['session_data']['amount_subtotal'] =
                  (paymentHistory[indexToUpdate]['session_data']
                          ['amount_subtotal']) *
                      -1;
            }

            // Actualiza el documento con el array modificado
            await doc.reference.update({'payment_history': paymentHistory});
          }
          break; // Salir del bucle si se encuentra y actualiza el payment_intent
        }
      }
    }
  } catch (e) {
    print('Error al actualizar el documento: $e');
  }
}

Stream<QuerySnapshot<Map<String, dynamic>>> getDataFirestoreMatch(
    String email, String accId) {
  try {
    // Referencia a la colección principal
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users_paylinks');

    // Referencia al documento específico del usuario basado en el email
    DocumentReference emailDocRef = usersRef.doc(email);

    // Referencia a la subcolección 'qrCodes' dentro del documento del email
    CollectionReference qrCodesRef = emailDocRef.collection('qrCodes');

    // Filtro por grupo y acc_id
    Query query;
    query = qrCodesRef.where('acc_id', isEqualTo: accId);

    // Devuelve los documentos filtrados y ordenados por 'createdOn'
    return query
        .orderBy('createdOn', descending: true)
        .snapshots()
        .map((snapshot) => snapshot as QuerySnapshot<Map<String, dynamic>>)
        .handleError(print);
  } on FirebaseException {
    throw ('Error al obtener los datos');
  }
}

Stream<QuerySnapshot<Map<String, dynamic>>> getDataFirestoreStream(
    String email, String group) {
  try {
    // Referencia a la colección principal
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users_paylinks');

    // Referencia al documento específico del usuario basado en el email
    DocumentReference emailDocRef = usersRef.doc(email);

    // Referencia a la subcolección 'qrCodes' dentro del documento del email
    CollectionReference qrCodesRef = emailDocRef.collection('qrCodes');

    if (group == 'All') {
      // Devuelve todos los documentos de la subcolección 'qrCodes' para este email
      return qrCodesRef
          .orderBy('createdOn', descending: true)
          .snapshots()
          .map((snapshot) => snapshot as QuerySnapshot<Map<String, dynamic>>)
          .handleError(print);
    } else {
      // Devuelve los documentos de la subcolección 'qrCodes' filtrados por grupo
      return qrCodesRef
          .where('group', isEqualTo: group)
          .orderBy('createdOn', descending: true)
          .snapshots()
          .map((snapshot) => snapshot as QuerySnapshot<Map<String, dynamic>>)
          .handleError(print);
    }
  } on FirebaseException {
    throw ('Error al obtener los datos');
  }
}

Stream<QuerySnapshot<Map<String, dynamic>>> getDataFirestoreStreamCount(
    String email, String group) {
  try {
    if (group == 'All') {
      return FirebaseFirestore.instance
          .collection('users_paylinks')
          .where('email', isEqualTo: email)
          .orderBy('createdOn', descending: true) // Ordena por 'createdOn'
          .snapshots()
          .handleError(print);
    } else {
      return FirebaseFirestore.instance
          .collection('users_paylinks')
          .where('email', isEqualTo: email)
          .where('group', isEqualTo: group)
          .orderBy('createdOn', descending: true) // Ordena por 'createdOn'
          .snapshots()
          .handleError(print);
    }
  } on FirebaseException {
    throw ('Hey');
  }
}

Future<bool> editGroupQRDoc(
    String email, String prodId, String newGroup) async {
  try {
    DocumentReference qrDocRef = FirebaseFirestore.instance
        .collection('users_paylinks')
        .doc(email)
        .collection('qrCodes')
        .doc(prodId);

    await qrDocRef.update({'group': newGroup});
    return true;
  } catch (e) {
    print(e); // O manejar el error de otra manera
    return false;
  }
}

Future<bool> deleteDocument(String email, String prodId) async {
  try {
    DocumentReference qrDocRef = FirebaseFirestore.instance
        .collection('users_paylinks')
        .doc(email)
        .collection('qrCodes')
        .doc(prodId);

    await qrDocRef.delete();
    return true;
  } catch (e) {
    print(e); // O manejar el error de otra manera
    return false;
  }
}

Future<dynamic> uploadPic(File? image1) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  storage.ref().putString(image1!.path, format: PutStringFormat.base64);
  var url = await storage.ref().getDownloadURL();
  return url;
}

Future<void> formularioContactoAdd(email, text) async {
  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('contact_help');

  await collectionRef
      .add({'emailFrom': email, 'text': text})
      .then((value) => print("User contacted successfully!"))
      .catchError((error) => print("Failed to add user: $error"));
}

Future<void> downloadAllQR(email, group) async {
  var url = Uri.parse(AppUrl.AzureBaseUrl + 'qrDownload/');

  try {
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'group': group}),
    );

    if (response.statusCode == 200) {
      createAndTriggerDownloadLink(response.bodyBytes, 'qr_archive.zip');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<int> refundPayment(paymentIntent) async {
  var url = Uri.parse(AppUrl.AzureBaseUrl + '/refundPayment');

  try {
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'payment_intent': paymentIntent}),
    );

    if (response.statusCode == 200) {
      return 200;
    } else {
      return 500;
    }
  } catch (e) {
    return 501;
  }
}

void createAndTriggerDownloadLink(List<int> bytes, String fileName) {
  // Convertir los bytes a Blob
  final blob = html.Blob([bytes]);

  // Crear un enlace URL para el Blob
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  // Limpiar el objeto URL después de la descarga
  html.Url.revokeObjectUrl(url);
}

class FileSaver {
  void saveAs(List<int> bytes, String fileName) =>
      js.context.callMethod("saveAs", [
        html.Blob([bytes]),
        fileName
      ]);
}

Future<void> addDataFirebase(
    {email,
    pay_link,
    acc_id,
    acc_dest_info,
    prod_name,
    prod_desc,
    price,
    typeOfInsert,
    qrStyle,
    group}) async {
  // Referencia a la colección principal
  CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users_paylinks');

  CollectionReference QrtoEmailRef =
      FirebaseFirestore.instance.collection('qr_to_email');

  // Crear o obtener el documento para el email específico
  DocumentReference emailDocRef = usersRef.doc(email);

  // Referencia a la subcolección 'qrCodes' dentro del documento del email
  CollectionReference qrCodesRef = emailDocRef.collection('qrCodes');

  // Crear un mapa para los intervalos de tiempo de los próximos 30 días
  Map<String, dynamic> allTimeIntervals = {};
  Map<String, dynamic> allPrices = {};
  Map<String, dynamic> allTiempoMinutos = {};

  for (int i = 0; i < 30; i++) {
    DateTime date = DateTime.now().add(Duration(days: i));
    String dateString =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    allTimeIntervals[dateString] = generateTimeIntervals(date, 90);
    allPrices[dateString] = 20;
    allTiempoMinutos[dateString] = 90;
  }

  // Agregar datos QR a la subcolección
  await qrCodesRef
      .add({
        'acc_id': acc_id,
        'prod_name': prod_name,
        'prod_desc': prod_desc,
        'pay_link': pay_link,
        'price': allPrices, //20€ por pista por defecto
        'type': typeOfInsert,
        'createdOn': DateTime.now(),
        'qrStyle': qrStyle,
        'group': group,
        'tiempoMinutos': allTiempoMinutos,
        'time_court_intervals': allTimeIntervals,
        // Agrega otros campos según sea necesario
      })
      .then((value) => print("QR Code added successfully!"))
      .catchError((error) => print("Failed to add QR code: $error"));

  await QrtoEmailRef.add({'plink': pay_link, 'acc_id': acc_id, 'email': email})
      .then((value) => print("QR Code added successfully!"))
      .catchError((error) => print("Failed to add QR code: $error"));
}

Future<dynamic> createPayLink(prodName, accId) async {
  var url = Uri.parse('${AppUrl.AzureBaseUrl}payLinkMisa/');
  var headers = {'Content-Type': 'application/json'};
  try {
    var response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          'prod_name': prodName,
          'acc_id': accId,
        }));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {}
}

Future<dynamic> createPayLinkNormal(prodName) async {
  var url = Uri.parse('${AppUrl.AzureBaseUrl}checkOutNormal/');
  var headers = {'Content-Type': 'application/json'};
  try {
    var response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          'prod_name': prodName,
        }));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {}
}

Future<bool> isInfoSubmitted(String accId) async {
  var url = Uri.parse('${AppUrl.AzureBaseUrl}retrieveAccInfo/');
  var headers = {'Content-Type': 'application/json'};
  int retryCount = 0;
  int maxRetries = 10; // Set a maximum number of retries

  bool isInfoSub = false;

  while (isInfoSub == false) {
    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'acc_id': accId}),
      );

      if (response.statusCode == 200) {
        var details = jsonDecode(response.body)['details_submitted'];
        if (details == true) {
          isInfoSub = true;
          return true;
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return false;
      }
    } catch (e) {
      print('An error occurred: $e');
      // Consider how to handle retries in case of exceptions
    }

    retryCount++;
    await Future.delayed(const Duration(seconds: 5)); // Delay before retrying
  }

  return false; // Return false if all retries fail
}

Future<dynamic> createAccountLink() async {
  // URL of the API endpoint
  var url = Uri.parse('${AppUrl.AzureBaseUrl}accLinkMisa/');
  var headers = {'Content-Type': 'application/json'};

  try {
    // Sending the POST request
    var response = await http.post(url, headers: headers);

    // Checking the response status
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}

// Map<String, String> generateTimeIntervals(p0) {
//   Map<String, String> intervals = {};
//   DateTime startTime = DateTime(DateTime.now().year, DateTime.now().month,
//       DateTime.now().day, 8, 0); // Inicio a las 08:00 am
//   DateTime endTime = DateTime(DateTime.now().year, DateTime.now().month,
//       DateTime.now().day, 23, 0); // Fin a las 23:00 pm

//   while (startTime.isBefore(endTime)) {
//     String interval =
//         "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}-";
//     startTime = startTime
//         .add(Duration(minutes: p0)); // Incrementa 90 minutos (1.5 horas)
//     interval +=
//         "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
//     intervals[interval] = 'X';
//   }

//   return intervals;
// }
Map<String, String> generateTimeIntervals(DateTime date, int minutes) {
  Map<String, String> intervals = {};
  DateTime startTime =
      DateTime(date.year, date.month, date.day, 8, 0); // 08:00 am
  DateTime endTime =
      DateTime(date.year, date.month, date.day, 23, 0); // 23:00 pm

  while (startTime.isBefore(endTime)) {
    String interval =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}-";
    startTime = startTime.add(Duration(minutes: minutes));
    interval +=
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
    intervals[interval] = 'X';
  }

  return intervals;
}

Future<dynamic> updateIntervalosSeleccionados(String email, String accId,
    String dayKey, Map<String, String> intervalosSeleccionados) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    // Obtén una referencia al documento en Firestore correspondiente a accId
    var docRef = _firestore
        .collection('users_paylinks')
        .doc(email)
        .collection('qrCodes')
        .doc(accId);

    // Actualiza solo los intervalos para el día específico
    String fieldToUpdate = 'time_court_intervals.$dayKey';
    await docRef.update({
      fieldToUpdate: intervalosSeleccionados,
    });

    print(
        'Intervalos actualizados en Firestore para accId: $accId, día: $dayKey');
  } catch (error) {
    print('Error al actualizar los intervalos: $error');
  }
}

String formatearFecha(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';
}

Future<void> updatePrice(
    String email, String accId, int price, DateTime dateSelected) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    // Obtén una referencia al documento en Firestore correspondiente a accId
    var docRef = _firestore
        .collection('users_paylinks')
        .doc(email)
        .collection('qrCodes')
        .doc(accId);

    // Formatea la fecha seleccionada para que coincida con las claves del mapa
    var dateFormated = formatearFecha(
        dateSelected); // Asegúrate de que esto genera una cadena en el formato correcto, por ejemplo, '29-01-2024'

    // Actualiza solo el precio para la fecha seleccionada dentro del mapa 'price'
    await docRef.update({
      'price.$dateFormated':
          price, // Notación "campo.clave" para actualizar un registro específico dentro de un mapa
    });

    print(
        'Precio actualizado en Firestore para $dateFormated en accId: $accId');
  } catch (error) {
    print('Error al actualizar los precios: $error');
  }
}

Future<void> updateCourtTime(
    String email, String accId, int time, DateTime dateSelected) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    // Obtén una referencia al documento en Firestore correspondiente a accId
    var docRef = _firestore
        .collection('users_paylinks')
        .doc(email)
        .collection('qrCodes')
        .doc(accId);

    // Actualiza el campo 'intervalosSeleccionados' con los nuevos valores
    // Primero, borra el campo 'time_court_intervals'
    var dateFormated = formatearFecha(
        dateSelected); // Asegúrate de que esto genera una cadena en el formato correcto, por ejemplo, '29-01-2024'

    await docRef.update({
      'tiempoMinutos.$dateFormated': time,
    });

    print('tiempos actualizados en Firestore para accId: $accId');
  } catch (error) {
    print('Error al actualizar los tiempos: $error');
  }
}

Future<List<Map<String, dynamic>>> obtenerPagosEnFechas(
    String email, String accId) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> listaPagos = [];

  try {
    // Obtén una referencia al documento en Firestore
    var docRef = await _firestore
        .collection('users_paylinks')
        .doc(email)
        .collection('qrCodes')
        .doc(accId)
        .get();

    // Verifica si el documento existe y tiene el campo deseado
    if (docRef.exists && docRef.data()!.containsKey('payment_history')) {
      var paymentHistory = docRef.data()!['payment_history'] as List<dynamic>;

      // Itera sobre cada elemento en el historial de pagos
      for (var payment in paymentHistory) {
        // Suponiendo que cada pago es un mapa y tiene 'session_data' que quieres extraer
        if (payment.containsKey('session_data')) {
          var sessionData = payment['session_data'] as Map<String, dynamic>;
          listaPagos.add(sessionData);
        }
      }
    } else {
      print('Documento no encontrado o campo payment_history no existe');
    }
  } catch (error) {
    print('Error al obtener los pagos: $error');
  }

  return listaPagos;
}

// Esta función aplana un JSON anidado para convertirlo en un mapa plano
Map<String, dynamic> aplanarJson(Map<String, dynamic> json,
    [String prefix = '']) {
  final SplayTreeMap<String, dynamic> resultado =
      SplayTreeMap<String, dynamic>();
  const camposPermitidos = {
    'session_data.amount_total',
    'session_data.created',
    'session_data.currency',
    'session_data.metadata_cust.pista_name',
    'session_data.customer_details.email',
    'session_data.customer_details.name',
    'session_data.customer_details.phone'
  };

  void funcionAplanar(Map<String, dynamic> subJson, String currentPrefix) {
    subJson.forEach((key, value) {
      var newKey = currentPrefix + key;
      if (value is Map) {
        funcionAplanar(value as Map<String, dynamic>, newKey + '.');
      } else {
        if (camposPermitidos.contains(newKey)) {
          if (newKey.endsWith('.created') && value is int) {
            newKey = newKey.replaceAll('session_data.', '');
            final dateTime = DateTime.fromMillisecondsSinceEpoch(value * 1000);
            // Crear dos campos separados para la fecha y la hora

            resultado['${newKey}_date'] =
                '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
            resultado['${newKey}_time'] =
                '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
          } else {
            // Aquí se pueden manejar otros campos si es necesario
            newKey = newKey.replaceAll('session_data.', '');
            resultado[newKey] = value;
          }
        }
      }
    });
  }

  funcionAplanar(json, prefix);
  return resultado;
}

// Esta función convierte una lista de JSON anidados en un CSV
String convertirJsonACsv(List<Map<String, dynamic>> jsonList) {
  // Aplanar cada elemento JSON
  final List<Map<String, dynamic>> datosAplanados =
      jsonList.map((json) => aplanarJson(json)).toList();

  // Usar un StringBuffer para construir el CSV
  final StringBuffer csvBuffer = StringBuffer();

  // Añadir encabezado si es necesario
  if (datosAplanados.isNotEmpty) {
    csvBuffer.writeln(datosAplanados.first.keys.join(","));
  }

  // Añadir los datos
  for (var jsonRow in datosAplanados) {
    csvBuffer.writeln(jsonRow.values.map((value) => '"$value"').join(","));
  }

  return csvBuffer.toString();
}

Future<void> crearYDescargarCSV(List<dynamic> jsonData) async {
  List<Map<String, dynamic>> dataPaymentsMaps =
      jsonData.map((item) => item as Map<String, dynamic>).toList();

  final String csvContent = convertirJsonACsv(dataPaymentsMaps);
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "datos.csv")
    ..click();

  // Limpiar los recursos
  html.Url.revokeObjectUrl(url);
}

Future<Map<String, String>> obtenerIntervalosSeleccionados(
    String email, String accId) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> intervalosSeleccionados = {};

  try {
    // Obtén una referencia al documento en Firestore correspondiente a accId
    var docRef = await _firestore
        .collection('users_paylinks')
        .doc(email)
        .collection('qrCodes')
        .doc(accId)
        .get();

    // Verifica si el documento existe y tiene el campo deseado
    if (docRef.exists && docRef.data()!.containsKey('time_court_intervals')) {
      // Extrae el campo 'time_court_intervals' y lo almacena en el mapa
      intervalosSeleccionados =
          Map<String, String>.from(docRef.data()!['time_court_intervals']);
    } else {
      print('Documento no encontrado o campo time_court_intervals no existe');
    }
  } catch (error) {
    print('Error al obtener los intervalos: $error');
  }

  return intervalosSeleccionados;
}

String findTimeSlot(int unixTimestamp, List<String> timeslots) {
  // Convertir el timestamp Unix a DateTime
  DateTime targetTime =
      DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

  timeslots.sort((a, b) {
    // Separar las horas de inicio de los intervalos
    var startA = a.split('-')[0]; // Obtiene la hora de inicio de 'a'
    var startB = b.split('-')[0]; // Obtiene la hora de inicio de 'b'

    // Convertir las horas de inicio a DateTime
    // Nota: Asumimos que todas las fechas son del mismo día
    DateTime timeA = DateFormat("HH:mm").parse(startA);
    DateTime timeB = DateFormat("HH:mm").parse(startB);

    // Comparar las horas de inicio
    return timeA.compareTo(timeB);
  });

  for (int i = 0; i < timeslots.length; i++) {
    List<String> currentSlotTimes = timeslots[i].split('-');
    DateTime currentStartTime = DateTime(
        targetTime.year,
        targetTime.month,
        targetTime.day,
        int.parse(currentSlotTimes[0].split(':')[0]),
        int.parse(currentSlotTimes[0].split(':')[1]));
    DateTime currentEndTime = DateTime(
        targetTime.year,
        targetTime.month,
        targetTime.day,
        int.parse(currentSlotTimes[1].split(':')[0]),
        int.parse(currentSlotTimes[1].split(':')[1]));

    // Si el tiempo está dentro de los últimos 30 minutos del intervalo actual
    if (targetTime.isAfter(currentEndTime.subtract(Duration(minutes: 30))) &&
        targetTime.isBefore(currentEndTime)) {
      // Si hay un siguiente intervalo, clasificar en el siguiente intervalo
      if (i < timeslots.length - 1) {
        return timeslots[i + 1];
      }
    }

    // Verifica si la hora está dentro del intervalo actual
    if (targetTime.isAtSameMomentAs(currentStartTime) ||
        (targetTime.isAfter(currentStartTime) &&
            targetTime.isBefore(currentEndTime))) {
      return timeslots[i];
    }
  }

  // Si no se encuentra un intervalo coincidente, devolver mensaje
  return "Hora no está en ninguna franja horaria";
}

String formatUnixTimestamp(int timestamp) {
  // Convertir a milisegundos
  int timestampInMilliseconds = timestamp * 1000;

  // Crear objeto DateTime
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(timestampInMilliseconds);

  // Formatear la fecha y hora en el formato DD-MM-YYYY HH:MM:SS
  return "Fecha y hora de pago: ${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}  a las ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
}

List<String> obtenerIntervalosConX(Map<String, dynamic> intervalos) {
  List<String> intervalosConX = [];

  intervalos.forEach((clave, valor) {
    // Convierte 'valor' a String antes de la comparación
    if (valor.toString() == "X") {
      intervalosConX.add(clave);
    }
  });

  return intervalosConX;
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

List<Map<String, dynamic>> getSessionDataListFromSnapshot(snapshot) {
  List<Map<String, dynamic>> sessionsList = [];

  for (var doc in snapshot.docs) {
    var data = doc.data(); // Obtiene los datos del documento.

    if (data.containsKey('payment_history')) {
      var paymentHistory = data['payment_history'];
      var pista = data['prod_name'];

      // Verifica que 'payment_history' sea una lista antes de hacer el casting.
      if (paymentHistory is List) {
        List<dynamic> sessionDataList = paymentHistory;

        // Itera sobre 'sessionDataList' de forma segura.
        for (var sessionData in sessionDataList) {
          if (sessionData is Map<String, dynamic>) {
            // Agrega el mapa de datos de la sesión a 'sessionsList'.
            var sessionDataWithPista = {'pista': pista, 'session': sessionData};

            // Agrega el nuevo mapa a 'sessionsList'.
            sessionsList.add(sessionDataWithPista);
          }
        }
      }
    }
  }

  // Ordena la lista por el campo 'created'
  sessionsList.sort((a, b) {
    var createdA = a['created'];
    var createdB = b['created'];
    if (createdA is Timestamp && createdB is Timestamp) {
      return createdB.compareTo(createdA);
    }
    return 0; // o manejar el caso en que 'created' no es un Timestamp
  });

  return sessionsList;
}

Future<void> filtrarYDescargarCSV(data, selectedDate) async {
  Set<dynamic> idsYaAnadidos = {};
  List<Map<String, dynamic>> dataPaymentsDataForCsvOnDate = [];

  for (var row in data) {
    var itemDate = DateTime.fromMillisecondsSinceEpoch(
        row['session_data']['created'] * 1000);
    var formattedItemDate =
        "${itemDate.day.toString().padLeft(2, '0')}/${itemDate.month.toString().padLeft(2, '0')}/${itemDate.year}";
    var formattedSelectedDate =
        "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}";

    var id = row['session_data']['payment_intent'];
    if (formattedItemDate == formattedSelectedDate &&
        !idsYaAnadidos.contains(id)) {
      dataPaymentsDataForCsvOnDate.add(row);
      idsYaAnadidos.add(id);
    }
  }

  await crearYDescargarCSV(dataPaymentsDataForCsvOnDate);

  dataPaymentsDataForCsvOnDate.clear();
}

List<Offset> calculateLetterPositions(String word, Size screenSize) {
  const double gridSize = 5.0;
  const double letterSpacing = gridSize * 1.1;
  final double startX = -100;
  // final double startX = (screenSize.width -
  //         (word.length * gridSize * 4 + (word.length - 1) * letterSpacing)) /
  //     4;
  final double startY = (screenSize.height - gridSize * 5) / 1;

  final Map<String, List<List<int>>> letters = {
    'M': [
      [0, 4],
      [0, 3],
      [0, 2],
      [0, 1],
      [0, 0],
      [1, 1],
      [2, 2],
      [3, 1],
      [4, 0],
      [4, 1],
      [4, 2],
      [4, 3],
      [4, 4]
    ],
    'A': [
      [2, 0],
      [1, 1],
      [2, 1],
      [3, 1],
      [0, 2],
      [1, 2],
      [2, 2],
      [3, 2],
      [4, 2],
      [0, 3],
      [4, 3],
      [0, 4],
      [4, 4]
    ],
    'T': [
      [0, 0],
      [1, 0],
      [2, 0],
      [3, 0],
      [4, 0],
      [2, 1],
      [2, 2],
      [2, 3],
      [2, 4]
    ],
    'C': [
      [1, 0],
      [2, 0],
      [3, 0],
      [0, 1],
      [4, 1],
      [0, 2],
      [0, 3],
      [1, 4],
      [2, 4],
      [3, 4]
    ],
    'H': [
      [0, 0],
      [0, 1],
      [0, 2],
      [0, 3],
      [0, 4],
      [1, 2],
      [2, 2],
      [3, 2],
      [4, 0],
      [4, 1],
      [4, 2],
      [4, 3],
      [4, 4]
    ],
    'Q': [
      [1, 0],
      [2, 0],
      [3, 0],
      [0, 1],
      [4, 1],
      [0, 2],
      [4, 2],
      [0, 3],
      [1, 4],
      [2, 4],
      [3, 3],
      [4, 4]
    ],
    'R': [
      [0, 0],
      [0, 1],
      [0, 2],
      [0, 3],
      [0, 4],
      [1, 0],
      [2, 0],
      [3, 1],
      [1, 2],
      [2, 2],
      [3, 3],
      [4, 4]
    ],
    // Agrega las definiciones de las letras que necesites
  };

  final List<Offset> positions = [];
  double currentX = startX;

  for (final char in word.split('')) {
    final letter = letters[char];
    if (letter != null) {
      for (final point in letter) {
        final x = currentX + point[0] * gridSize;
        final y = startY + point[1] * gridSize;
        positions.add(Offset(x, y));
      }
    }
    currentX += gridSize * 5 + letterSpacing;
  }

  return positions;
}

Future<String?> textCompletion(textInput) async {
  String inputPrompt =
      // ignore: prefer_interpolation_to_compose_strings
      'Dame la información más relevante sobre este historial de pagos en el contexto de un club de tenis. Muestra las estadísticas más importantes:' +
          textInput;
  Completion? completion = await chatGpt.textCompletion(
    request: CompletionRequest(
      prompt: inputPrompt,
      maxTokens: 100,
    ),
  );

  if (kDebugMode) {
    print(completion?.choices);
  }

  return completion?.choices!.first.text;
}

Stream<QuerySnapshot<Map<String, dynamic>>>? getFirestoreStream(
    usermail, group, _fireStoreInstance) {
  if (group == "null" || group == "Todos los grupos") {
    // Si widget.group es nulo, busca los grupos disponibles en la base de datos
    return _fireStoreInstance
        .collection('users_paylinks')
        .doc(usermail)
        .collection('qrCodes')
        .snapshots();
  } else {
    return _fireStoreInstance
        .collection('users_paylinks')
        .doc(usermail)
        .collection('qrCodes')
        .where('group', isEqualTo: group)
        .snapshots();
  }
}

List<Widget> cardPageView(BuildContext context, email) {
  return [
    LineChartTotalFact(
      datastream: getFirestoreStream(
          email, "Todos los grupos", FirebaseFirestore.instance),
      lastNRegistros: 150,
    ),
    TextSummayCard(
      datastream: getFirestoreStream(
          email, "Todos los grupos", FirebaseFirestore.instance),
    ),
    LineChartCount(
      datastream: getFirestoreStream(
          email, "Todos los grupos", FirebaseFirestore.instance),
      lastNRegistros: 150,
    ),
  ];
}

Map<String, dynamic> getTotalFacturacionPorDia(
    List<dynamic> paymentHistoryDocuments) {
  Map<String, double> totalPorDia = {};
  Map<String, int> totalDePagosEnFecha = {'NumberOfPayments': 0};
  Map<String, int> currentDaysOfMonth = {'DaysOfMonth': 0};

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
          DateTime createdDate = DateTime.fromMillisecondsSinceEpoch(
              sessionData['created'] * 1000);
          DateTime currentDate = DateTime.now();
          if (createdDate.year == currentDate.year &&
              createdDate.month == currentDate.month) {
            double amount = sessionData['amount_total'] / 100 as double;

            currentDaysOfMonth.update('DaysOfMonth', (value) => value + 1);

            totalDePagosEnFecha.update(
                'NumberOfPayments', (value) => value + 1);

            totalPorDia.update(
              'Valor',
              (existingAmount) => existingAmount + amount,
              ifAbsent: () => amount,
            );
          }
        }
      }
    }
  }

  return {
    'totalPorDia': totalPorDia,
    'totalDePagosEnFecha': totalDePagosEnFecha,
    'Days': currentDaysOfMonth
  };
}
