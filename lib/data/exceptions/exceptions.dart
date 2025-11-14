import 'package:flutter/material.dart';

@immutable
abstract class CustomException implements Exception {
  final String message;
  final String? url;
  final Object? cause;
  final StackTrace? stackTrace;

  const CustomException(this.message, {this.url, this.cause, this.stackTrace});

  @override
  String toString() {
    final b = StringBuffer(message);
    if (url != null) b.write(' | url=$url');
    if (cause != null) b.write(' | cause=$cause');
    return b.toString();
  }
}

class JsonDecodeException extends CustomException {
  const JsonDecodeException(
    super.message, {
    super.url,
    super.cause,
    super.stackTrace,
  });
}

class GithubException extends CustomException {
  const GithubException(
    super.message, {
    super.url,
    super.cause,
    super.stackTrace,
  });
}

class NetworkException extends CustomException {
  final int? statusCode;
  const NetworkException(
    super.message, {
    this.statusCode,
    super.url,
    super.cause,
    super.stackTrace,
  });
}

class CertainException extends CustomException {
  final int? statusCode;
  const CertainException(
    super.message, {
    this.statusCode,
    super.url,
    super.cause,
    super.stackTrace,
  });
}
