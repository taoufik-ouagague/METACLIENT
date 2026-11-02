import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaclient/models/client_config_model.dart';
import 'package:metaclient/theme/app_theme.dart';

void main() {
  group('ClientConfigModel Tests', () {
    test('parses complete config with colors and logo', () {
      final json = {
        "optionalColor": "#FDEB03",
        "primaryColor": "#2B3C99",
        "logoUrl": "https://metaphore.kaytechnology.com:6799/logo/logo_supratours.png",
        "secondaryColor": "#109B48"
      };

      final config = ClientConfigModel.fromJson(json);

      expect(config.primaryColor, '#2B3C99');
      expect(config.secondaryColor, '#109B48');
      expect(config.optionalColor, '#FDEB03');
      expect(config.logoUrl, 'https://metaphore.kaytechnology.com:6799/logo/logo_supratours.png');

      expect(config.primary, const Color(0xFF2B3C99));
      expect(config.secondary, const Color(0xFF109B48));
      expect(config.optional, const Color(0xFFFDEB03));

      expect(config.buttonGradient, isNotNull);
      expect(config.buttonGradient!.colors, [
        const Color(0xFF2B3C99),
        const Color(0xFF109B48),
      ]);
    });

    test('falls back correctly when colors are null or missing', () {
      final json = <String, dynamic>{
        "logoUrl": null,
      };

      final config = ClientConfigModel.fromJson(json);

      expect(config.primary, isNull);
      expect(config.secondary, isNull);
      expect(config.buttonGradient, isNull);
    });

    test('hex parser handles 6-digit, 8-digit, and invalid strings', () {
      expect(ClientConfigModel.parseHexColor('#2B3C99'), const Color(0xFF2B3C99));
      expect(ClientConfigModel.parseHexColor('2B3C99'), const Color(0xFF2B3C99));
      expect(ClientConfigModel.parseHexColor('#FF2B3C99'), const Color(0xFF2B3C99));
      expect(ClientConfigModel.parseHexColor(''), isNull);
      expect(ClientConfigModel.parseHexColor(null), isNull);
      expect(ClientConfigModel.parseHexColor('invalid'), isNull);
    });
  });

  group('ConfigController Fallbacks & Gradients', () {
    test('brandGradient blends primary, secondary, and optional colors', () {
      final json = {
        "optionalColor": "#FDEB03",
        "primaryColor": "#2B3C99",
        "secondaryColor": "#109B48"
      };

      final config = ClientConfigModel.fromJson(json);
      expect(config.primary, const Color(0xFF2B3C99));
      expect(config.secondary, const Color(0xFF109B48));
      expect(config.optional, const Color(0xFFFDEB03));
    });
  });
}
