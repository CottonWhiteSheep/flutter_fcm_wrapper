class FlutterFCMWrapperRespondException implements Exception {
  final String errorMessage;

  const FlutterFCMWrapperRespondException({
    required this.errorMessage,
  });

  @override
  String toString() {
    return 'FlutterFCMWrapperRespondException{errorMessage: $errorMessage}';
  }
}
