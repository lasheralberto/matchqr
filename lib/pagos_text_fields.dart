// Importaciones del sistema Dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:payment_tool/HomePageDesktop.dart';
import 'package:payment_tool/constants.dart';

class PagosTextFields extends StatefulWidget {
  final TextEditingController prodNameController;
  final TextEditingController prodDescController;
  final TextEditingController groupController;

  String email;

  PagosTextFields(
      {Key? key,
      required this.email,
      required this.prodNameController,
      required this.prodDescController,
      required this.groupController})
      : super(key: key);

  @override
  State<PagosTextFields> createState() => _PagosTextFieldsState();
}

class _PagosTextFieldsState extends State<PagosTextFields> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController newgroupController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 400,
          child: TextField(
            minLines: 1,
            maxLines: 40,
            controller: widget.prodNameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white60,
              labelText: TextFieldsTexts.IntroTextField,
              border: OutlineInputBorder(
                borderRadius: StyleConstants.border,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 400,
          child: TextField(
            minLines: 1,
            maxLines: 3,
            controller: widget.prodDescController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white60,
              labelText: TextFieldsTexts.IdeaTextField,
              border: OutlineInputBorder(
                borderRadius: StyleConstants.border,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users_paylinks')
                .doc(widget.email)
                .collection('qrCodes')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData) {
                return const Text("No hay datos disponibles");
              }

              // Extracción de la lista de grupos
              List<String?> grupos = snapshot.data!.docs
                  .map((doc) =>
                      (doc.data() as Map<String, dynamic>)['group'] as String?)
                  .where((group) => group != null) // Filtrar nulos
                  .toSet() // Eliminar duplicados
                  .toList();

              String?
                  selectedGroup; // Variable para almacenar el grupo seleccionado

              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 3,
                      controller: widget.groupController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white60,
                        labelText: "Grupo",
                        border: OutlineInputBorder(
                            borderRadius: StyleConstants.border),
                        suffixIcon: PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              selectedGroup = value;
                              widget.groupController.text = value;
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return grupos.map((choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice.toString()),
                              );
                            }).toList();
                          },
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}
