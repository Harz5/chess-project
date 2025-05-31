import 'package:flutter/material.dart';
import '../services/performance_optimization_service.dart';

/// Provider für die Verwaltung der Performance-Optimierung
class PerformanceProvider extends ChangeNotifier {
  final PerformanceOptimizationService _performanceService = PerformanceOptimizationService();
  
  // Performance-Einstellungen
  bool _enableLazyLoading = true;
  bool _enableCaching = true;
  bool _enableMemoization = true;
  bool _enableDebounce = true;
  
  // Performance-Metriken
  Map<String, dynamic> _performanceMetrics = {};
  
  // Getter
  bool get enableLazyLoading => _enableLazyLoading;
  bool get enableCaching => _enableCaching;
  bool get enableMemoization => _enableMemoization;
  bool get enableDebounce => _enableDebounce;
  Map<String, dynamic> get performanceMetrics => _performanceMetrics;
  
  PerformanceProvider() {
    _initializeService();
  }
  
  /// Initialisiert den Performance-Service
  Future<void> _initializeService() async {
    _performanceService.initialize();
    _updateMetrics();
  }
  
  /// Aktualisiert die Performance-Metriken
  void _updateMetrics() {
    _performanceMetrics = _performanceService.getPerformanceMetrics();
    notifyListeners();
  }
  
  /// Aktiviert oder deaktiviert Lazy Loading
  void setLazyLoading(bool enabled) {
    _enableLazyLoading = enabled;
    notifyListeners();
  }
  
  /// Aktiviert oder deaktiviert Caching
  void setCaching(bool enabled) {
    _enableCaching = enabled;
    if (!enabled) {
      _performanceService.clearCache();
    }
    notifyListeners();
  }
  
  /// Aktiviert oder deaktiviert Memoization
  void setMemoization(bool enabled) {
    _enableMemoization = enabled;
    notifyListeners();
  }
  
  /// Aktiviert oder deaktiviert Debounce
  void setDebounce(bool enabled) {
    _enableDebounce = enabled;
    notifyListeners();
  }
  
  /// Misst die Performance einer Operation
  T measureOperation<T>(String operationName, T Function() operation) {
    return _performanceService.measureOperation(operationName, operation);
  }
  
  /// Implementiert Memoization für rechenintensive Funktionen
  T memoize<T>(String key, T Function() computation) {
    if (_enableMemoization) {
      return _performanceService.memoize(key, computation);
    } else {
      return computation();
    }
  }
  
  /// Führt eine Operation mit Debounce aus
  void debounce(Duration duration, VoidCallback operation) {
    if (_enableDebounce) {
      _performanceService.debounce(duration, operation);
    } else {
      operation();
    }
  }
  
  /// Optimiert die Bildwiedergabe durch Lazy Loading
  Widget optimizeImageLoading(String imageUrl, {double? width, double? height}) {
    if (_enableLazyLoading) {
      return _performanceService.optimizeImageLoading(imageUrl, width: width, height: height);
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
      );
    }
  }
  
  /// Optimiert Listen durch Lazy Loading
  Widget optimizeListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required String listKey,
  }) {
    if (_enableLazyLoading) {
      return _performanceService.optimizeListView(
        items: items,
        itemBuilder: itemBuilder,
        listKey: listKey,
      );
    } else {
      return ListView.builder(
        key: Key(listKey),
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      );
    }
  }
  
  /// Reduziert die Neuberechnungen durch Verwendung von const Widgets
  Widget createConstWidget(Widget child) {
    return _performanceService.createConstWidget(child);
  }
  
  @override
  void dispose() {
    _performanceService.dispose();
    super.dispose();
  }
}
