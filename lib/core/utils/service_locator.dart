class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();
  factory ServiceLocator() => instance;
  ServiceLocator._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  void init() {
    _initialized = true;
  }
}
