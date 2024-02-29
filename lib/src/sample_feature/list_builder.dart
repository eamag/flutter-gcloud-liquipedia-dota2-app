// import 'package:d2batchest/src/local_notifs.dart';
import 'dart:async';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:d2batchest/src/match.dart';
import 'package:flutter/material.dart';

const String baseUrl = 'https://liquipedia.net/';

createList(items, {bool notify = false}) {
  return ListView.builder(
    itemCount: items.length,
    shrinkWrap: true,
    scrollDirection: Axis.vertical,
    itemBuilder: (BuildContext context, int index) {
      DMatch item = items[index];

      return ListTile(
        contentPadding: const EdgeInsets.all(0), // Remove default padding
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Center(
                child: Text(item.team1Name.split(' (page does not exist)')[0]),
              ),
            ),
            Flexible(
              child: FractionallySizedBox(
                widthFactor: 0.2,
                child: item.team1ImageUrl != null
                    ? Center(
                        child: CachedNetworkImage(
                          imageUrl: baseUrl + item.team1ImageUrl!,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      )
                    : Container(),
              ),
            ),
            Flexible(
              child: FractionallySizedBox(
                widthFactor: 0.2,
                child: item.team2ImageUrl != null
                    ? Center(
                        child: CachedNetworkImage(
                          imageUrl: baseUrl + item.team2ImageUrl!,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      )
                    : Container(),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(item.team2Name.split(' (page does not exist)')[0]),
              ),
            ),
          ],
        ),

        subtitle: CountdownTimer(matchTime: item.datetime),
        onTap: () {
          createCalendarEvent(item);
        },
      );
    },
  );
}

class CountdownTimer extends StatefulWidget {
  final DateTime matchTime;

  CountdownTimer({required this.matchTime});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _timeDifference = const Duration();

  @override
  void initState() {
    super.initState();
    _calculateTimeDifference();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeDifference();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateTimeDifference() {
    setState(() {
      _timeDifference = widget.matchTime.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    int hours = _timeDifference.inHours;
    int minutes = _timeDifference.inMinutes.remainder(60);
    int seconds = _timeDifference.inSeconds.remainder(60);

    return Center(
      child: Text(
        'In $hours hours $minutes minutes $seconds seconds',
      ),
    );
  }
}

Future<void> createCalendarEvent(DMatch match) async {
  final String title = '${match.team1Name} vs. ${match.team2Name}';
  final String description = 'Match details...\n'
      '- Team 1: ${match.team1Name} (${match.team1Href})\n'
      '- Team 2: ${match.team2Name} (${match.team2Href})';
  final DateTime startTime = match.datetime;
  final DateTime endTime = startTime
      .add(const Duration(hours: 1)); // Assuming match duration is 1 hour

  final Event event = Event(
    title: title,
    description: description,
    location: '', // Optional location
    startDate: startTime,
    endDate: endTime,
    iosParams: const IOSParams(
      reminder: Duration(minutes: 60), // Set reminder for 1 hour
    ),
  );

  await Add2Calendar.addEvent2Cal(event);
}
