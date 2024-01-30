 
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/cuadraditosLanding.dart';
import 'package:payment_tool/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  var title;
  bool hasTitle;

  CustomAppBar({
    super.key,
    required this.title,
    required this.hasTitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<dynamic> getUserPhoto() async {
    var user = authFirebase.currentUser;
    if (user != null) {
      return user.photoURL;
    }
  }

  Future<void> _signOut() async {
    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await authFirebase.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<dynamic> userPhoto = getUserPhoto();

    return AppBar(
      
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0))),
      actions: <Widget>[
        GestureDetector(
          onTap: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(
                  100, 100, 0, 0), // Adjust position as needed
              items: [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: Text(LoginConstants.logOut),
                    onTap: () async {
                      // Perform logout action here
                      // For example, you can add code to navigate to the login screen
                      //_signOut();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CuadraditosLanding()),
                          (route) => false);
                      //Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          },
          child: FutureBuilder(
            future: userPhoto,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage(snapshot.data), // Replace with your image
                  backgroundColor: Colors.grey, // Placeholder background color
                );
              } else {
                return CircleAvatar(
                  radius: 20, // Replace with your image
                  backgroundColor: Colors.grey,
                  child: Text(
                    authFirebase.currentUser!.email!.isNotEmpty
                        ? authFirebase.currentUser!.email!
                            .substring(0, 1)
                            .toUpperCase()
                        : '',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ), // Placeholder background color
                );
              }
            },
          ),
        ),
        const SizedBox(width: 16), // Adjust the width as needed
      ],

      toolbarHeight: 400.0,
      elevation: 20.0, // Remove the app bar shadow
      backgroundColor:
          ColorConstants.colorAppBar, // Set the background color to blue
      title: hasTitle ? Text(title) : null, // Remove the title
      // leading: Center(
      //   child: Container(
      //     height: 80,
      //     child: Image.asset(
      //       AssetsImages.AppBarInkWizLogo,
      //       fit: BoxFit.cover, // Adjust the fit as needed
      //     ),
      //   ),
      // ),
    );
  }
}
