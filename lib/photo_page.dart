// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, unused_local_variable
import 'package:image_picker/image_picker.dart';
// import 'package:uri_to_file/uri_to_file.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
// import 'package:multi_image_picker/multi_image_picker.dart';

class PhotoPage extends StatefulWidget {
  final String userId;
  final int folderId;
  PhotoPage({Key? key, required this.userId, required this.folderId})
      : super(key: key);

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  // Variables
  List<File> arrImages = [];
  // List<Asset> images = [];
  // bool? includeLocation = false;
  // List photoTags = [Item(title: 'Hello')];

  // Some variables for Tags widget
  // final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();

  // Methods
  upload(File imageFile) async {
    print('URI: ${imageFile.uri}');
    // open a bytestream
    var stream = ByteStream(imageFile.openRead());
    stream.cast();
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("http://3.236.222.168:3000/image");

    // create multipart request
    var request = MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = MultipartFile('file', stream, length,
        filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);

    request.fields['name'] = basename(imageFile.path);
    request.fields['userId'] = widget.userId;
    request.fields['folderId'] = '${widget.folderId}';
    request.fields['tags'] = '[]';

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  Future<void> _getImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      arrImages.add(File(pickedImage.path));
    } else {
      print('Error while picking image');
    }
  }

  // Pick image
  // Future<void> _getImages() async {
  //   try {
  //     images = await MultiImagePicker.pickImages(
  //       maxImages: 300,
  //       enableCamera: false,
  //       materialOptions: MaterialOptions(
  //         actionBarTitle: "Cloud photo Album",
  //       ),
  //     );
  //   } on Exception catch (e) {
  //     print('Error at get images: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double width = MediaQuery.of(context).size.width;
    double height =
        MediaQuery.of(context).size.height - padding.top - padding.bottom;
    double vw = width / 100;
    double vh = height / 100;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Upload'),
      ),
      body: Padding(
        padding: EdgeInsets.all(height * 0.02),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity,
                      40.0), // height size is fixed cause font size is fixed too
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  primary: Colors.white30,
                ),
                onPressed: () async {
                  await _getImage();
                  setState(() {});
                  // Upload images to S3 Bucket
                },
                child: Text(
                  'Choose images',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: vh * 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${arrImages.length} images selected',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                  itemCount: arrImages.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    print('Images length at builder: ${arrImages.length}');
                    return ListTile(
                      leading: Icon(Icons.camera),
                      title: Text(arrImages[index].path),
                    );
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width / 2,
                      40.0), // height size is fixed cause font size is fixed too
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  primary: Colors.white30,
                ),
                onPressed: arrImages.isEmpty
                    ? null
                    : () async {
                        // Upload images to S3 Bucket

                        for (File imgFile in arrImages) {
                          await upload(imgFile);
                          // String base64Image =
                          //     base64Encode(imgFile.readAsBytesSync());

                          // var url =
                          //     Uri.parse('http://3.236.222.168:3000/image');
                          // var img = {
                          //   "name": imgFile.path,
                          //   "userId": widget.userId,
                          //   "folderId": widget.folderId,
                          //   "tags": '[]',
                          //   "file": base64Image
                          // };

                          // Response response = await post(url,
                          //     headers: {'Content-Type': 'multipart/form-data'},
                          //     body: jsonEncode(img));
                          // if (response.statusCode == 200) {
                          //   print('image uploaded');
                          // } else {
                          //   print('error');
                          //   print(response.statusCode);
                          // }

                          // String fileExtension = imgFile.path.substring(
                          //   imgFile.path.lastIndexOf('.') + 1,
                          // );

                          //  MultipartRequest request =
                          //     MultipartRequest('POST', url);
                          // request.files.add(
                          //   MultipartFile.fromBytes(
                          //     'file',
                          //     await File.fromUri(Uri.parse(imgFile.path))
                          //         .readAsBytes(),
                          //     contentType: MediaType('image', fileExtension),
                          //   ),
                          // );

                          // request.fields['name'] = imgFile.path;
                          // request.fields['userId'] = widget.userId;
                          // request.fields['folderId'] = '${widget.folderId}';
                          // request.fields['tags'] = '[]';

                          // try {
                          //   StreamedResponse response = await request.send();
                          //   print(response.statusCode);
                          // } catch (e) {
                          //   print('Error: $e');
                          // }
                        }
                        print('uploading');

                        // for (var img in images) {
                        //   var imgAsBytes = await img.getByteData();

                        //   var url = Uri.parse(
                        //       'http://photoalbumapi-env.eba-z3bpuujp.us-east-1.elasticbeanstalk.com/image');

                        //   String fileExtension = img.name!.substring(
                        //     img.name!.lastIndexOf('.') + 1,
                        //   );

                        //   final buffer = imgAsBytes.buffer;

                        // //String uriString = img.identifier!;
                        // //Uri uri = Uri.parse(uriString);
                        // //print('About to use package...');
                        //// var newImage = Image.file(img);
                        //   print('About to add file...');
                        //   MultipartRequest request =
                        //       MultipartRequest('POST', url);
                        //   request.files.add(
                        //     MultipartFile.fromBytes(
                        //       'file',
                        //       buffer.asUint8List(imgAsBytes.offsetInBytes,
                        //           imgAsBytes.lengthInBytes),
                        //       contentType: MediaType('image', fileExtension),
                        //     ),
                        //   );

                        //   request.fields['name'] = img.name!;
                        //   request.fields['userId'] = widget.userId;
                        //   request.fields['folderId'] = '${widget.folderId}';
                        //   request.fields['tags'] = '[]';
                        //   print(request.files[0].filename);

                        //   print('About to do request...');
                        //   try {
                        //     StreamedResponse response = await request.send();
                        //     print(response.statusCode);
                        //     print(response.stream);
                        //   } catch (e) {
                        //     print('Error: $e');
                        //   }

                        //   // Response response = await post(url,
                        //   //     headers: {
                        //   //       'Content-Type': 'multipart/form-data',
                        //   //     },
                        //   //     body: jsonEncode(image));
                        //   // if (response.statusCode == 200) {
                        //   //   print('image ${img.name} created');
                        //   // } else {
                        //   //   print(
                        //   //       'Error uploading image #${img.name}, statusCode: ${response.statusCode}');
                        //   // }
                        // }
                      },
                child: Text(
                  'Upload images',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Text('Include location'),
              //     Checkbox(
              //       onChanged: (bool? value) {
              //         setState(() {
              //           includeLocation = value;
              //         });
              //       },
              //       value: includeLocation,
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: vh * 1,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     // Text('Tags:'),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
