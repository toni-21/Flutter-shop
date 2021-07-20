import 'package:flutter/material.dart';
import '../scoped_models/main.dart';

import './edit_productpage.dart';
import './list_productspage.dart';
import '../widgets/ui_elements/logout.dart';

class ProductAdminPage extends StatelessWidget {
  final MainModel model;
  ProductAdminPage(this.model);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                title: Text('Choose'),
              ),
              ListTile(
                leading: Icon(Icons.shop),
                title: Text('All Products'),
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
              ),
              Divider(),
              LogoutListTile(),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Manage Products'),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Create Product',
                icon: Icon(Icons.create),
              ),
              Tab(text: 'Product List', icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EditProduct(),
            ProductList(model),
          ],
        ),
      ),
    );
  }
}
