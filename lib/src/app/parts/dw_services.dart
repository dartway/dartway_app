part of '../dw.dart';

class _DwServices {
  _DwServices._();

  // static final _DwServices _instance = _DwServices._();

  // static _DwServices get i => _instance;

  late SharedPreferences _prefs;
  SharedPreferences get sharedPreferences => _prefs;

  _init({required DwConfig config}) async {
    if (config.useSharedPreferences) {
      _prefs = await SharedPreferences.getInstance();
    }
  }
}
