/// Modell für In-App-Kaufprodukte
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String type; // 'consumable', 'non_consumable', 'subscription'
  final String category; // 'variant', 'design', 'master', 'bundle'
  final List<String> features;
  final String? iconAsset;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.category,
    required this.features,
    this.iconAsset,
  });

  /// Erstellt ein Produkt aus einer Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      type: map['type'] as String,
      category: map['category'] as String,
      features: List<String>.from(map['features'] as List),
      iconAsset: map['iconAsset'] as String?,
    );
  }

  /// Konvertiert das Produkt in eine Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'type': type,
      'category': category,
      'features': features,
      'iconAsset': iconAsset,
    };
  }
}

/// Modell für Abonnements
class Subscription extends Product {
  final String duration; // 'monthly', 'yearly'
  final double discountPercentage;
  final bool autoRenewing;

  const Subscription({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.category,
    required super.features,
    required this.duration,
    this.discountPercentage = 0.0,
    this.autoRenewing = true,
    super.iconAsset,
  }) : super(type: 'subscription');

  /// Erstellt ein Abonnement aus einer Map
  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      category: map['category'] as String,
      features: List<String>.from(map['features'] as List),
      duration: map['duration'] as String,
      discountPercentage: map['discountPercentage'] as double? ?? 0.0,
      autoRenewing: map['autoRenewing'] as bool? ?? true,
      iconAsset: map['iconAsset'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'duration': duration,
      'discountPercentage': discountPercentage,
      'autoRenewing': autoRenewing,
    });
    return map;
  }
}

/// Modell für virtuelle Währung
class VirtualCurrency {
  final String id;
  final String name;
  final int amount;
  final double price;
  final double bonusPercentage;
  final String? iconAsset;

  const VirtualCurrency({
    required this.id,
    required this.name,
    required this.amount,
    required this.price,
    this.bonusPercentage = 0.0,
    this.iconAsset,
  });

  /// Erstellt eine virtuelle Währung aus einer Map
  factory VirtualCurrency.fromMap(Map<String, dynamic> map) {
    return VirtualCurrency(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as int,
      price: map['price'] as double,
      bonusPercentage: map['bonusPercentage'] as double? ?? 0.0,
      iconAsset: map['iconAsset'] as String?,
    );
  }

  /// Konvertiert die virtuelle Währung in eine Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'price': price,
      'bonusPercentage': bonusPercentage,
      'iconAsset': iconAsset,
    };
  }
}

/// Modell für Benutzerkonten
class UserAccount {
  final String userId;
  String email;
  bool isPremium;
  List<String> purchasedProducts;
  String? activeSubscription;
  int virtualCurrencyBalance;

  UserAccount({
    required this.userId,
    required this.email,
    this.isPremium = false,
    this.purchasedProducts = const [],
    this.activeSubscription,
    this.virtualCurrencyBalance = 0,
  });

  /// Erstellt ein Benutzerkonto aus einer Map
  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      userId: map['userId'] as String,
      email: map['email'] as String,
      isPremium: map['isPremium'] as bool? ?? false,
      purchasedProducts:
          List<String>.from(map['purchasedProducts'] as List? ?? []),
      activeSubscription: map['activeSubscription'] as String?,
      virtualCurrencyBalance: map['virtualCurrencyBalance'] as int? ?? 0,
    );
  }

  /// Konvertiert das Benutzerkonto in eine Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'isPremium': isPremium,
      'purchasedProducts': purchasedProducts,
      'activeSubscription': activeSubscription,
      'virtualCurrencyBalance': virtualCurrencyBalance,
    };
  }

  /// Fügt ein gekauftes Produkt hinzu
  void addPurchasedProduct(String productId) {
    if (!purchasedProducts.contains(productId)) {
      purchasedProducts.add(productId);
    }
  }

  /// Setzt das aktive Abonnement
  void setActiveSubscription(String subscriptionId) {
    activeSubscription = subscriptionId;
    isPremium = true;
  }

  /// Fügt virtuelle Währung hinzu
  void addVirtualCurrency(int amount) {
    virtualCurrencyBalance += amount;
  }

  /// Zieht virtuelle Währung ab
  bool spendVirtualCurrency(int amount) {
    if (virtualCurrencyBalance >= amount) {
      virtualCurrencyBalance -= amount;
      return true;
    }
    return false;
  }

  /// Prüft, ob ein Produkt gekauft wurde
  bool hasProduct(String productId) {
    return purchasedProducts.contains(productId) || isPremium;
  }
}
