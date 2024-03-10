import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:payment_tool/constants.dart';

class FilterChipsGroups extends StatefulWidget {
  final String userEmail;
  Function(String group)? onGroupSelected;
  FilterChipsGroups(
      {Key? key, required this.userEmail, required this.onGroupSelected})
      : super(key: key);

  @override
  State<FilterChipsGroups> createState() => _FilterChipsGroupsState();
}

class _FilterChipsGroupsState extends State<FilterChipsGroups> {
  String? selectedGroup;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.height * 0.5,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users_paylinks')
                .doc(widget.userEmail)
                .collection('qrCodes')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Cargando..'));
              }
        
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay grupos disponibles.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
        
              var groups = snapshot.data!.docs
                  .map((doc) => doc['group'] as String)
                  .toSet()
                  .toList();
              groups.add('Todos los grupos');
        
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: StyleConstants.border // Esquinas redondeadas
                        ),
                    color: AppColors.IconColor3,
                    // elevation: StyleConstants.elevation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: groups.map((group) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FilterChip(
                            label: Text(
                              group == '' ? 'Sin grupo' : group,
                              style: TextStyle(
                                fontWeight: group == selectedGroup
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: group == selectedGroup
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: group == selectedGroup,
                            selectedColor: AppColors.IconColor2,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedGroup = selected ? group : null;
                              });
                              if (selected) {
                                widget.onGroupSelected!(group);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
