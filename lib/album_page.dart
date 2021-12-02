// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_const_constructors_in_immutables, prefer_final_fields, prefer_typing_uninitialized_variables, avoid_print, unused_local_variable

import 'dart:convert';
import 'dart:io';

// import 'package:cloud_photo_album/map_page.dart';
import 'package:cloud_photo_album/photo_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'provider/google_sing_in.dart';

class AlbumPage extends StatefulWidget {
  final int currentFolderId;
  final bool isRootFolder;
  final String userId;
  AlbumPage(
      {Key? key,
      required this.currentFolderId,
      required this.isRootFolder,
      required this.userId})
      : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  @override
  void initState() {
    super.initState();
  }

  // Variables
  var textController = TextEditingController();
  var folderNameController = TextEditingController();
  List userFolders = [];
  List userImages = [];
  String currentFolderName = '';

  // Methods
  Widget createFolder(folder, context, width, userId) {
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
                  isRootFolder: false,
                  userId: userId,
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
                contentPadding: EdgeInsets.zero,
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
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

  Future<void> getFolderData() async {
    var url = Uri.parse(
        'http://photoalbumapi-env.eba-z3bpuujp.us-east-1.elasticbeanstalk.com/folder?folderId=${widget.currentFolderId}&userId=${widget.userId}');
    print('url: $url'); // DBUG
    Response response = await get(url);
    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      userFolders = body['folders'];
      userImages = body['images'];
      currentFolderName = body['folderName'];
    } else {
      print('Error retrieving data, statusCode: ${response.statusCode}');
    }
  }

  List<Widget> renderUserData(context, width, userId) {
    List<Widget> userData = [];
    // Create folders
    for (var folder in userFolders) {
      userData.add(createFolder(folder, context, width, userId));
    }
    // Create images
    for (var image in userImages) {
      userData.add(createImage(image));
    }
    return userData;
  }

  String girdViewDropdownValue = 'View: Grid';

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
                leading: widget.isRootFolder
                    ? null
                    : BackButton(onPressed: () {
                        Navigator.maybePop(
                            context); // not sure of how it's different to pop(), but it says 'leading' uses this by default
                      }),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: PopupMenuButton(
                        icon: Icon(
                          Icons.add,
                        ),
                        elevation: 20,
                        enabled: true,
                        onSelected: (value) async {
                          if (value == 'image') {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PhotoPage(
                                  userId: widget.userId,
                                  folderId: widget.currentFolderId,
                                ),
                              ),
                            );
                            setState(() {});
                          } else if (value == 'folder') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Create folder'),
                                content: TextField(
                                  controller: folderNameController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 20.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey,
                                    )),
                                    hintText: 'Folder name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Cancel');
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context, 'OK');

                                      var folder = {
                                        "name": folderNameController.text,
                                        "userId": widget.userId,
                                        "folderId": widget.currentFolderId
                                      };

                                      print(folder);

                                      var url = Uri.parse(
                                          'http://photoalbumapi-env.eba-z3bpuujp.us-east-1.elasticbeanstalk.com/folder');
                                      Response response = await post(url,
                                          headers: {
                                            'Content-Type':
                                                'application/json; charset=UTF-8',
                                          },
                                          body: jsonEncode(folder));
                                      if (response.statusCode == 200) {
                                        print('Folder created');
                                        setState(() {});
                                      } else {
                                        print(
                                            'Error creating folder, statusCode: ${response.statusCode}');
                                      }
                                    },
                                    child: Text('Create'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text("Create folder"),
                                value: "folder",
                              ),
                              PopupMenuItem(
                                child: Text("Upload image"),
                                value: "image",
                              ),
                            ]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: TextButton(
                          onPressed: () {
                            final provider = Provider.of<GoogleSignInProvider>(
                                context,
                                listen: false);
                            provider.logout();
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
                title: widget.isRootFolder
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
                                  // FocusScope.of(context)
                                  //     .requestFocus(FocusNode());
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
                              girdViewDropdownValue = newValue!;
                              if (girdViewDropdownValue == 'View: Map') {
                                print('Map not available');
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => MapPage(
                                //         currentFolderName: currentFolderName),
                                //   ),
                                // );
                              } else if (girdViewDropdownValue ==
                                  'View: Grid') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AlbumPage(
                                        currentFolderId: widget.currentFolderId,
                                        isRootFolder: widget.isRootFolder,
                                        userId: widget.userId),
                                  ),
                                );
                              }
                            });
                          },
                          elevation: 16,
                          value: girdViewDropdownValue,
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
                      children: renderUserData(context, width, widget.userId),
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
                automaticallyImplyLeading: false,
                leading: widget.isRootFolder
                    ? null
                    : BackButton(onPressed: () {
                        Navigator.maybePop(
                            context); // not sure of how it's different to pop(), but it says 'leading' uses this by default
                      }),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: PopupMenuButton(
                        icon: Icon(
                          Icons.add,
                        ),
                        elevation: 20,
                        enabled: true,
                        onSelected: (value) async {
                          if (value == 'image') {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PhotoPage(
                                  userId: widget.userId,
                                  folderId: widget.currentFolderId,
                                ),
                              ),
                            );
                            setState(() {});
                          } else if (value == 'folder') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Create folder'),
                                content: TextField(
                                  controller: folderNameController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 20.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey,
                                    )),
                                    hintText: 'Folder name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Cancel');
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context, 'OK');

                                      var folder = {
                                        "name": folderNameController.text,
                                        "userId": widget.userId,
                                        "folderId": widget.currentFolderId
                                      };

                                      print(folder);

                                      var url = Uri.parse(
                                          'http://photoalbumapi-env.eba-z3bpuujp.us-east-1.elasticbeanstalk.com/folder');
                                      Response response = await post(url,
                                          headers: {
                                            'Content-Type':
                                                'application/json; charset=UTF-8',
                                          },
                                          body: jsonEncode(folder));
                                      if (response.statusCode == 200) {
                                        print('Folder created');
                                      } else {
                                        print(
                                            'Error creating folder, statusCode: ${response.statusCode}');
                                      }
                                    },
                                    child: Text('Create'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text("Create folder"),
                                value: "folder",
                              ),
                              PopupMenuItem(
                                child: Text("Upload image"),
                                value: "image",
                              ),
                            ]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: TextButton(
                          onPressed: () {
                            final provider = Provider.of<GoogleSignInProvider>(
                                context,
                                listen: false);
                            provider.logout();
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
                title: widget.isRootFolder
                    ? Text(
                        'Cloud photo Album',
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        currentFolderName,
                        textAlign: TextAlign.center,
                      ),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
