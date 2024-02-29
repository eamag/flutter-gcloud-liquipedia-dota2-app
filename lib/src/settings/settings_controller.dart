import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsController with ChangeNotifier {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  List<String> favouriteTeams = [];
  List<String> filteredTeams = [];

  void addToFavourites(String team) async {
    if (!favouriteTeams.contains(team)) {
      favouriteTeams.add(team);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favouriteTeams', favouriteTeams);
      await messaging.subscribeToTopic(convertToValidTopic(team));
    }
  }

  void removeFromFavourites(String team) async {
    if (favouriteTeams.contains(team)) {
      favouriteTeams.remove(team);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favouriteTeams', favouriteTeams);
      await messaging.unsubscribeFromTopic(convertToValidTopic(team));
    }
  }

  Future getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favouriteTeams = prefs.getStringList('favouriteTeams') ?? [];
    return favouriteTeams;
  }
}

String convertToValidTopic(String input) {
  // Define the correct regular expression pattern
  RegExp regex = RegExp(r'[^a-zA-Z0-9-_.~%]');
  // Replace invalid characters with underscores
  String result = input.replaceAll(regex, '_');
  // Remove leading and trailing underscores
  result = result.replaceAll(RegExp(r'^_+|_+$'), '');

  return result;
}
