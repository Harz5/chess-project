import 'package:flutter/material.dart';
import '../models/monetization_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service für die Monetarisierungsfunktionalität
class MonetizationService {
  // Singleton-Instanz
  static final MonetizationService _instance = MonetizationService._internal();
  factory MonetizationService() => _instance;
  MonetizationService._internal();

  // Produkt-Katalog
  final List<Product> _products = [];
  final List<Subscription> _subscriptions = [];
  final List<VirtualCurrency> _virtualCurrencies = [];

  // Benutzerkonto
  UserAccount? _userAccount;

  // Initialisierungsstatus
  bool _isInitialized = false;

  /// Initialisiert den Monetarisierungsservice
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Lade Produkte
    _loadProducts();

    // Lade Benutzerkonto
    await _loadUserAccount();

    _isInitialized = true;
  }

  /// Lädt die Produktdaten
  void _loadProducts() {
    // In einer echten Implementierung würden diese Daten von einem Server geladen
    // Hier werden sie hart codiert für Demonstrationszwecke

    // Produkte
    _products.addAll([
      const Product(
        id: 'variant_pack',
        title: 'Varianten-Paket',
        description:
            'Schaltet alle Schachvarianten frei: Chess960, Crazyhouse, Antichess und mehr.',
        price: 4.99,
        type: 'non_consumable',
        category: 'variant',
        features: [
          'Chess960 (Fischer Random Chess)',
          'Crazyhouse',
          'Antichess',
          'Drei-Schach',
          'König des Hügels',
          'Racing Kings',
        ],
        iconAsset: 'assets/images/variant_pack.png',
      ),
      const Product(
        id: 'design_pack',
        title: 'Design-Paket',
        description: 'Schaltet zusätzliche Themes und Figurensets frei.',
        price: 3.99,
        type: 'non_consumable',
        category: 'design',
        features: [
          '10+ thematische Schachbretter',
          '8+ Figurensets',
          'Anpassbare Hintergründe',
          'Benutzerdefinierbare Soundeffekte',
        ],
        iconAsset: 'assets/images/design_pack.png',
      ),
      const Product(
        id: 'master_pack',
        title: 'Meister-Paket',
        description:
            'Erweiterte KI-Gegner und Analysetools für fortgeschrittene Spieler.',
        price: 7.99,
        type: 'non_consumable',
        category: 'master',
        features: [
          'Erweiterte KI-Gegner mit 5 zusätzlichen Schwierigkeitsgraden',
          'Detaillierte Spielanalyse und Zugvorschläge',
          'Bibliothek mit klassischen Schachpartien',
          'Taktiktrainer mit über 1000 Übungen',
          'Eröffnungsdatenbank mit Statistiken',
        ],
        iconAsset: 'assets/images/master_pack.png',
      ),
      const Product(
        id: 'all_inclusive_pack',
        title: 'Alles-inklusive-Paket',
        description: 'Alle Premium-Inhalte zu einem vergünstigten Preis.',
        price: 12.99,
        type: 'non_consumable',
        category: 'bundle',
        features: [
          'Alle Schachvarianten',
          'Alle Design-Optionen',
          'Alle Meister-Funktionen',
          'Lebenslanges Upgrade auf alle zukünftigen Inhalte',
        ],
        iconAsset: 'assets/images/all_inclusive_pack.png',
      ),
      const Product(
        id: 'ad_free',
        title: 'Werbefreiheit',
        description: 'Entfernt alle Werbung aus der App.',
        price: 2.99,
        type: 'non_consumable',
        category: 'misc',
        features: [
          'Keine Banner-Werbung',
          'Keine Interstitial-Werbung',
          'Keine Belohnungswerbung',
        ],
        iconAsset: 'assets/images/ad_free.png',
      ),
    ]);

    // Abonnements
    _subscriptions.addAll([
      const Subscription(
        id: 'chess_club_monthly',
        title: 'Schach-Club Monatlich',
        description: 'Monatliches Abonnement für alle Premium-Inhalte.',
        price: 2.99,
        category: 'subscription',
        duration: 'monthly',
        features: [
          'Zugang zu allen Premium-Inhalten',
          'Werbefreiheit',
          'Wöchentliche neue Schachaufgaben',
          'Monatliche exklusive Turniere',
          'Priorisierter Matchmaking für Online-Spiele',
        ],
        iconAsset: 'assets/images/chess_club_monthly.png',
      ),
      const Subscription(
        id: 'chess_club_yearly',
        title: 'Schach-Club Jährlich',
        description:
            'Jährliches Abonnement für alle Premium-Inhalte mit Rabatt.',
        price: 24.99,
        category: 'subscription',
        duration: 'yearly',
        discountPercentage: 30.0,
        features: [
          'Zugang zu allen Premium-Inhalten',
          'Werbefreiheit',
          'Wöchentliche neue Schachaufgaben',
          'Monatliche exklusive Turniere',
          'Priorisierter Matchmaking für Online-Spiele',
          'Cloud-Speicherung aller Partien',
          'Frühzeitiger Zugang zu neuen Funktionen',
        ],
        iconAsset: 'assets/images/chess_club_yearly.png',
      ),
    ]);

    // Virtuelle Währung
    _virtualCurrencies.addAll([
      const VirtualCurrency(
        id: 'chess_coins_small',
        name: 'Schachmünzen Klein',
        amount: 100,
        price: 0.99,
        iconAsset: 'assets/images/chess_coins.png',
      ),
      const VirtualCurrency(
        id: 'chess_coins_medium',
        name: 'Schachmünzen Mittel',
        amount: 500,
        price: 3.99,
        bonusPercentage: 5.0,
        iconAsset: 'assets/images/chess_coins.png',
      ),
      const VirtualCurrency(
        id: 'chess_coins_large',
        name: 'Schachmünzen Groß',
        amount: 1200,
        price: 7.99,
        bonusPercentage: 20.0,
        iconAsset: 'assets/images/chess_coins.png',
      ),
    ]);
  }

  /// Lädt das Benutzerkonto
  Future<void> _loadUserAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_account');

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _userAccount = UserAccount.fromMap(userMap);
      } else {
        // Erstelle ein neues Benutzerkonto, wenn keines existiert
        _userAccount = UserAccount(
          userId: 'local_user',
          email: 'local@example.com',
        );
        await _saveUserAccount();
      }
    } catch (e) {
      print('Fehler beim Laden des Benutzerkontos: $e');
      // Erstelle ein neues Benutzerkonto im Fehlerfall
      _userAccount = UserAccount(
        userId: 'local_user',
        email: 'local@example.com',
      );
    }
  }

  /// Speichert das Benutzerkonto
  Future<void> _saveUserAccount() async {
    if (_userAccount == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(_userAccount!.toMap());
      await prefs.setString('user_account', userJson);
    } catch (e) {
      print('Fehler beim Speichern des Benutzerkontos: $e');
    }
  }

  /// Gibt alle Produkte zurück
  List<Product> getProducts() {
    return List.unmodifiable(_products);
  }

  /// Gibt alle Abonnements zurück
  List<Subscription> getSubscriptions() {
    return List.unmodifiable(_subscriptions);
  }

  /// Gibt alle virtuellen Währungen zurück
  List<VirtualCurrency> getVirtualCurrencies() {
    return List.unmodifiable(_virtualCurrencies);
  }

  /// Gibt ein Produkt anhand der ID zurück
  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Gibt ein Abonnement anhand der ID zurück
  Subscription? getSubscriptionById(String subscriptionId) {
    try {
      return _subscriptions
          .firstWhere((subscription) => subscription.id == subscriptionId);
    } catch (e) {
      return null;
    }
  }

  /// Gibt eine virtuelle Währung anhand der ID zurück
  VirtualCurrency? getVirtualCurrencyById(String currencyId) {
    try {
      return _virtualCurrencies
          .firstWhere((currency) => currency.id == currencyId);
    } catch (e) {
      return null;
    }
  }

  /// Gibt das Benutzerkonto zurück
  UserAccount? getUserAccount() {
    return _userAccount;
  }

  /// Kauft ein Produkt
  Future<bool> purchaseProduct(String productId) async {
    // In einer echten Implementierung würde hier die In-App-Purchase-API verwendet
    // Hier wird der Kauf simuliert

    if (_userAccount == null) return false;

    final product = getProductById(productId);
    if (product == null) return false;

    // Simuliere erfolgreichen Kauf
    _userAccount!.addPurchasedProduct(productId);
    await _saveUserAccount();

    return true;
  }

  /// Abonniert ein Abonnement
  Future<bool> subscribeToSubscription(String subscriptionId) async {
    // In einer echten Implementierung würde hier die In-App-Purchase-API verwendet
    // Hier wird das Abonnement simuliert

    if (_userAccount == null) return false;

    final subscription = getSubscriptionById(subscriptionId);
    if (subscription == null) return false;

    // Simuliere erfolgreiches Abonnement
    _userAccount!.setActiveSubscription(subscriptionId);
    await _saveUserAccount();

    return true;
  }

  /// Kauft virtuelle Währung
  Future<bool> purchaseVirtualCurrency(String currencyId) async {
    // In einer echten Implementierung würde hier die In-App-Purchase-API verwendet
    // Hier wird der Kauf simuliert

    if (_userAccount == null) return false;

    final currency = getVirtualCurrencyById(currencyId);
    if (currency == null) return false;

    // Simuliere erfolgreichen Kauf
    _userAccount!.addVirtualCurrency(currency.amount);
    await _saveUserAccount();

    return true;
  }

  /// Gibt virtuelle Währung aus
  Future<bool> spendVirtualCurrency(int amount) async {
    if (_userAccount == null) return false;

    final success = _userAccount!.spendVirtualCurrency(amount);
    if (success) {
      await _saveUserAccount();
    }

    return success;
  }

  /// Prüft, ob ein Produkt gekauft wurde
  bool hasProduct(String productId) {
    if (_userAccount == null) return false;
    return _userAccount!.hasProduct(productId);
  }

  /// Prüft, ob der Benutzer Premium ist
  bool isPremium() {
    if (_userAccount == null) return false;
    return _userAccount!.isPremium;
  }

  /// Gibt den Kontostand der virtuellen Währung zurück
  int getVirtualCurrencyBalance() {
    if (_userAccount == null) return 0;
    return _userAccount!.virtualCurrencyBalance;
  }

  /// Gibt zurück, ob der Service initialisiert ist
  bool get isInitialized => _isInitialized;
}
