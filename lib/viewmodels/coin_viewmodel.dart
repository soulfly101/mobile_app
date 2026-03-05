import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/api_service.dart';

class CoinViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Coin> _coins = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Coin> get coins => _coins;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCoins() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _coins = await _api.fetchCoins();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadCoins();
  }
}