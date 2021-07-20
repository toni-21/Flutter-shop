import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/location_data.dart';
import '../scoped_models/main.dart';
import '../widgets/form_inputs/location.dart';
import '../widgets/form_inputs/image.dart';

class EditProduct extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditProductState();
  }
}

class _EditProductState extends State<EditProduct> {
  Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null,
    'location': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _priceTextController = TextEditingController();

  Widget _buildTitleTextField(product) {
    if (product == null) {
      _titleTextController.text = _titleTextController.text;
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.title;
    } else if (product != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Title'),
      controller: _titleTextController,
      //initialValue: product == null ? '' : product.title,
      // ignore: missing_return
      validator: (String? value) {
        if (value == null || value.length < 5) {
          return 'Title is required and ahould be 5+ characters long';
        }
      },
      onSaved: (String? value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(product) {
    if (product == null) {
      _descriptionTextController.text = _descriptionTextController.text;
    } else if (product != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = product.description;
    } else if (product != null && _descriptionTextController.text != '') {
      _descriptionTextController.text = _descriptionTextController.text;
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Description'),
      controller: _descriptionTextController,
      maxLines: 4,
      //initialValue: product == null ? _titleTextController.text : product.description,
      // ignore: missing_return
      validator: (String? value) {
        if (value == null || value.length < 10) {
          return 'Description is required and should be 10+ characters long';
        }
      },
      onSaved: (String? value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPriceTextField(product) {
    if (product == null) {
      _priceTextController.text = _priceTextController.text;
    } else if (product != null && _priceTextController.text.trim() == '') {
      _priceTextController.text = product.price.toString();
    } else if (product != null && _priceTextController.text != '') {
      _priceTextController.text = _priceTextController.text;
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Price'),
      controller: _priceTextController,
      keyboardType: TextInputType.number,
      //initialValue: product == null ? '' : product.price.toString(),
      // ignore: missing_return
      validator: (String? value) {
        if (value == null ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number.';
        }
      },
      onSaved: (String? value) {
        if (value != null) _formData['price'] = double.parse(value);
      },
    );
  }

  Widget _buildRaisedButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget? child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : ElevatedButton(
                child: Text('SAVE'),
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex),
              );
      },
    );
  }

  void setLocation(LocationData? locData) {
    _formData['location'] = locData;
  }

  void _setImage(File image) {
      _formData['image'] = image;

  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int? selectedProductIndex]) {
    if (!_formKey.currentState!.validate() ||
        (_formData['image'] == null && selectedProductIndex == -1)) {
      return;
    }
    _formKey.currentState!.save();
    if (selectedProductIndex == -1) {
      addProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        double.parse(_priceTextController.text),
        _formData['image'],
        _formData['location'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/home')
              .then((_) => setSelectedProduct(null));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('something went wrong'),
                content: Text('please try again'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Okay'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            },
          );
        }
      });
    } else {
      updateProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        double.parse(_priceTextController.text),
        _formData['image'],
        _formData['location'],
      ).then(
        (_) => Navigator.pushReplacementNamed(context, '/').then(
          (_) => setSelectedProduct(null),
        ),
      );
    }
  }

  Widget _buildpageContent(
    BuildContext context,
    Product? product,
  ) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.95;
    final double targetpadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetpadding / 2),
            children: <Widget>[
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              SizedBox(height: 10.0),
              LocationInput(setLocation, product),
              SizedBox(height: 10.0),
              ImageInput(_setImage, product),
              SizedBox(height: 10.0),
              _buildRaisedButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget? child, MainModel model) {
        return model.selectedProductIndex == -1
            ? _buildpageContent(context, model.selectedProduct)
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: _buildpageContent(context, model.selectedProduct),
              );
      },
    );
  }
}
