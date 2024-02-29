import 'package:d2batchest/src/data_fetcher.dart';
import 'package:d2batchest/src/match.dart';
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import 'list_builder.dart';

class SampleItemListView extends StatefulWidget {
  final SettingsController controller;

  SampleItemListView({
    required this.controller,
    Key? key,
  }) : super(key: key);

  static const routeName = '/';

  @override
  _SampleItemListViewState createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  late List<DMatch> filteredItems;
  List<DMatch>? recentItems;

  @override
  void initState() {
    super.initState();
  }

  fetchData() async {
    recentItems = await fetchUpcomingMatches();
    List<String> updatedFavouriteTeams =
        await widget.controller.getPreferences();
    return {
      'recentItems': recentItems,
      'updatedFavouriteTeams': updatedFavouriteTeams,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Favourites'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            fetchData();
          });
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading indicator while waiting for preferences
          } else {
            if (snapshot.data == null) {
              return const Text('Error');
            }
            Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
            List<String> updatedFavouriteTeams = data['updatedFavouriteTeams'];
            recentItems = data['recentItems'];

            recentItems = recentItems!
                .where((item) => item.datetime
                    .isAfter(DateTime.now().subtract(const Duration(hours: 1))))
                .toSet()
                .toList();
            filteredItems = recentItems!
                .where((item) =>
                    (updatedFavouriteTeams.contains(item.team1Name) ||
                        updatedFavouriteTeams.contains(item.team2Name)))
                .toList();
            return Column(
              children: [
                Expanded(child: createList(filteredItems, notify: true)),
                TextButton(
                  onPressed: () async {
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                  child: const Text('Edit Favourites'),
                ),
                Expanded(child: createList(recentItems)),
              ],
            );
          }
        },
      ),
    );
  }
}
