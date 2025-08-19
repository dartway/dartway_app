import 'dart:async';

import 'package:dartway_app/dartway_app.dart';
import 'package:flutter/material.dart';

class DwCallback<T> {
  final Future<void> Function(BuildContext context) _execute;

  const DwCallback._(this._execute);

  Future<void> call(BuildContext context) => _execute(context);

  factory DwCallback.create(
    FutureOr<T> Function() action, {
    String? onSuccessNotification,
    String? onErrorNotification,
    FutureOr<DwUiNotification?> Function(T value)? customNotificationBuilder,
    FutureOr<void> Function(BuildContext context, T value)? followUpIfMounted,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return DwCallback._((context) async {
      try {
        final value = await action();

        if (onSuccessNotification != null) {
          dw.notify.success(onSuccessNotification);
        }

        if (customNotificationBuilder != null) {
          final customNotification = await customNotificationBuilder(value);
          if (customNotification != null) {
            dw.notify.custom(customNotification);
          }
        }

        if (followUpIfMounted != null && context.mounted) {
          await followUpIfMounted(context, value);
        }
      } catch (error, stackTrace) {
        if (onErrorNotification != null) {
          dw.notify.error(onErrorNotification);
        }
        onError?.call(error, stackTrace);
        dw.handleError(error, stackTrace);
      }
    });
  }
}
