import 'package:d2batchest/src/data_fetcher.dart';
import 'package:flutter/material.dart';
import 'settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);
  static const routeName = '/settings';
  final SettingsController controller;

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _textEditingController = TextEditingController();
  List<String> filteredTeams = [];
  List<String> allTeams = [];
  initTeams() async {
    allTeams = await fetchAllTeams();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          TextField(
            textAlign: TextAlign.center,
            controller: _textEditingController,
            onChanged: (text) {
              setState(() {
                filteredTeams = allTeams
                    .where((String option) =>
                        option.toLowerCase().contains(text.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search Teams',
              hintText: 'Type to search...',
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTeams.length,
              itemBuilder: (BuildContext context, int index) {
                final selectedTeam = filteredTeams[index];
                return ListTile(
                  dense: false,
                  title: Center(
                    child: Text(selectedTeam),
                  ),
                  trailing:
                      widget.controller.favouriteTeams.contains(selectedTeam)
                          ? const Icon(Icons.star)
                          : const Icon(Icons.star_border),
                  onTap: () {
                    final selectedTeam = filteredTeams[index];
                    if (widget.controller.favouriteTeams
                        .contains(selectedTeam)) {
                      widget.controller.removeFromFavourites(selectedTeam);
                    } else {
                      widget.controller.addToFavourites(selectedTeam);
                    }
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
