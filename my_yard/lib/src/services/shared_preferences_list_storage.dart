// Copyright (c) [2025] Johan Scheepers/ChatGPT
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A generic class to handle saving and loading lists of objects
/// to and from SharedPreferences.
class SharedPreferencesListStorage<T> {
  /// Creates a [SharedPreferencesListStorage] instance.
  ///
  /// [prefs]: The SharedPreferences instance to use.
  /// [key]: The key under which the list will be stored in SharedPreferences.
  /// [decode]: A function that takes a decoded JSON object (dynamic) and returns
  ///           an object of type [T].
  /// [encode]: A function that takes an object of type [T] and returns a JSON-encodable
  ///           object (dynamic).
  SharedPreferencesListStorage(
      {required SharedPreferences prefs,
      required String key,
      required T Function(dynamic json) decode,
      required dynamic Function(T object) encode})
      : _prefs = prefs,
        _key = key,
        _decode = decode,
        _encode = encode;

  final SharedPreferences _prefs;
  final String _key;
  final T Function(dynamic) _decode;
  final dynamic Function(T) _encode;

  /// Loads the list of objects from SharedPreferences.
  ///
  /// Returns an empty list if no data is found or if decoding fails.
  Future<List<T>> loadList() async {
    final jsonStringList = _prefs.getStringList(_key) ?? [];
    try {
      return jsonStringList.map((jsonString) {
        final decodedJson = jsonDecode(jsonString);
        return _decode(decodedJson);
      }).toList();
    } catch (e) {
      // Log the error in a real application
      print('Error loading list from SharedPreferences for key "$_key": $e');
      // Optionally clear the corrupt data
      // await _prefs.remove(_key);
      return [];
    }
  }

  /// Saves the list of objects to SharedPreferences.
  Future<void> saveList(List<T> list) async {
    try {
      final jsonStringList =
          list.map((item) => jsonEncode(_encode(item))).toList();
      await _prefs.setStringList(_key, jsonStringList);
    } catch (e) {
      // Log the error in a real application
      print('Error saving list to SharedPreferences for key "$_key": $e');
    }
  }
}
