//Importaciones externas
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:js' as js;
import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

//Importaciones locales
import 'package:payment_tool/functions.dart';
import 'package:payment_tool/constants.dart';

class QRCards extends StatefulWidget {
  String mail;
  int mode;
  QRCards({Key? key, required this.mail, required this.mode}) : super(key: key);

  @override
  State<QRCards> createState() => _QRCardsState();
}

class _QRCardsState extends State<QRCards> {
  //Create an instance of ScreenshotController
  GlobalKey repaintBoundaryKey = GlobalKey();
  Uint8List? _imageFile;
  final TextEditingController _groupController = TextEditingController();
  dynamic snapshotList;

  //filtros de grupo
  String? groupFilterSelected = 'All';
  bool? isFilteredGroup = false;

  bool isLoadingDownloadQR = false;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Tooltip(
              message: 'Filtrar por grupo',
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                      backgroundColor: AppColors.IconColor2,
                      foregroundColor: AppColors.IconColor),
                  onPressed: () {
                    //se actualiza el campo groupFilterSelected
                    _showFilterPopup(widget.mail);
                  },
                  child: Icon(Icons.filter_alt_rounded,
                      weight: 40.0,
                      color: ColorConstants.colorButtons,
                      size: 15),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 20.0),
              child: Tooltip(
                message: 'Eliminar todos los QR',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                      backgroundColor: AppColors.IconColor2),
                  onPressed: () async {
                    await deleteUsersWithEmail(
                        context, widget.mail, groupFilterSelected.toString());
                  },
                  child: const Icon(Icons.delete,
                      weight: 40.0, color: Colors.white, size: 15),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Tooltip(
              message: 'Descargar todos los QR',
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                      backgroundColor: AppColors.IconColor2),
                  onPressed: () async {
                    setState(
                      () => isLoadingDownloadQR = true,
                    );
                    await downloadAllQR(
                        widget.mail, groupFilterSelected.toString());

                    setState(
                      () => isLoadingDownloadQR = false,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.download,
                        weight: 40.0,
                        color: ColorConstants.colorButtons,
                        size: 15,
                      ),
                      if (isLoadingDownloadQR)
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Container(
        alignment: Alignment.center,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: StyleConstants.border,
          ),
          elevation: 20.0,
          color: AppColors.IconColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getDataFirestoreStream(widget.mail, groupFilterSelected!)
                  .asBroadcastStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  snapshotList = snapshot.data!.docs;

                  return LayoutBuilder(builder: (context, constr) {
                    var gridParams = calculateGridParameters(context, constr);

                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.5,
                      width: gridParams.width,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridParams.crossAxisCount,
                            childAspectRatio: gridParams.aspectRatio),
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];
                          var idDoc = doc.reference.id;
                          var payLinkUrl = doc['pay_link'];
                          var prodName = doc['prod_name'];
                          var prodDesc = doc['prod_desc'];
                          var eyeShape = selectedShapeQR[doc['qrStyle']['eye']];
                          var color = doc['qrStyle']['color'];
                          var colorConv = Color.fromRGBO(
                              color['red'], color['green'], color['blue'], 1.0);

                          var createdOn = doc['createdOn'].toDate();
                          var formattedDate =
                              DateFormat('dd/MM/yyyy').format(createdOn);

                          var group = doc['group'];

                          return Card(
                            color: ColorConstants.colortheme,
                            shape: RoundedRectangleBorder(
                              borderRadius: StyleConstants.border,
                            ),
                            elevation: 1.1,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                      onPressed: () {
                                        _modificarGrupo(idDoc, group);
                                      },
                                      icon: const Icon(
                                        Icons.add_to_photos_sharp,
                                        size: 15,
                                        color: AppColors.IconColor,
                                      )),
                                ),
                                Text(prodName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(
                                  height: 5,
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      _showQRpopup(
                                          prodName,
                                          payLinkUrl,
                                          prodName,
                                          prodDesc,
                                          group,
                                          eyeShape,
                                          colorConv,
                                          formattedDate,
                                          idDoc);
                                    },
                                    child: QrImageView(
                                      size: 200.0,
                                      data: payLinkUrl,
                                      embeddedImageStyle: QrEmbeddedImageStyle(
                                          size: StyleConstants.logoQrSize),
                                      embeddedImage: AssetImage(
                                          AssetsImages.tennisLogoBall),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape:
                                            QrDataModuleShape.square,
                                        color: colorConv,
                                      ),
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape,
                                        color: colorConv,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(group),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  });
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.height / 4,
                        child: Image.asset(
                          AssetsImages.noDataQrBackground,
                        ),
                      ),
                      Text(TextFieldsTexts.nodataQR,
                          style: TextStyle(color: ColorConstants.colorTexts))
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    ]);
  }

  void savePngLocally(content) {
    const fileName = 'example.png'; // Specify the desired file name

    // Call the JavaScript function
    js.context.callMethod('saveFile', [fileName, content]);
  }

  void saveAsFileBulk(bytes, String fileName) {
    // Create a Blob from the bytes
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<ByteData?> _addWhiteBackground(ui.Image image) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(recorder);

    // Ajustar el tamaño del Canvas para que coincida con el tamaño de la imagen
    ui.Size size = ui.Size(image.width.toDouble(), image.height.toDouble());

    // Dibujar un fondo blanco
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      ui.Paint()..color = Colors.white,
    );

    // Dibujar la imagen encima del fondo blanco
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());

    // Convertir el Canvas en una imagen
    final ui.Image finalImage = await recorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData;
  }

  Future<Uint8List> captureSingleWidget(GlobalKey key) async {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await _addWhiteBackground(image);
    return byteData!.buffer.asUint8List();
  }

  Future<void> captureAndStoreImages(List<DocumentSnapshot> documents) async {
    List<Uint8List> images = [];

    for (var doc in documents) {
      GlobalKey key =
          GlobalKey(); // Replace with your actual GlobalKey for each widget
      Uint8List pngBytes = await captureSingleWidget(key);
      images.add(pngBytes);
    }

    // Now images list contains all the captured images
    // Next step is to zip these images
    await createAndSaveZipFile(images);
  }

  Future<void> createAndSaveZipFile(images) async {
    Archive archive = Archive();

    for (int i = 0; i < images.length; i++) {
      // Add each image to the archive
      ArchiveFile file =
          ArchiveFile('image_$i.png', images[i].length, images[i]);
      archive.addFile(file);
    }

    // Encode the archive as a ZIP
    List<int>? zipBytes = ZipEncoder().encode(archive);

    // Save the ZIP file
    saveAsFileBulk(zipBytes, 'images.zip');
  }

  Future<Uint8List> captureAndSaveWidget() async {
    RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await _addWhiteBackground(image);
    //ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;

    // Continue to Step 3 to save the file
  }

  void _showFilterPopup(String userEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StreamBuilder<List<String>>(
            stream: getDataGroups(userEmail),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No groups found');
              }

              snapshot.data!.sort((a, b) => a.compareTo(b));

              // Si hay datos disponibles, se muestran en el DropdownSearch
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      disabledItemFn: (String s) => s.startsWith(' '),
                    ),
                    items: snapshot.data as List<String>,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Filtra por grupo",
                        hintText: "Filtra por grupo",
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        groupFilterSelected = v;
                        isFilteredGroup = true;
                      });
                    },
                    selectedItem: groupFilterSelected == 'All'
                        ? snapshot.data!.first
                        : groupFilterSelected,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          groupFilterSelected = 'All';
                        });
                      },
                      icon: const Icon(Icons.filter_alt_off_rounded))
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _modificarGrupo(idDoc, group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar grupo'),
          content: TextFormField(
            //initialValue: group,
            controller: _groupController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Editar'),
              onPressed: () async {
                // Aquí manejas la lógica de 'Submit'
                bool isEditedGroup = await editGroupQRDoc(
                    widget.mail, idDoc, _groupController.text);
                if (isEditedGroup) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Grupo actualizado')));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Error')));
                }
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  void _showQRpopup(title, data, prodName, prodDesc, group, eyeShape, colorConv,
      createdOn, idDoc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Center(child: Text(title)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width / 2,
                  child: Center(
                    child: Align(
                      alignment: Alignment.center,
                      child: RepaintBoundary(
                        key: repaintBoundaryKey,
                        child: Card(
                          elevation: 0,
                          borderOnForeground: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text(prodName), Text(prodDesc)],
                              ),
                              QrImageView(
                                size: 200.0,
                                data: data,
                                embeddedImageStyle: QrEmbeddedImageStyle(
                                    size: StyleConstants.logoQrSize),
                                embeddedImage:
                                    AssetImage(AssetsImages.tennisLogoBall),
                                dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: colorConv,
                                ),
                                eyeStyle: QrEyeStyle(
                                  eyeShape: eyeShape,
                                  color: colorConv,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ListTile(
                    //title: Text(prodName),
                    subtitle: ListTile(
                      title: Text(group),
                      subtitle: Row(
                        children: [
                          const Text('Creado:'),
                          Text(createdOn),
                        ],
                      ),
                    ),
                  ),
                ),

                // Add more widgets here
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  var pngBytes = await captureAndSaveWidget();
                  savePngLocally(pngBytes);
                  //saveAsFile(pngBytes, '$prodName.png');
                },
                style: ButtonStyle(
                    alignment: Alignment.center,
                    backgroundColor:
                        MaterialStateProperty.all(ColorConstants.colorButtons)),
                child: const Icon(
                  Icons.save_alt_outlined,
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  tooltip: 'Borrar QR',
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)),
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // Lógica para borrar el documento de Firestore
                    var isDeleted = await deleteDocument(widget.mail, idDoc);
                    if (isDeleted == true) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}

class GridParameters {
  final int crossAxisCount;
  final double width;
  final double aspectRatio;

  GridParameters(
      {required this.crossAxisCount,
      required this.width,
      required this.aspectRatio});
}

GridParameters calculateGridParameters(
    BuildContext context, BoxConstraints constr) {
  var screenWidth = MediaQuery.of(context).size.width;

  // Calculate dynamicWidth
  var maxBreakpoint = screenWidth / 2;
  var widthFactor = screenWidth < maxBreakpoint
      ? 0.7 + (maxBreakpoint - screenWidth) / screenWidth
      : 0.6;
  var dynamicWidth = math.min(screenWidth * widthFactor, constr.maxWidth);

  // Calculate crossAxisCount
  int crossAxisCount;
  if (screenWidth < 600) {
    crossAxisCount = 1;
  } else if (screenWidth < 800) {
    crossAxisCount = 2;
  } else if (screenWidth < StyleConstants.mobileSize) {
    crossAxisCount = 3;
  } else {
    crossAxisCount = 4;
  }

  // Calculate width and aspectRatio
  var crossAxisSpacing = 8.0;
  var cellWidth = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
      crossAxisCount;
  var cellHeight = 600.0;
  var aspectRatio = cellWidth / cellHeight;

  return GridParameters(
      crossAxisCount: crossAxisCount,
      width: dynamicWidth,
      aspectRatio: aspectRatio);
}
