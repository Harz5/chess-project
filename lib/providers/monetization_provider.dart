import 'package:flutter/material.dart';
import '../models/monetization_models.dart';
import '../services/monetization_service.dart';

/// Provider für die Verwaltung der Monetarisierungsfunktionalität
class MonetizationProvider extends ChangeNotifier {
  final MonetizationService _monetizationService = MonetizationService();
  
  // Produkt-Katalog
  List<Product> _products = [];
  List<Subscription> _subscriptions = [];
  List<VirtualCurrency> _virtualCurrencies = [];
  
  // Benutzerkonto
  UserAccount? _userAccount;
  
  // Initialisierungsstatus
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getter
  List<Product> get products => _products;
  List<Subscription> get subscriptions => _subscriptions;
  List<VirtualCurrency> get virtualCurrencies => _virtualCurrencies;
  UserAccount? get userAccount => _userAccount;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  MonetizationProvider() {
    _initializeService();
  }
  
  /// Initialisiert den Monetarisierungsservice
  Future<void> _initializeService() async {
    if (_isInitialized || _isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _monetizationService.initialize();
      
      _products = _monetizationService.getProducts();
      _subscriptions = _monetizationService.getSubscriptions();
      _virtualCurrencies = _monetizationService.getVirtualCurrencies();
      _userAccount = _monetizationService.getUserAccount();
      
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Fehler bei der Initialisierung: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Aktualisiert die Daten
  Future<void> refreshData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _products = _monetizationService.getProducts();
      _subscriptions = _monetizationService.getSubscriptions();
      _virtualCurrencies = _monetizationService.getVirtualCurrencies();
      _userAccount = _monetizationService.getUserAccount();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren der Daten: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Kauft ein Produkt
  Future<bool> purchaseProduct(String productId) async {
    if (!_isInitialized || _isLoading) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _monetizationService.purchaseProduct(productId);
      
      if (success) {
        _userAccount = _monetizationService.getUserAccount();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _errorMessage = 'Fehler beim Kauf des Produkts: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Abonniert ein Abonnement
  Future<bool> subscribeToSubscription(String subscriptionId) async {
    if (!_isInitialized || _isLoading) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _monetizationService.subscribeToSubscription(subscriptionId);
      
      if (success) {
        _userAccount = _monetizationService.getUserAccount();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _errorMessage = 'Fehler beim Abonnieren: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Kauft virtuelle Währung
  Future<bool> purchaseVirtualCurrency(String currencyId) async {
    if (!_isInitialized || _isLoading) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _monetizationService.purchaseVirtualCurrency(currencyId);
      
      if (success) {
        _userAccount = _monetizationService.getUserAccount();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _errorMessage = 'Fehler beim Kauf der virtuellen Währung: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Gibt virtuelle Währung aus
  Future<bool> spendVirtualCurrency(int amount) async {
    if (!_isInitialized || _isLoading) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _monetizationService.spendVirtualCurrency(amount);
      
      if (success) {
        _userAccount = _monetizationService.getUserAccount();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _errorMessage = 'Fehler beim Ausgeben der virtuellen Währung: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Prüft, ob ein Produkt gekauft wurde
  bool hasProduct(String productId) {
    if (!_isInitialized) return false;
    return _monetizationService.hasProduct(productId);
  }
  
  /// Prüft, ob der Benutzer Premium ist
  bool isPremium() {
    if (!_isInitialized) return false;
    return _monetizationService.isPremium();
  }
  
  /// Gibt den Kontostand der virtuellen Währung zurück
  int getVirtualCurrencyBalance() {
    if (!_isInitialized) return 0;
    return _monetizationService.getVirtualCurrencyBalance();
  }
  
  /// Gibt ein Produkt anhand der ID zurück
  Product? getProductById(String productId) {
    if (!_isInitialized) return null;
    return _monetizationService.getProductById(productId);
  }
  
  /// Gibt ein Abonnement anhand der ID zurück
  Subscription? getSubscriptionById(String subscriptionId) {
    if (!_isInitialized) return null;
    return _monetizationService.getSubscriptionById(subscriptionId);
  }
  
  /// Gibt eine virtuelle Währung anhand der ID zurück
  VirtualCurrency? getVirtualCurrencyById(String currencyId) {
    if (!_isInitialized) return null;
    return _monetizationService.getVirtualCurrencyById(currencyId);
  }
}
