import 'package:flutter/cupertino.dart';

abstract class ApplicationError implements Exception {
  ApplicationError({required this.message}) {
    _showError(message);
  }

  final String message;

  _showError(String message) {
    FlutterError.presentError(FlutterErrorDetails(exception: message));
  }
}
