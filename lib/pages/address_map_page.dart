import 'dart:async';
import 'package:flutter/material.dart';

import '../models/product.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressMap extends StatefulWidget {
  final Product product;
  AddressMap(this.product);
  @override
  State<StatefulWidget> createState() {
    return _AddressMapState();
  }
}

class _AddressMapState extends State<AddressMap> {
  final Completer<GoogleMapController> _controller = Completer();

  void _setMapControl(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Location'),
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
        actions: <Widget>[
          TextButton(
            child: Text(
              'CLOSE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(), 
          )
        ],
      ),
      body: GoogleMap(
        onMapCreated: _setMapControl,
        initialCameraPosition: CameraPosition(
            target: LatLng(widget.product.locationData.latitude,
                widget.product.locationData.longitude),
            zoom: 14.0,
            bearing: 45.0),
        markers: Set.from(<Marker>[
          Marker(
            markerId: MarkerId('My Location'),
            onTap: () => print('marker tapped'),
            position: LatLng(widget.product.locationData.latitude,
                widget.product.locationData.longitude),
          ),
        ]),
        liteModeEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        mapType: MapType.normal,
      ),
    );
  }
}
