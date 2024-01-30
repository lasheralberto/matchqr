  // // void anyLinkGo() async {
  // //   if (prodNameController.text.isEmpty ||
  // //       prodDescController.text.isEmpty ||
  // //       anyLinkController.text.isEmpty) {
  // //     ScaffoldMessenger.of(context).showSnackBar(
  // //         const SnackBar(content: Text('Debes cumplimentar todos los campos')));
  // //   } else {
  // //     await addDataFirebase(
  // //         email: widget.email,
  // //         acc_dest_info: {'email': widget.email},
  // //         prod_name: prodNameController.text,
  // //         prod_desc: prodDescController.text,
  // //         pay_link: {'url': anyLinkController.text},
  // //         typeOfInsert: 'url',
  // //         qrStyle: qrStyle,
  // //         group: groupController.text);
  // //   }
  // // }


  //   void wifiGo(email, wifiName, groupName, wifiPass, wifiSec) async {
  //   if (prodNameController.text.isEmpty ||
  //       prodDescController.text.isEmpty ||
  //       _wifiSelected!.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Debes cumplimentar todos los campos')));
  //   } else {
  //     String qrStringWifi = 'WIFI:T:$wifiSec;S:$wifiName;P:$wifiPass';

  //     await addDataFirebase(
  //         email: email,
  //         acc_dest_info: {'email': email},
  //         prod_name: wifiName,
  //         prod_desc: wifiSec,
  //         pay_link: {'url': qrStringWifi},
  //         typeOfInsert: 'wifi',
  //         qrStyle: qrStyle,
  //         group: groupName);
  //   }
  // }

  //   Future<void> _generateExcel() async {
  //   var excel = exc.Excel.createExcel(); // Crea una nueva instancia de Excel
  //   exc.Sheet sheetObject = excel['Sheet1'];

  //   // Añade las columnas
  //   sheetObject.appendRow([
  //     const exc.TextCellValue('Nombre'),
  //     const exc.TextCellValue('Descripción'),
  //     const exc.TextCellValue('Url'),
  //     const exc.TextCellValue('Grupo'),
  //     const exc.TextCellValue('Estilo ojo'),
  //     const exc.TextCellValue('Rojo'),
  //     const exc.TextCellValue('Azul'),
  //     const exc.TextCellValue('Verde'),
  //   ]);
  //   sheetObject.appendRow([
  //     const exc.TextCellValue('Mi página web'),
  //     const exc.TextCellValue('QR para redirigir al usuario a mi web'),
  //     const exc.TextCellValue('www.myweb.com'),
  //     const exc.TextCellValue('Web'),
  //     const exc.TextCellValue('Redondo'),
  //     const exc.IntCellValue(254),
  //     const exc.IntCellValue(154),
  //     const exc.IntCellValue(71),
  //   ]);

  //   var fileBytes = excel.save(fileName: 'plantilla_qr1.xlsx');
  // }

    // void _formatNumber() {
  // //   String text = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
  // //   if (text.isNotEmpty) {
  // //     int value = int.tryParse(text) ?? 0;
  // //     String formattedText = NumberFormat.currency(
  // //       locale: "es_ES",
  // //       symbol: "",
  // //       decimalDigits: 2,
  // //     ).format(value / 100);

  // //     priceController.value = TextEditingValue(
  // //       text: formattedText,
  // //       selection: TextSelection.collapsed(offset: formattedText.length),
  // //     );
  // //   }
  // // }

  //   void precioFijoGo() async {
  //   String noCommas = priceController.text.replaceAll(',', '');
  //   var priceint = int.parse(noCommas);
  //   var accountStripe = await createAccountLink();

  //   // Update the state with the account onboarding URL
  //   setState(() {
  //     accountOnboardUrl = accountStripe['link_acc']['url'];
  //   });

  //   // Launch the URL for the user to complete account setup
  //   launchUrl(Uri.parse(accountOnboardUrl.toString()));

  //   // Check if the user has completed the onboarding
  //   var isOnboarded = await isInfoSubmitted(accountStripe['account']['id']);

  //   // If onboarding is complete, create a payment link

  //   if (isOnboarded == true) {
  //     var paylink = await createPayLink(
  //         widget.email,
  //         prodDescController.text,
  //         prodNameController.text,
  //         priceint, // Assuming this is a fixed amount
  //         accountStripe['account']['id'],
  //         false);

  //     await addDataFirebase(
  //         email: widget.email,
  //         pay_link: paylink['payLink'],
  //         acc_id: accountStripe,
  //         acc_dest_info: paylink['acc_info_dest'],
  //         prod_name: prodNameController.text,
  //         prod_desc: prodDescController.text,
  //         price: priceController.text,
  //         typeOfInsert: 'fixprice',
  //         qrStyle: qrStyle,
  //         group: groupController.text);
  //   }
  // }


