import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:path_provider/path_provider.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/authEnum.dart';
import '../models/location_data.dart';

mixin ConnectedProductModel on Model {
  List<Product> _products = [];
  String? _selectedProductId;
  User? _authenticatedUser;
  bool _isLoading = false;
  int? _totalResults;

  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.jpg');

    http.Response response = await http.get(Uri.parse(imageUrl));

    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  Future<Map<String, dynamic>> uploadPic(File implant) async {
    http.Response response = await http.post(
      Uri.parse('https://parseapi.back4app.com/files/pic.jpg'),
      body: implant.readAsBytesSync(),
      headers: {
        'X-Parse-Application-Id': 'VuHdv2mY7eIMuROZJH3eipamDKxRCeHHJZfyOYSO',
        'X-Parse-REST-API-Key': 'e1J78wpMqVOmdexNmDu6Vp95X24Imosu8oUpe191',
        'Content-Type': 'image/jpeg',
      },
    );
    final Map<String, dynamic> responseData = json.decode(response.body);
    return responseData;
  }

  Future<bool> addProduct(String title, String description, double price,
      File image, LocationData locData) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> imageData = await uploadPic(image);
    print(imageData);

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'price': price.toString(),
      'image': {
        "__type": "File",
        "name": imageData['name'],
        "url": imageData['url']
      },
      'userEmail': _authenticatedUser!.email,
      'userId': _authenticatedUser!.id,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse('https://parseapi.back4app.com/classes/products'),
        body: json.encode(productData),
        headers: {
          'X-Parse-Application-Id': 'VuHdv2mY7eIMuROZJH3eipamDKxRCeHHJZfyOYSO',
          'X-Parse-REST-API-Key': 'e1J78wpMqVOmdexNmDu6Vp95X24Imosu8oUpe191',
          'Content-Type': 'application/json',
        },
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode != 201 && response.statusCode != 200) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      Product newProduct = Product(
        id: responseData['objectId'],
        title: title,
        description: description,
        price: price,
        image: image,
        userId: _authenticatedUser!.id,
        userEmail: _authenticatedUser!.email,
        locationData: locData,
      );
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

