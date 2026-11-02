import 'package:flutter/material.dart';

class ClientConfigModel {
  final String? optionalColor;
  final String? primaryColor;
  final String? secondaryColor;
  final String? logoUrl;

  ClientConfigModel({
    this.optionalColor,
    this.primaryColor,
    this.secondaryColor,
    this.logoUrl,
  });

  factory ClientConfigModel.fromJson(Map<String, dynamic> json) {
    return ClientConfigModel(
      optionalColor: json['optionalColor']?.toString(),
      primaryColor: json['primaryColor']?.toString(),
      secondaryColor: json['secondaryColor']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'optionalColor': optionalColor,
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'logoUrl': logoUrl,
      };

  static Color? parseHexColor(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty) return null;
    var hex = hexString.replaceAll('#', '').trim();
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(val);
    }
    return null;
  }

  Color? get primary => parseHexColor(primaryColor);
  Color? get secondary => parseHexColor(secondaryColor);
  Color? get optional => parseHexColor(optionalColor);

  LinearGradient? get buttonGradient {
    final p = primary;
    final s = secondary;
    if (p != null && s != null) {
      return LinearGradient(
        colors: [p, s],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (p != null) {
      return LinearGradient(
        colors: [p, p.withOpacity(0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return null;
  }
}
