//import 'package:flutter/material.dart';
import 'dart:io';
import './location_data.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final File image;
  final String? imageUrl;
  final String userId;
  final String userEmail;
  final bool isFavorite;
  final LocationData locationData;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
        this.imageUrl,
    required this.userId,
    required this.userEmail,
    required this.locationData,
    this.isFavorite = false,
  });
}