mixin ProductModel on ConnectedProductModel {
  bool _showFavorites = false;

  List<Product> get products {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorite).toList());
    }
    return List.from(_products);
  }

  String? get selectedProductId {
    return _selectedProductId;
  }

  int? get totalResults {
    return _totalResults;
  }

  Product? get selectedProduct {
    if (_selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == _selectedProductId;
    });
  }

  int? get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selectedProductId;
    });
  }

  bool get displayedFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> updateProduct(String title, String description, double price,
      File image, LocationData locData) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> imageData = await uploadPic(image);

    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'price': price.toString(),
      'image': {
        "__type": "File",
        "name": imageData['name'],
        "url": imageData['url'],
      },
      'userEmail': selectedProduct!.userEmail,
      'userId': selectedProduct!.userId,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
    };
    return http.put(
      Uri.parse(
          'https://parseapi.back4app.com/classes/products/${selectedProduct!.id}'),
      body: json.encode(updateData),
      headers: {
        'X-Parse-Application-Id': 'VuHdv2mY7eIMuROZJH3eipamDKxRCeHHJZfyOYSO',
        'X-Parse-REST-API-Key': 'e1J78wpMqVOmdexNmDu6Vp95X24Imosu8oUpe191',
        'Content-Type': 'application/json'
      },
    ).then((http.Response response) {
      _isLoading = false;
      final Product updateProduct = Product(
          id: selectedProduct!.id,
          title: title,
          description: description,
          price: price,
          image: image,
          locationData: locData,
          userEmail: selectedProduct!.userEmail,
          userId: selectedProduct!.userId);
      _products[selectedProductIndex!] = updateProduct;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct!.id;
    _products.removeAt(selectedProductIndex!);
    _selectedProductId = null;
    notifyListeners();
    return http.delete(
      Uri.parse(
          'https://parseapi.back4app.com/classes/products/$deletedProductId'),
      headers: {
        'X-Parse-Application-Id': 'VuHdv2mY7eIMuROZJH3eipamDKxRCeHHJZfyOYSO',
        'X-Parse-REST-API-Key': 'e1J78wpMqVOmdexNmDu6Vp95X24Imosu8oUpe191',
      },
    ).then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future fetchProduct({onlyForUser = false, clearExisting = false}) async {
    _isLoading = true;
    if (clearExisting) {
      _products = [];
    }

    notifyListeners();
    try {
      final http.Response response = await http.get(
        Uri.parse('https://parseapi.back4app.com/classes/products'),
        headers: {
          'X-Parse-Application-Id': 'VuHdv2mY7eIMuROZJH3eipamDKxRCeHHJZfyOYSO',
          'X-Parse-REST-API-Key': 'e1J78wpMqVOmdexNmDu6Vp95X24Imosu8oUpe191',
        },
      );
      final List<Product> fetchedProductList = [];
      final decodedResponse = json.decode(response.body);
      print(decodedResponse);

      if (decodedResponse == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      print("oga1");
      List productDataList = decodedResponse['results'];

      for (int i = 0; i < productDataList.length; i++) {
        Map<String, dynamic> productData = productDataList[i];

        String url = productData['image']['url'];
        File urlImage = await urlToFile(url);

        final Product _product = Product(
          id: productData['objectId'],
          title: productData['title'],
          description: productData['description'],
          price: double.parse((productData['price'])),
          image: urlImage,
          userId: productData['userId'],
          userEmail: productData['userEmail'],
          locationData: LocationData(
            address: productData['loc_address'],
            latitude: productData['loc_lat'],
            longitude: productData['loc_lng'],
          ),
          isFavorite: productData['isFavorite'],
        );
        print('oga2');
        fetchedProductList.add(_product);
      }
      if (onlyForUser) {
        _products = fetchedProductList.where((Product product) {
          return product.userId == _authenticatedUser!.id;
        }).toList();
      } else {
        _products = fetchedProductList;
      }
      _isLoading = false;
      notifyListeners();
      _selectedProductId = null;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return;
    }
  }

  void toggleProductFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedProduct!.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
      id: selectedProduct!.id,
      title: selectedProduct!.title,
      description: selectedProduct!.description,
      price: selectedProduct!.price,
      image: selectedProduct!.image,
      userEmail: selectedProduct!.userEmail,
      userId: selectedProduct!.userId,
      locationData: selectedProduct!.locationData,
      isFavorite: newFavoriteStatus,
    );
    _products[selectedProductIndex!] = updatedProduct;
    notifyListeners();

    final Map<String, dynamic> imageData =
        await uploadPic(updatedProduct.image);

    final Map<String, dynamic> updateData = {
      'title': updatedProduct.title,
      'description': updatedProduct.description,
      'price': updatedProduct.price.toString(),
      'image': {
        "__type": "File",
        "name": imageData['name'],
        "url": imageData['url'],
      },
      'userEmail': selectedProduct!.userEmail,
      'userId': selectedProduct!.userId,
      'loc_lat': updatedProduct.locationData.latitude,
      'loc_lng': updatedProduct.locationData.longitude,
      'loc_address': updatedProduct.locationData.address,
      'isFavorite': updatedProduct.isFavorite,
    };

    http.Response response;
    response = await http.put(
        Uri.parse(
            'https://parseapi.back4app.com/classes/products/${selectedProduct!.id}'),
        body: json.encode(updateData),
        headers: {
          'X-Parse-Application-Id': 'VuHdv2mY7eIMuROZJH3eipamDKxRCeHHJZfyOYSO',
          'X-Parse-REST-API-Key': 'e1J78wpMqVOmdexNmDu6Vp95X24Imosu8oUpe191',
          'Content-Type': 'application/json',
        });

    if (response.statusCode != 200) {
      final Product updatedProduct = Product(
        id: selectedProduct!.id,
        title: selectedProduct!.title,
        description: selectedProduct!.description,
        price: selectedProduct!.price,
        image: selectedProduct!.image,
        userEmail: selectedProduct!.userEmail,
        userId: selectedProduct!.userId,
        locationData: selectedProduct!.locationData,
        isFavorite: !newFavoriteStatus,
      );
      _products[selectedProductIndex!] = updatedProduct;
      notifyListeners();
      _selectedProductId = null;
    }
  }

  void selectProduct(String? productId) {
    _selectedProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    _selectedProductId = null;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductModel {
  late Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  User? get user {
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    Map<String, String> authData = {
      "username":
          email, //back4app requires username not email so I assigned the email to back4app username
      "password": password,
      // 'returnSecureToken': true,
    };
    Uri uri = Uri.https('parseapi.back4app.com', '/login', authData);
    Uri shorturi = Uri.https('parseapi.back4app.com', '/users');

    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.get(
        uri,
        headers: {
          'X-Parse-Application-Id': 'VuHdv2mY7eIMuROZJH3eipamDKxRCeHHJZfyOYSO',
          'X-Parse-REST-API-Key': 'e1J78wpMqVOmdexNmDu6Vp95X24Imosu8oUpe191',
          'X-Parse-Revocable-Session': '1',
          'Content-Type': 'application/json',
        },
      );
    } else {
      response = await http.post(
        shorturi,
        body: json.encode(authData),
        headers: {
          'X-Parse-Application-Id': 'VuHdv2mY7eIMuROZJH3eipamDKxRCeHHJZfyOYSO',
          'X-Parse-REST-API-Key': 'e1J78wpMqVOmdexNmDu6Vp95X24Imosu8oUpe191',
          'X-Parse-Revocable-Session': '1',
          'Content-Type': 'application/json',
        },
      );
    }
    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);

    bool hasError = true;
    String message = 'something went wrong';

    if (responseData.containsKey('sessionToken') == true) {
      hasError = false;
      message = 'Authentication succeded';
      _authenticatedUser = User(
          id: responseData['objectId'],
          email: email,
          token: responseData['sessionToken']);
      int? timer = 3600;
      setAuthTimeout(timer);

      final DateTime now = DateTime.now();
      final DateTime expiryTime = now.add(
        Duration(seconds: timer),
      );
      _userSubject.add(true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['sessionToken']);
      prefs.setString('userid', responseData['objectId']);
      prefs.setString('userEmail', email);

      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error'] == 'Invalid username/password.') {
      hasError = true;
      message = 'Invalid username/password';
    } else if (responseData['error'] ==
        'Account already exists for this username.') {
      hasError = true;
      message = 'This username already exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoauthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final userId = prefs.getString('userid');
    final String? userEmail = prefs.getString('userEmail');
    final expiryTimeString = prefs.getString('expiryTime');

    if (token != null && expiryTimeString != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      print(token);

      print(userId);

      print(userEmail);

      //print(userId);
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      if (userId != null && userEmail != null)
        _authenticatedUser = User(
          id: userId,
          email: userEmail,
          token: token,
        );

      if (parsedExpiryTime.isBefore(now)) {
        //print(parsedExpiryTime.toString());
        _authenticatedUser = null;
        print('you are nulled');
        notifyListeners();
        return;
      }

      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    print('Logout');
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    _selectedProductId = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    notifyListeners();
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
      _userSubject.add(false);
    });
  }
}

mixin UtilityModel on ConnectedProductModel {
  bool get isLoading {
    return _isLoading;
  }
}
