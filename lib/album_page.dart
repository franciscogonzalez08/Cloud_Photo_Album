// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                print('Clicked'); // DBUG
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
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Log out',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Cloud Photo Album',
          textAlign: TextAlign.left,
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TODO: Implement search field
          // Row(
          //   children: [
          //     Text('data')
          //   ],
          // ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(9, (index) {
                return Container(
                  margin: EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.network('https://picsum.photos/150'),
                        Container(
                          color: Colors.white70,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            'Image.png',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
