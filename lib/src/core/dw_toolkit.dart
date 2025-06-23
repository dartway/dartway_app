import '../configs/dw_toolkit_config.dart';

class DwToolkit {
  static late final DwToolkitConfig _config;

  static bool init(DwToolkitConfig config) {
    _config = config;
    return true;
  }

  static DwToolkitConfig get config => _config;

  static void handleError(Object error, StackTrace stackTrace) {
    _config.globalErrorHandler?.call(error, stackTrace);
  }

  static bool get isDefaultModelsGetterSetUp =>
      _config.defaultModelGetter != null;

  static T getDefaultModel<T>() {
    final getter = _config.defaultModelGetter;

    if (getter == null) {
      throw StateError(
        'DwToolkit.defaultModelGetter is not set. '
        'Please provide it in DwToolkitConfig when initializing DartWayApp',
      );
    }

    return getter<T>();
  }
}
