import 'package:flutter/material.dart';

import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          supportedLocales: const [
            Locale('en', ''),
          ],
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(),
          ),
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case SampleItemListView.routeName:
                  default:
                    return SampleItemListView(controller: settingsController);
                }
              },
            );
          },
        );
      },
    );
  }
}
