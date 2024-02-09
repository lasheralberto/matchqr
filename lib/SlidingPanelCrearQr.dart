import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:payment_tool/HomePageDesktop.dart';
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/functions.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pagos_text_fields.dart';

class SlidingPanelQR extends StatefulWidget {
  var email;
  var prodNameController;
  var prodDescControlller;
  var groupController;

  SlidingPanelQR(
      {Key? key,
      required this.email,
      required this.prodNameController,
      required this.prodDescControlller,
      required this.groupController})
      : super(key: key);

  @override
  State<SlidingPanelQR> createState() => _SlidingPanelQRState();
}

class _SlidingPanelQRState extends State<SlidingPanelQR> {
  String _selectedShape = shapesQR[0];
  final String _selectedShapeData = shapesQR[0];
  var qrStyle;
  Color mycolor = Colors.black;
  String? accountOnboardUrl;
  bool _qrLoading = false;

  dynamic addDataStyleQR() async {
    setState(() {
      qrStyle = {
        'eye': _selectedShape,
        'mainPoints': _selectedShapeData,
        //'img': urlImage,
        'color': {
          'red': mycolor.red,
          'green': mycolor.green,
          'blue': mycolor.blue,
          'alpha': mycolor.alpha
        }
      };
    });
  }

  Future<bool> createQRpayment() async {
    // Verificar los campos comunes primero
    if (widget.prodNameController.text.isEmpty ||
        widget.prodDescControlller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes cumplimentar todos los campos')),
      );
      return false; // Salir temprano si los campos comunes están vacíos
    } else {
      var _isAccCreated = await stripeConnectCheckout();
      return _isAccCreated;
    }

    // checkOutNormal(prodNameController.text, prodDescController.text, qrStyle, groupController.text);
  }

  void checkOutNormal(prodName, prodDesc, qrstyle, group) async {
    var checkOutInfo = await createPayLinkNormal(prodName);

    if (checkOutInfo.isNotEmpty) {
      await addDataFirebase(
          email: widget.email,
          pay_link: checkOutInfo['checkOutObject']['url'],
          acc_id: checkOutInfo['checkOutObject']['id'],
          acc_dest_info: '',
          prod_name: prodName,
          prod_desc: prodDesc,
          price: '',
          typeOfInsert: 'checkOutNormal',
          qrStyle: qrstyle,
          group: group);
    }
  }

  Future<bool> stripeConnectCheckout() async {
    var accountStripe = await createAccountLink();

    // Update the state with the account onboarding URL
    setState(() {
      accountOnboardUrl = accountStripe['link_acc']['url'];
    });

    // Launch the URL for the user to complete account setup
    await launchUrl(Uri.parse(accountOnboardUrl.toString()));

    // Check if the user has completed the onboarding
    var isOnboarded = await isInfoSubmitted(accountStripe['account']['id']);

    // If onboarding is complete, create a payment link
    if (isOnboarded == true) {
      var paylink = await createPayLink(
        widget.prodNameController.text,
        accountStripe['account']['id'],
      );

      await addDataFirebase(
          email: widget.email,
          pay_link: paylink['checkOutObject']['url'],
          acc_id: paylink['checkOutObject']['id'],
          acc_dest_info: paylink['acc_info_dest'],
          prod_name: widget.prodNameController.text,
          prod_desc: widget.prodDescControlller.text,
          price: "",
          typeOfInsert: 'stripeConnect',
          qrStyle: qrStyle,
          group: widget.groupController.text);

      return true;
    } else {
      return false;
    }
  }

  void _showShapeDialog(BuildContext context, StateSetter setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona una Forma'),
          content: DropdownButton<String>(
            value: _selectedShape,
            items: shapesQR.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedShape = newValue!;
                Navigator.of(context)
                    .pop(); // Cierra el diálogo después de seleccionar
              });
            },
          ),
        );
      },
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Personaliza tu QR'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: const Text('Elegir Color'),
                    onTap: () {
                      _showColorPickerDialog(context, setState);
                    },
                  ),
                  ListTile(
                    title: const Text('Elegir estilo "QR Eyes"'),
                    onTap: () {
                      _showShapeDialog(context, setState);
                    },
                  ),
                  // ListTile(
                  //   title: const Text('Elegir estilo "QR Data"'),
                  //   onTap: () {
                  //     _showShapeDataDialog(context, setState);
                  //   },
                  // ),
                  _buildQrView(context, setState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQrView(BuildContext context, StateSetter setState) {
    return SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.height / 4,
        child: Center(
          child: QrImageView(
            backgroundColor: Colors.transparent,
            data: 'Ejemplo 1234567890',
            embeddedImage: AssetImage(AssetsImages.tennisLogoBall),
            embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(30, 30)),
            eyeStyle: QrEyeStyle(
                color: mycolor, eyeShape: selectedShapeQR[_selectedShape]),
            dataModuleStyle: QrDataModuleStyle(color: mycolor),
          ),
        ));
  }

  void _showColorPickerDialog(BuildContext context, StateSetter setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escoge un color para tu QR.'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: mycolor,
              onColorChanged: (Color color) {
                setState(() {
                  mycolor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: LayoutBuilder(
            builder: (context, constr) {
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 600,
                              child: Card(
                                margin: const EdgeInsets.all(40),
                                color: ColorConstants.colorCard,
                                shape: RoundedRectangleBorder(
                                  borderRadius: StyleConstants
                                      .border, // Adjust the radius as needed
                                ),
                                elevation:
                                    30.0, // Add elevation for a card-like effect
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      //////////////////////////buttons for editing QR and mass generation
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              children: [
                                                const Text(
                                                    'Con tecnología de pagos de'),
                                                Image.asset(
                                                  AssetsImages.stripeLogo,
                                                  height: 70,
                                                  width: 100,
                                                )
                                              ],
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            label: Text(
                                              TextFieldsTexts.personalizarQR,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      FontSize.large.value),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      StyleConstants.border),
                                              backgroundColor:
                                                  AppColors.IconColor,
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                            ),
                                            onPressed: () =>
                                                _showOptionsDialog(context),
                                            icon: const Icon(
                                              Icons.style_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      //////////////////////////buttons for editing QR and mass generation

                                      const SizedBox(
                                        height: 10,
                                      ),
                                      PagosTextFields(
                                        email: widget.email,
                                        prodNameController:
                                            widget.prodNameController,
                                        prodDescController:
                                            widget.prodDescControlller,
                                        groupController: widget.groupController,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]);
            },
          ),
        ),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: StyleConstants.border),
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: AppColors.IconColor),
              onPressed: () async {
                addDataStyleQR();

                setState(() {
                  _qrLoading = true;
                });

                var _isQrCreated = await createQRpayment();

                setState(() {
                  _qrLoading = _isQrCreated == true ? false : true;
                });

                //si el usuario ha terminado el formulario --> True
              },
              label: Text(
                TextFieldsTexts.generarQR,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: FontSize.large.value),
              ),
              icon: _qrLoading == true
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(
                      Icons.qr_code_rounded,
                      color: Colors.white,
                    )),
        ),
      ],
    );
  }
}
