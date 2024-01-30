import 'package:flutter/material.dart';
import 'package:payment_tool/main.dart';

import 'constants.dart';

class RecoverPassWidget extends StatefulWidget {
  RecoverPassWidget({Key? key}) : super(key: key);

  @override
  State<RecoverPassWidget> createState() => _RecoverPassWidgetState();
}

class _RecoverPassWidgetState extends State<RecoverPassWidget> {
  final GlobalKey<FormState> _formKeyRecover = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool? _success = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: StyleConstants.border,
      ),
      elevation: 20,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: AppColors.IconColor2,
          borderRadius: StyleConstants.border,
        ),
        child: Card(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LoginConstants.passRecover,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKeyRecover,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration:
                            InputDecoration(labelText: LoginConstants.emailBox),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return LoginConstants.enterSomeText;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 20.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: StyleConstants.border),
                            backgroundColor:
                                AppColors.IconColor, // Transparent background
                            padding: const EdgeInsets.all(
                                16.0), // Adjust button size
                          ),
                          onPressed: () async {
                            await authFirebase
                                .sendPasswordResetEmail(
                                    email: _emailController.text)
                                .then((value) {
                              setState(() {
                                _success = true;
                              });
                            });
                          },
                          child: Text(
                            LoginConstants.emailBox,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(_success == null
                          ? ''
                          : (_success == true
                              ? LoginConstants.recoverPassSent
                              : '')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
