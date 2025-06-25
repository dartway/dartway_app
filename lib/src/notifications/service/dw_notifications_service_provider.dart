import 'package:dartway_app/src/notifications/service/dw_notifications_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dw_notifications_service.dart';

final dwNotificationsServiceProvider = Provider<DwNotificationsService>((ref) {
  final service = DwNotificationsService();
  DwNotificationsController.register(service); // регистрация
  ref.onDispose(() => service.dispose());
  return service;
});
