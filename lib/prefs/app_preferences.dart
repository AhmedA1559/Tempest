import 'package:get_storage/get_storage.dart';

class AppPreferences {
  AppPreferences._internal();

  static final AppPreferences instance = AppPreferences._internal();

  static late final GetStorage _sharedPref;

  GetStorage get sharedPref => _sharedPref;

  static init() async {
    await GetStorage.init();
    _sharedPref = GetStorage();
  }
}
