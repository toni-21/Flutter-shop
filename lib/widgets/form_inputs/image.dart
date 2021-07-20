import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Product? product;


  ImageInput(this.setImage, this.product);
  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  void _getImage(ImageSource source, context) async {
    final pickedFile =
        await _picker.getImage(source: source, imageQuality: 50, maxWidth: 500);
    setState(() {
      // ignore: unnecessary_null_comparison
      // if (pickedFile != null) {
      //   _image = File(pickedFile.path);
      //   widget.setImage(_image);
      // } else {
      //   _image = null;
      //   print('no image selected');
      // }
      _image = File(pickedFile!.path);
    });
    widget.setImage(_image);
    Navigator.of(context).pop();
  }

  void _openImagePickerr() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150.0,
          margin: EdgeInsets.all(8.0),
          child: Column(children: [
            Text(
              'Pick an image',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            TextButton(
              style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor)),
              child: Text('Use Gallery'),
              onPressed: () {
                _getImage(ImageSource.gallery, context);
              },
            ),
            TextButton(
              style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor)),
              child: Text('Use Camera'),
              onPressed: () {
                _getImage(ImageSource.camera,context);
              },
            )
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color _buttonColor = Theme.of(context).primaryColor;

    Widget _previewImage = Text('Please pick an image');
    if (_image != null) {
      _previewImage = Image.file(
        _image!,
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
        height: 300.0,
        alignment: Alignment.topCenter,
      );
    } else if (widget.product != null) {
      _previewImage = Image.file(
        widget.product!.image,
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
        height: 300.0,
        alignment: Alignment.topCenter,
      );
      widget.setImage(widget.product!.image);
    }

    return Column(
      children: <Widget>[
        OutlinedButton(
          style: ButtonStyle(
            side: MaterialStateProperty.all<BorderSide>(
              BorderSide(
                color: _buttonColor,
                width: 2.0,
              ),
            ),
          ),
          onPressed: () {
            _openImagePickerr();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: _buttonColor,
              ),
              SizedBox(width: 5.0),
              Text(
                widget.product == null
                    ? 'Add Image'
                    : 'Replace Image',
                style: TextStyle(color: _buttonColor),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        // ignore: unnecessary_null_comparison
        _previewImage,
      ],
    );
  }
}
