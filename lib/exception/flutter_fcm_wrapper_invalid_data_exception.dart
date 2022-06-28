class FlutterFCMWrapperInvalidDataException implements Exception {
  final String errorMessage;

  const FlutterFCMWrapperInvalidDataException({
    required this.errorMessage,
  });

  @override
  String toString() {
    return 'FlutterFCMWrapperInvalidDataException{errorMessage: $errorMessage}';
  }
}
