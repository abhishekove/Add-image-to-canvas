import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image image;
  bool isImageloaded = false;
  File imageFile;
  void initState() {
    super.initState();
    init();
  }

  _openGallery(BuildContext context) async {
    var temp=await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.imageFile=temp;
      isImageloaded=false;
    });
    Future.delayed(new Duration(milliseconds: 500),(){
      init();
    });
    Navigator.of(context).pop();
  }
  _openCamera(BuildContext context)async{
    var temp=await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      isImageloaded=false;
      this.imageFile=temp;
    });
    init();
    Navigator.of(context).pop();
  }
  Future<void> _alertChoiceDialog(BuildContext context){
    return showDialog(context: context,builder: (BuildContext context){
      return AlertDialog(
        title: Text("Select Image"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              GestureDetector(
                child: Text("Gallery"),
                onTap: (){
                  _openGallery(context);
                  print("clicked");
                },
              ),
              SizedBox(height:20.0),
              GestureDetector(
                child: Text("Camera"),
                onTap: (){
                  _openCamera(context);
                },
              )
            ],
          ),
        ),
      );
    });
  }
  Future <Null> init() async {
    final ByteData data = await rootBundle.load('images/lake.jpg');
    image = await loadImage(_decider(data));
  }
  List<int> _decider(ByteData data){
    if(imageFile==null)return new Uint8List.view(data.buffer);
    return imageFile.readAsBytesSync();
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    if (this.isImageloaded) {
      return new CustomPaint(
        painter: new ImageEditor(image: image),
      );
    } else {
      return new Center(child: new Text('loading'));
    }
  }
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: (){
                _alertChoiceDialog(context);
              },
            )
          ],
        ),
        body: new Container(
          child: _buildImage(),
        )
    );
  }
}

class ImageEditor extends CustomPainter {


  ImageEditor({
    this.image,
  });

  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    // ByteData data = image.toByteData();
    canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}