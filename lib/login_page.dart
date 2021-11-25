// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_photo_album/album_page.dart';
import 'package:cloud_photo_album/provider/google_sing_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return AlbumPage(
              currentFolderId: 1,
            );
          } else {
            return buildlogin(context);
          }
        },
      ),
    );
  }

  Widget buildlogin(c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 100.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100.0,
              backgroundImage:
                  AssetImage('assets/storage-in-the-cloud-g77adb3b78_1920.png'),
            ),
          ],
        ),
        SizedBox(
          height: 100.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ButtonStyle(
                  alignment: Alignment.center,
                  minimumSize: MaterialStateProperty.all(Size(300.0, 50.0)),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  final provider =
                      Provider.of<GoogleSignInProvider>(c, listen: false);
                  provider.googleLogin();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Image.asset(
                        'assets/google_logo.png',
                        height: 30.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Sign up with Google',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                )),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                  alignment: Alignment.center,
                  minimumSize: MaterialStateProperty.all(Size(300.0, 50.0)),
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 20, 120, 243))),
              onPressed: () {
                Navigator.of(c).push(MaterialPageRoute(
                    builder: (context) => AlbumPage(
                          currentFolderId: 1,
                        )));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Image.asset(
                      'assets/facebook_logo.jpg',
                      height: 30.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Sign up with Facebook',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
      ],
    );
  }
}
