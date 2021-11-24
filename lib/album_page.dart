// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_const_constructors_in_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class AlbumPage extends StatefulWidget {
  final int currentFolderId;
  AlbumPage({Key? key, required this.currentFolderId}) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  // Variables
  var textController = TextEditingController();
  List userFolders = [];
  List userImages = [];
  String currentFolderName = '';

  // Methods
  Widget createFolder(folder, context, width) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        IconButton(
          iconSize: (width - 30.0) / 3,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AlbumPage(
                  currentFolderId: folder["folderId"],
                ),
              ),
            );
          },
          icon: Icon(
            Icons.folder,
          ),
        ),
        Container(
          margin: EdgeInsets.all(5.0),
          child: Text(
            '${folder["name"]}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget createImage(image) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: Image.network(
                  '${image["url"]}',
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage('${image["thumbnailUrl"]}'),
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0),
            ),
          ),
          child: Text(
            '${image["name"]}',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  getFolderData() async {
    var url = Uri.parse(
        'http://10.0.2.2:3000/folder?folderId=${widget.currentFolderId}'); // https://es.stackoverflow.com/questions/345783/se-produjo-una-excepci%C3%B3n-socketexception-socketexception-os-error-connection
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      userFolders = body['folders'];
      userImages = body['images'];
      currentFolderName = body['folderName'];
    } else {
      print('Error retrieving data, statusCode: ${response.statusCode}');
    }
  }

  List<Widget> renderUserData(context, width) {
    List<Widget> userData = [];
    // Create folders
    for (var folder in userFolders) {
      userData.add(createFolder(folder, context, width));
    }
    // Create images
    for (var image in userImages) {
      userData.add(createImage(image));
    }
    return userData;
  }

  String dropdownValue = 'View: Grid';

  @override
  Widget build(BuildContext context) {
    // Get view size
    EdgeInsets padding = MediaQuery.of(context).padding;
    double width = MediaQuery.of(context).size.width;
    double height =
        MediaQuery.of(context).size.height - padding.top - padding.bottom;
    double vw = width / 100;
    double vh = height / 100;

    return FutureBuilder(
        future: getFolderData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: Colors.amber[50],
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading:
                    widget.currentFolderId == 1 // !This might change later on
                        ? null
                        : BackButton(onPressed: () {
                            Navigator.maybePop(
                                context); // not sure of how it's different to pop(), but it says 'leading' uses this by default
                          }),
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          )),
                    ),
                  ),
                ],
                backgroundColor: Colors.transparent,
                title: widget.currentFolderId == 1
                    ? Text(
                        'Cloud photo Album',
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        currentFolderName,
                        textAlign: TextAlign.center,
                      ),
              ),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 30.0,
                          child: TextField(
                            controller: textController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(2.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.grey,
                              )),
                              hintText: 'Search',
                              prefixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  print(
                                      'Searching'); // TODO: Implement filter by name
                                },
                                icon: Icon(
                                  Icons.search,
                                ),
                              ),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  textController.clear();
                                },
                                icon: Icon(
                                  Icons.clear,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.filter_alt,
                          ),
                        ),
                        DropdownButton(
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          elevation: 16,
                          value: dropdownValue,
                          items: <String>[
                            'View: Grid',
                            'View: List',
                            'View: Map'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: renderUserData(context, width),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error while loading user data');
          } else {
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
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
  }
}
