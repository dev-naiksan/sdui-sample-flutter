extension MapEx on Map<String, dynamic> {
  T getOr<T>(String key, T orElse) {
    return this[key] ?? orElse;
  }

  String getOrEmpty(String key) {
    return this[key] ?? "";
  }
}
