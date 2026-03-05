import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/coin.dart';

class ApiService {
  Future<List<Coin>> fetchCoins() async {
    final uri = Uri.https(
      'api.coingecko.com',
      '/api/v3/coins/markets',
      {
        'vs_currency': 'usd',
        'order': 'market_cap_desc',
        'per_page': '25',
        'page': '1',
        'sparkline': 'false',
      },
    );

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      // HTTP error handling
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      // JSON parsing
      final decoded = jsonDecode(response.body);

      // API returns an array
      if (decoded is! List) {
        throw const FormatException('Unexpected JSON format (expected a List).');
      }

      return decoded
          .map((item) => Coin.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.message}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}