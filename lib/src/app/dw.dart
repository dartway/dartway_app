import 'dart:async';

import 'package:dartway_app/src/app/configs/dw_config.dart';
import 'package:dartway_app/src/callbacks/dw_callback_old.dart';
import 'package:dartway_app/src/notifications/domain/dw_ui_notification.dart';
import 'package:dartway_app/src/notifications/service/dw_notifications_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'parts/dw_navigation.dart';
part 'parts/dw_notifications.dart';
part 'parts/dw_services.dart';

final dw = _Dw();

class _Dw {
  late final DwConfig _config;

  final notify = _DwNotifications._();
  final services = _DwServices._();
  final navigation = _DwNavigation._();

  Future<bool> init(DwConfig config) async {
    await services._init(config: config);

    _config = config;

    return true;
  }

  void handleError(Object error, StackTrace stackTrace) {
    _config.globalErrorHandler?.call(error, stackTrace);
  }

  bool get isDefaultModelsGetterSetUp => _config.defaultModelGetter != null;

  T getDefaultModel<T>() {
    final getter = _config.defaultModelGetter;

    if (getter == null) {
      throw StateError(
        'DwToolkit.defaultModelGetter is not set. '
        'Please provide it in DwConfig when initializing DwApp',
      );
    }

    return getter<T>();
  }

  DwCallbackOld call<T>(
    FutureOr<T> Function() action, {
    String? onSuccessNotification,
    FutureOr<DwUiNotification> Function(T actionResult)?
    customNotificationBuilder,
    String? onErrorNotification,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return DwCallbackOld<T>.create(
      action,
      onSuccessNotification: onSuccessNotification,
      customNotificationBuilder: customNotificationBuilder,
      onErrorNotification: onErrorNotification,
      onError: onError,
    );
  }

  DwCallbackOld contextCall<T>(
    BuildContext context,
    FutureOr<T> Function() action, {
    required FutureOr<void> Function(
      BuildContext mountedContext,
      T actionResult,
    )?
    followUpIfMountedAction,
    String? onSuccessNotification,
    FutureOr<DwUiNotification> Function(T actionResult)?
    customNotificationBuilder,
    String? onErrorNotification,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return DwCallbackOld<T>.create(
      action,
      context: context,
      onSuccessNotification: onSuccessNotification,
      customNotificationBuilder: customNotificationBuilder,
      onErrorNotification: onErrorNotification,
      onError: onError,
      followUpIfMountedAction: followUpIfMountedAction,
    );
  }
}
