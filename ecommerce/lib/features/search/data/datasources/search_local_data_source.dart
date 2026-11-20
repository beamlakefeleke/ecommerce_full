import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Local (SharedPreferences) data source for search history. Synchronous
/// reads; async writes.
abstract class SearchLocalDataSource {
  List<String> getSearchHistory();
  Future<bool> saveSearchHistory(List<String> history);
  Future<bool> clearSearchHistory();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final SharedPreferences sharedPreferences;
  SearchLocalDataSourceImpl({required this.sharedPreferences});

  @override
  List<String> getSearchHistory() =>
      sharedPreferences.getStringList(AppConstants.searchHistory) ?? [];

  @override
  Future<bool> saveSearchHistory(List<String> history) =>
      sharedPreferences.setStringList(AppConstants.searchHistory, history);

  @override
  Future<bool> clearSearchHistory() =>
      sharedPreferences.setStringList(AppConstants.searchHistory, []);
}
