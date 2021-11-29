// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unused_local_variable

import 'dart:convert';

import 'package:cloud_photo_album/album_page.dart';
import 'package:cloud_photo_album/photo_page.dart';
import 'package:cloud_photo_album/provider/google_sing_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Variables
    int rootFolderId;

    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (streamSnapshot.hasData) {
            User user = streamSnapshot.data as User;
            UserInfo userInfo = user.providerData[0];
            // (Create user if doesn't exist and) Get user's root folder
            String userId = userInfo.uid!;
            String userEmail = userInfo.email!;
            print(userId);

            return FutureBuilder(
                future: getRootFolder(userId, userEmail),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState == ConnectionState.done) {
                    print('Future: ${futureSnapshot.data}'); // DBUG
                    rootFolderId = (futureSnapshot.data as int);
                    return AlbumPage(
                      userId: userId,
                      currentFolderId: rootFolderId,
                      isRootFolder: true,
                    );
                  } else if (futureSnapshot.hasError) {
                    return Text('Error while loading root folder');
                  } else {
                    return Scaffold(
                      backgroundColor: Colors.amber[50],
                      appBar: AppBar(
                        actions: [
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: GestureDetector(
                              onTap: () {
                                print('hello');
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 1.0),
                                    child: Text(
                                      'New',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: GestureDetector(
                              onTap: () {},
                              child: TextButton(
                                  onPressed: () {
                                    final provider =
                                        Provider.of<GoogleSignInProvider>(
                                            context,
                                            listen: false);
                                    provider.logout();
                                  },
                                  child: Text(
                                    'Log out',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  )),
                            ),
                          ),
                        ],
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.transparent,
                      ),
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                });
          } else {
            return buildlogin(context);
          }
        },
      ),
    );
  }

  // Methods
  Future<int> getRootFolder(userId, userEmail) async {
    print('userId: $userId'); // DBUG
    var url = Uri.parse(
        'http://photoalbumapi-env.eba-z3bpuujp.us-east-1.elasticbeanstalk.com/user?userId=$userId&email=$userEmail');
    print('URL: $url'); // DBUG
    Response response = await get(url);
    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      print('success: $body'); // DBUG
      return body["folderId"];
    } else {
      print('Error retrieving folder ID, statusCode: ${response.statusCode}');
      return -1;
    }
  }

  Widget buildlogin(context) {
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
                      Provider.of<GoogleSignInProvider>(context, listen: false);
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
        // SizedBox(
        //   height: 10.0,
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     ElevatedButton(
        //       style: ButtonStyle(
        //           alignment: Alignment.center,
        //           minimumSize: MaterialStateProperty.all(Size(300.0, 50.0)),
        //           backgroundColor: MaterialStateProperty.all(
        //               Color.fromARGB(255, 20, 120, 243))),
        //       onPressed: () {
        //         Navigator.of(c).push(MaterialPageRoute(
        //             builder: (context) => AlbumPage(
        //                   currentFolderId: 1,
        //                 )));
        //       },
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Padding(
        //             padding: EdgeInsets.symmetric(vertical: 10.0),
        //             child: Image.asset(
        //               'assets/facebook_logo.jpg',
        //               height: 30.0,
        //             ),
        //           ),
        //           Padding(
        //             padding: EdgeInsets.only(left: 10.0),
        //             child: Text(
        //               'Sign up with Facebook',
        //               style: TextStyle(color: Colors.white),
        //             ),
        //           )
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(
        //   height: 10.0,
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [],
        // ),
      ],
    );
  }
}
