import 'package:flutter/material.dart';
import 'package:payment_tool/functions.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKeyContact = GlobalKey<FormState>();
  final String _name = '';
  String _email = '';
  String _message = '';

  TextEditingController? nameController;
  TextEditingController? messageController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(); // Initialize the controller

    messageController = TextEditingController(); // Initialize the controller
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKeyContact,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                    'Déjanos tu mensaje y trataremos de darte respuesta lo más pronto posible. ¡Gracias!'),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Correo Electrónico'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce tu correo electrónico';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!,
                ),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Mensaje'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce tu mensaje';
                    }
                    return null;
                  },
                  onSaved: (value) => _message = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Color de fondo
                    foregroundColor: Colors.grey, // Color al presionar
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Borde redondeado
                    ),
                    elevation: 5, // Sombra del botón
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKeyContact.currentState!.validate()) {
                      _formKeyContact.currentState!.save();
                      // Aquí puedes manejar la lógica de envío del formulario
                      // Por ejemplo, enviar los datos a un servidor
                      await formularioContactoAdd(
                          nameController!.text, messageController!.text);

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Formulario Enviado'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
