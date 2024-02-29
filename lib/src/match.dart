class DMatch {
  String team1;
  String team1Name;
  String team1Href;
  String team2;
  String team2Name;
  String team2Href;
  DateTime datetime;
  String? team1ImageUrl;
  String? team2ImageUrl;

  DMatch({
    required this.team1,
    required this.team1Name,
    required this.team1Href,
    required this.team2,
    required this.team2Name,
    required this.team2Href,
    required this.datetime,
    this.team1ImageUrl,
    this.team2ImageUrl,
  });

  factory DMatch.fromJson(Map<String, dynamic> json) {
    return DMatch(
      team1: json['team1'] ?? '',
      team1Name: json['team1_name'] ?? '',
      team1Href: json['team1_href'] ?? '',
      team2: json['team2'] ?? '',
      team2Name: json['team2_name'] ?? '',
      team2Href: json['team2_href'] ?? '',
      datetime: DateTime.fromMillisecondsSinceEpoch(
          int.parse(json['datetime']) * 1000),
      team1ImageUrl: json['team1_image_url'],
      team2ImageUrl: json['team2_image_url'],
    );
  }

  @override
  String toString() {
    return 'DMatch: {team1: $team1, team1Name: $team1Name, team1Href: $team1Href, team2: $team2, team2Name: $team2Name, team2Href: $team2Href, datetime: $datetime, team1ImageUrl: $team1ImageUrl, team2ImageUrl: $team2ImageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DMatch &&
          runtimeType == other.runtimeType &&
          team1 == other.team1 &&
          team2 == other.team2 &&
          datetime == other.datetime;

  @override
  int get hashCode => team1.hashCode ^ team2.hashCode ^ datetime.hashCode;
}
