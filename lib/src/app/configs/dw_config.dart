import 'package:flutter/material.dart';

class DwConfig {
  const DwConfig({
    this.globalErrorHandler = debugInfoErrorHandler,
    this.defaultModelGetter,
    this.useSharedPreferences = true,
  });

  final bool useSharedPreferences;

  final void Function(Object error, StackTrace stackTrace)? globalErrorHandler;
  final T Function<T>()? defaultModelGetter;

  static debugInfoErrorHandler(Object error, StackTrace stackTrace) =>
      debugPrint('$error\n$stackTrace');
}
