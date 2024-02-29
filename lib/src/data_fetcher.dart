import 'dart:convert';
import 'package:d2batchest/src/match.dart';
import 'package:http/http.dart' as http;

const String mockUrl = 'https://api.opendota.com/api';
const String baseUrl = 'https://{yours}.run.app';

Future<List<DMatch>> fetchUpcomingMatches() async {
  final response = await http.get(Uri.parse('$baseUrl/upcoming_matches'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    List<DMatch> matches =
        jsonData.take(200).map((d) => DMatch.fromJson(d)).toList();
    return matches;
  } else {
    throw Exception('Failed to load Matches');
  }
}

Future<List<String>> fetchAllTeams() async {
  final response = await http.get(Uri.parse('$baseUrl/all_teams'));

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the data
    final dynamic jsonData = json.decode(response.body);
    List<String> teams = [];
    jsonData.forEach((key, value) {
      if (value is String) {
        teams.add(value);
      }
    });
    return teams;
  } else {
    throw Exception('Failed to load Teams');
  }
}
