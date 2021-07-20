import 'dart:async';
//import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:http/http.dart' as http;

import '../../models/location_data.dart';
import '../../models/product.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product? product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();

  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController newGoogleMapController;
  late LocationData _locationData;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      _getLocation(widget.product!.locationData.address, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _controlMap(GoogleMapController controller) {
    _controller.complete(controller);
    newGoogleMapController = controller;
  }

  final List<Marker> _allMarkers = [];

  // final CameraPosition _myLocation = CameraPosition(
  //   target: LatLng(41.40338, 2.17403),
  //   zoom: 14.0,
  //   bearing: 45.0,
  //   tilt: 45.0,
  // );

  void _getLocation(String address,
      {geocode = true, double? lat, double? lng}) async {
    if (address.isEmpty) {
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      // final Uri uri = Uri.https(
      //     'maps.googleapis.com', 'maps/api/geocode/json', {
      //   'address': address,
      //   'key': 'AIzaSyBo3ZVcmc2mNIHsd_CNLakb49w8AqHeoms'
      // });
      // final http.Response response = await http.get(uri);
      // final decodedResponse = json.decode(response.body);
      // print(decodedResponse);

      // final formattedAddress =
      //     decodedResponse['results'][0]['formatted_address'];
      // final _coords = decodedResponse['results'][0]['geometry']['location'];
      // _locationData = LocationData(
      //     address: formattedAddress,
      //     latitude: _coords['lat'],
      //     longitude: _coords['lng']);
      _locationData = LocationData(
          address: _addressInputController.text,
          latitude: 41.40338,
          longitude: 2.17403);
      if (_controller.isCompleted) {
        newGoogleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(
                  _locationData.latitude,
                  _locationData.longitude,
                ),
                zoom: 14.0,
                bearing: 45.0),
          ),
        );
      }
    } else if (!geocode && lat == null && lng == null) {
      _locationData = widget.product!.locationData;
    } else {
      _locationData =
          LocationData(address: address, latitude: lat!, longitude: lng!);
    }
    widget.setLocation(_locationData);
    setState(() {
      _addressInputController.text = _locationData.address;
      _allMarkers.add(
        Marker(
          markerId: MarkerId('my location'),
          onTap: () {
            print('marker tapped');
          },
          position: LatLng(
            _locationData.latitude,
            _locationData.longitude,
          ),
        ),
      );
    });
  }

  void locatePosition() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final LatLng currentCoords =
          LatLng(position.latitude, position.longitude);
      final String address = 'Google Headquaters';

      if (!_controller.isCompleted) {
        _getLocation(address,
            geocode: false, lat: position.latitude, lng: position.longitude);
        return;
      } else {
        newGoogleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: currentCoords, zoom: 14, bearing: 45.0)),
        );
        setState(() {
          _addressInputController.text = address;
        });
      }
    } catch (error) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Could not fetch location"),
              content: Text("Please add address manually!"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Okay")),
              ],
            );
          });
    }
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getLocation(_addressInputController.text, geocode: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          focusNode: _addressInputFocusNode,
          controller: _addressInputController,
          decoration: InputDecoration(labelText: 'Address'),
          // ignore: missing_return
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'no valid address found';
            }
          },
        ),
        SizedBox(height: 10),
        TextButton(
          child: Text(
            'Locate User',
          ),
          onPressed: () {
            locatePosition();
          },
        ),
        SizedBox(height: 10.0),
        // _buildMap(),
        _addressInputController.text.isEmpty
            ? Container()
            : Container(
                height: 300,
                width: 500,
                child: GoogleMap(
                  onMapCreated: _controlMap,
                  initialCameraPosition:
                      // _myLocation,
                      CameraPosition(
                    target:
                        LatLng(_locationData.latitude, _locationData.longitude),
                    zoom: 15.5,
                    bearing: 45.0,
                  ),
                  liteModeEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: Set.from(_allMarkers),
                  mapType: MapType.normal,
                ),
              ),
      ],
    );
  }
}
