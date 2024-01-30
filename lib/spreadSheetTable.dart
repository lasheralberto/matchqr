import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'dart:js' as js;

import 'package:excel/excel.dart';
import 'package:payment_tool/functions.dart';

class MyData {
  String name;
  String descr;
  String url;
  String group;
  String style;
  int red;
  int green;
  int blue;
  int alpha;

  MyData(
      {required this.name,
      required this.url,
      required this.descr,
      required this.group,
      required this.style,
      required this.red,
      required this.green,
      required this.blue,
      required this.alpha});
}

Future<bool> pickAndLoadExcelUrl(email, context) async {
  final html.FileUploadInputElement input = html.FileUploadInputElement()
    ..multiple = false
    ..accept = '.xlsx,.xls';

  String? safeToString(dynamic value) {
    return value?.toString();
  }

  input.onChange.listen((e) async {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        final data = reader.result as String;
        final bytes = base64.decode(data.split(",").last);
        var excel = Excel.decodeBytes(bytes);

        // Process your excel file here
        for (var table in excel.tables.keys) {
          bool isFirstRow = true;
          for (var row in excel.tables[table]!.rows) {
            if (row.isEmpty) {
              continue;
            }
            if (isFirstRow) {
              isFirstRow = false;
            } else {
              try {
                var prodName = safeToString(row[0]?.value);
                var prodDesc = safeToString(row[1]?.value);
                var url = safeToString(row[2]?.value);
                var group = safeToString(row[3]?.value);
                var eyestyle = safeToString(row[4]?.value);

                // For parsing integers, make sure the value is not null and is a valid integer
                int red, blue, green;
                if (row[5]?.value != null) {
                  red = int.tryParse(row[5]!.value.toString()) ??
                      0; // default value on parse failure
                } else {
                  red = 0;
                }

                if (row[6]?.value != null) {
                  blue = int.tryParse(row[6]!.value.toString()) ?? 0;
                } else {
                  blue = 0;
                }
                if (row[7]?.value != null) {
                  green = int.tryParse(row[7]!.value.toString()) ?? 0;
                } else {
                  green = 0;
                }

                var data = {
                  'email': email,
                  'acc_dest_info': {'email': email},
                  'prod_name': prodName,
                  'prod_desc': prodDesc,
                  'pay_link': {'url': url},
                  'group': group,
                  'type': 'url',
                  'qrStyle': {
                    'color': {
                      'red': red,
                      'blue': blue,
                      'green': green,
                      'alpha': 255
                    },
                    'eye': eyestyle

                    // Add other fields for qrStyle if necessary
                  },
                  // ... other fields ...
                };

                // Call the function to add data to Firebase
                addDataFirebase(
                    email: data['email'],
                    pay_link: data['pay_link'],
                    acc_id: null, // Replace with actual account ID
                    acc_dest_info: {
                      'email': data['email']
                    }, // Replace with actual account destination info
                    prod_name: data['prod_name'],
                    prod_desc: data['prod_desc'],
                    price: null, // Replace with actual price
                    typeOfInsert: 'url', // Replace with actual type of insert
                    qrStyle: data['qrStyle'],
                    group: data['group']
                    // Add other parameters as necessary
                    );

                // Rest of your code here
              } catch (e) {
                // Log the error
                print(e);
              }
            }
          }
        }
      });
    }
  });

  input.click();
  bool isLoaded = true;
  return isLoaded;
}

void showPopup(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}

void showPrivacyPopUp(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: <Widget>[
          ElevatedButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}


// ... Your other imports and code ...

// Call this function when you want to show the dialog
Future<void> showLoadingDialog(
    BuildContext context,
    Future<bool> Function(String, dynamic) pickAndLoadExcelUrl,
    String email) async {
  // Start the loading process
  showDialog(
    context: context,
    barrierDismissible: false, // User must tap button to close the dialog
    builder: (BuildContext dialogContext) {
      return const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(), // The loading indicator
            SizedBox(height: 20), // For spacing
            Text('Loading... Please wait.'),
          ],
        ),
      );
    },
  );

  // Perform the loading operation
  bool isLoaded = await pickAndLoadExcelUrl(email, context);

  // Once loading is complete, close the dialog
  Navigator.of(context, rootNavigator: true).pop('dialog');

  // You can now proceed with your application's workflow
  if (isLoaded) {
    // Handle successful loading
  } else {
    // Handle loading failure
  }
}

Future<dynamic> uploadExcelFile() async {
  // Add your function code here!
  try {
    // Open the file picker to allow the user to select an Excel
    void callUploadFunction() {
      js.context.callMethod('uploadExcelFile');
    }
  } catch (e) {
    return null;
  }
}
