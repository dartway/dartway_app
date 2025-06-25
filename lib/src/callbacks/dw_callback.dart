import 'dart:async';

import 'package:dartway_app/dartway_app.dart';
import 'package:dartway_app/src/notifications/domain/dw_ui_notification.dart';
import 'package:flutter/material.dart';

class DwCallback<T> {
  final Future<void> Function() _execute;

  const DwCallback._(this._execute);

  Future<void> call() => _execute();

  factory DwCallback.create(
    FutureOr<T> Function() action, {
    BuildContext? context,
    FutureOr<void> Function(BuildContext mountedContext, T actionResult)?
    followUpIfMountedAction,
    String? onSuccessNotification,
    FutureOr<DwUiNotification?> Function(T)? customNotificationBuilder,
    String? onErrorNotification,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return DwCallback._(() async {
      try {
        final value = await action();

        if ((value != null || null is T) && onSuccessNotification != null) {
          dw.notify.success(onSuccessNotification);
        }

        if (customNotificationBuilder != null) {
          final notification = await customNotificationBuilder(value);
          if (notification != null) {
            dw.notify.custom(notification);
          }
        }

        if (context?.mounted == true && followUpIfMountedAction != null) {
          await followUpIfMountedAction(context!, value);
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
