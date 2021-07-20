import 'package:flutter/material.dart';

import 'dart:async';

import '../widgets/ui_elements/title_default.dart';
import '../models/product.dart';
import './address_map_page.dart';
import '../widgets/product_related/product_fab.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  Widget _buildAddressPriceRow(price, address, context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AddressMap(product),
              ),
            );
          },
          child: Text(
            address,
            style: TextStyle(
              fontFamily: 'Oswald',
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          '\$' + price.toString(),
          style: TextStyle(color: Colors.grey, fontFamily: 'Oswald'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('back button pressed');
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(product.title),
        // ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 256.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title:Text(
                    product.title,
                  ),
            
                background: Hero(
                  tag: product.id,
                  child: FadeInImage(
                    image: FileImage(product.image),
                    placeholder: AssetImage('assets/food.jpeg'),
                    height: 300.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
             
              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: TitleDefault(product.title),
              ),
              _buildAddressPriceRow(
                  product.price, product.locationData.address, context),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  product.description,
                  textAlign: TextAlign.center,
                ),
              ),
            ])),
          ],
        ),
        floatingActionButton: ProductFAB(product),
      ),
    );
  }
}
