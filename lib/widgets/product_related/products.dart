import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../../scoped_models/main.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(products) {
    Widget productCard;
    if (products.length > 0) {
      productCard = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index]),
        itemCount: products.length,
      );
    } else {
      productCard = Center(
        child: Text('Product not found, please add product'),
      );
    }
    return productCard;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget? child, MainModel model) {
          print('[Products Widget] build();');
      return _buildProductList(model.displayedProducts);
    });
  }
}
