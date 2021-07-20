import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../scoped_models/main.dart';
import '../../models/product.dart';
import '../ui_elements/title_default.dart';
import './price_tag.dart';
import './address_tag.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  ProductCard(this.product);

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: TitleDefault(product.title),
          ),
          SizedBox(width: 8.0),
          PriceTag('\$${product.price.toString()}'),
        ],
      ),
    );
  }

  Widget _buildActionsButtonbar(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget? child, MainModel model) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.info),
                iconSize: 35,
                color: Theme.of(context).accentColor,
                onPressed: () {
                  model.selectProduct(product.id);
                  Navigator.pushNamed<bool>(
                    context,
                    '/productpage/' + product.id,
                  ).then((_) => model.selectProduct(null));
                }),
            IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red),
              onPressed: () {
                model.selectProduct(product.id);
                model.toggleProductFavoriteStatus();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: product.id,
            child: FadeInImage(
              image: FileImage(product.image),
              placeholder: AssetImage('assets/food.jpeg'),
              height: 300.0,
              fit: BoxFit.cover,
            ),
          ),
          _buildTitlePriceRow(),
          AddressTag(product),
          _buildActionsButtonbar(context),
        ],
      ),
    );
  }
}
