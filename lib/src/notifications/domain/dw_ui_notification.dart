enum DwUiNotificationType { info, success, warning, error }

class DwUiNotification {
  final String message;
  final DwUiNotificationType type;
  final Duration duration;

  DwUiNotification({
    required this.message,
    required this.type,
    required this.duration,
  });
}
