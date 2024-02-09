import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class SidebarXCustom extends StatelessWidget {
  const SidebarXCustom({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      extendIcon: Icons.done,
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white, // Cambiado a blanco para un look más limpio
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: Colors.lightBlue[50], // Un azul claro muy suave para hover
        textStyle: const TextStyle(
          color: Colors.blueGrey, // Cambiado a azul grisáceo
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.blue, // Color azul para el texto seleccionado
          fontWeight: FontWeight.bold,
          fontSize: 18,
          decoration: TextDecoration.none, // Asegura que no haya subrayado
        ),

        itemTextPadding: const EdgeInsets.only(left: 20),
        //selectedItemTextPadding: const EdgeInsets.only(left: 20),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        iconTheme: const IconThemeData(
          color: Colors.blueGrey, // Cambiado a azul grisáceo
          size: 25,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.blue, // Cambiado a azul
          size: 25,
        ),
      ),

      footerDivider:
          const Divider(color: Colors.blueGrey), // Divider azul grisáceo
      items: const [
        SidebarXItem(
          icon: Icons.qr_code_sharp,
          label: '',
        ),
        SidebarXItem(
          icon: Icons.add_chart,
          label: '',
        ),
        // Añade más elementos según sea necesario
      ],
    );
  }
}
