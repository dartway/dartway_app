import 'package:dartway_toolkit/src/configs/dw_services_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DwServices {
  static final DwServices _instance = DwServices._();
  DwServices._();

  static DwServices get i => _instance;

  late SharedPreferences _prefs;
  SharedPreferences get sharedPreferences => _prefs;

  Future<bool> init(DwServicesConfig config) async {
    if (config.useSharedPreferences) {
      _prefs = await SharedPreferences.getInstance();
    }

    return true;
  }
}
