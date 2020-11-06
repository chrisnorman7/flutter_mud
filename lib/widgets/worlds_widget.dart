/// Provides the [WorldsWidget] class.
import 'package:flutter/material.dart';

import '../json/settings.dart';
import '../json/world.dart';
import 'add_world_widget.dart';
import 'world_widget.dart';

class WorldsWidget extends StatefulWidget {
  @override
  WorldsWidgetState createState() => WorldsWidgetState();
}

class WorldsWidgetState extends State<WorldsWidget> {
  Settings _settings;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_settings == null) {
      child = const Text('Loading...');
    } else if (_settings.worlds.isEmpty) {
      child = const Text('No worlds have been created yet.');
    } else {
      child = ListView.builder(
        itemCount: _settings.worlds.length,
        itemBuilder: (BuildContext context, int index) {
          final World world = _settings.worlds[index];
          return ListTile(
            title: Text(world.name),
            subtitle: Text('${world.hostname}:${world.port}'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<WorldWidget>(
                      builder: (BuildContext context) => WorldWidget(world)));
            },
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter MUD'),
        actions: <Widget>[
          FloatingActionButton(
            tooltip: 'Add World',
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<AddWorldWidget>(
                      builder: (BuildContext context) =>
                          AddWorldWidget(_settings, () => setState(() {}))));
            },
          )
        ],
      ),
      body: child,
    );
  }

  Future<void> loadSettings() async {
    final Settings s = await Settings.load();
    setState(() => _settings = s);
  }
}
