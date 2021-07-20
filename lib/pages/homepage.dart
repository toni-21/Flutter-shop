import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/product_related/products.dart';
import '../scoped_models/main.dart';
import '../widgets/ui_elements/logout.dart';

class HomePage extends StatefulWidget {
  final MainModel model;
  HomePage(this.model);
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.model.fetchProduct(onlyForUser: false);
  }

  Widget _buildProductsList() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget? child, MainModel model) {
      print("totalresults: ${model.displayedProducts.length}");
      Widget content = Center(child: Text('No Products available'));

      if (model.displayedProducts.length > 0 && !model.isLoading) {
        content = Products();
      } else if (model.isLoading) {
        content = Center(
          child: CircularProgressIndicator(),
        );
      }
      return RefreshIndicator(
        onRefresh: () {
          return model.fetchProduct(onlyForUser: false);
        },
        child: content,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: Text('Choose'),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () => Navigator.pushReplacementNamed(context, '/admin'),
            ),
            Divider(),
            LogoutListTile(),
          ],
        ),
      ),
      appBar: AppBar(
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
              builder: (BuildContext context, Widget? child, MainModel model) {
            return IconButton(
              icon: Icon(model.displayedFavoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () => model.toggleDisplayMode(),
            );
          })
        ],
        title: Text('Easy List'),
      ),
      body: _buildProductsList(),
    );
  }
}
