import 'package:flutter/material.dart';

class DwToolkitConfig {
  const DwToolkitConfig({
    this.globalErrorHandler = debugInfoErrorHandler,
    this.defaultModelGetter,
  });

  final void Function(Object error, StackTrace stackTrace)? globalErrorHandler;
  final T Function<T>()? defaultModelGetter;

  static debugInfoErrorHandler(Object error, StackTrace stackTrace) =>
      debugPrint('$error\n$stackTrace');
}