// void _pickImage(context, StateSetter setState) async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     // Check if an image is picked
//     if (image != null) {
//       // Read the image as bytes
//       var file = File(image.path);
//     } else {
//       throw ('No se pudo subir la imagen');
//     }
//   }

//   void _showUploadOptions(BuildContext context, email) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Generación QR mediante fichero"),
//           content: const Text("Selecciona una acción"),
//           actions: <Widget>[
//             TextButton(
//               child: const Text("¿Cómo genero QR a través de Excel?"),
//               onPressed: () {
//                 //_generateExcel();
//                 _showUploadExcelPlantilla(context);
//               },
//             ),
//             TextButton(
//               child: const Text("Subir Excel"),
//               onPressed: () {
//                 // Implementar funcionalidad para subir Excel

//                 showLoadingDialog(context, pickAndLoadExcelUrl, email);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

  // void _showUploadExcelPlantilla(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Instrucciones para Subir Excel'),
  //         content: SingleChildScrollView(
  //           child: RichText(
  //             text: const TextSpan(
  //               style: TextStyle(
  //                   color: Colors.black,
  //                   fontSize: 16.0), // Estilo por defecto para todo el texto
  //               children: <TextSpan>[
  //                 TextSpan(
  //                     text:
  //                         'Para subir su archivo Excel y generar códigos QR, asegúrese de que el archivo sigue el formato del ejemplo mostrado. Cada fila debe contener:\n\n'),
  //                 TextSpan(
  //                     text: 'Columna 1  ',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 TextSpan(
  //                     text: 'Nombre: el nombre del producto o servicio.\n'),
  //                 TextSpan(
  //                     text: 'Columna 2  ',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 TextSpan(text: 'Descripción: una descripción corta.\n'),
  //                 TextSpan(
  //                     text: 'Columna 3  ',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 TextSpan(
  //                     text:
  //                         'URL/Referencia: la dirección web/referencia a la que el código QR dirigirá.\n'),
  //                 TextSpan(
  //                     text: 'Columna 4  ',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 TextSpan(
  //                     text:
  //                         'Grupo: la categoría o grupo al que pertenece el producto/servicio.\n'),
  //                 TextSpan(
  //                     text: 'Columna 5  ',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 TextSpan(
  //                     text:
  //                         "Estilo de Ojo: el estilo de QR, puede ser 'Cuadrado' o 'Redondo'.\n"),
  //                 TextSpan(
  //                     text: 'Columna 6  ',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 TextSpan(text: "Color Rojo RGB (Valor de 0 a 255) \n"),
  //                 TextSpan(
  //                     text: 'Columna 7  ',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 TextSpan(
  //                   text: 'Color Verde (Valor de 0 a 255) \n',
  //                 ),
  //                 TextSpan(
  //                     text: 'Columna 8  ',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 TextSpan(
  //                   text: 'Color Azul (Valor de 0 a 255) \n \n',
  //                 ),
  //                 TextSpan(
  //                     text:
  //                         'El nombre de las columnas no afecta, pero sí el orden. El contenido debe coincidir con estas especificaciones. Al tener su Excel listo, seleccione la opción de subida en la plataforma y su archivo se procesará automáticamente.'),
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Entendido'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }