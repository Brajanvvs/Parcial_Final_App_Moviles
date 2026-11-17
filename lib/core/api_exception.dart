class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.message,
    this.fieldErrors = const {},
  });

  final int status;
  final String message;
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => status == 401;

  @override
  String toString() => message;
}
