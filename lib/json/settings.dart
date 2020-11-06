/// Provides the [Settings] class.
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'world.dart';

part 'settings.g.dart';

const String _key = 'settings';

@JsonSerializable()
class Settings {
  Settings({this.worlds}) {
    worlds ??= <World>[
      World(name: 'Miriani', hostname: 'toastsoft.net', port: 1234),
      World(name: 'Valhalla', hostname: 'valhalla.com', port: 4242),
      World(name: 'ChatMUD', hostname: 'chatmud.com', port: 7777),
      World(name: 'LambdaMOO', hostname: 'lambda.moo.mud.org', port: 8888)
    ];
  }

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  List<World> worlds;

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  Future<void> save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String s = jsonEncode(this);
    prefs.setString(_key, s);
  }

  static Future<Settings> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String s = prefs.getString(_key);
    if (s == null) {
      return Settings();
    }
    final dynamic json = jsonDecode(s);
    return Settings.fromJson(json as Map<String, dynamic>);
  }

  void sortWorlds() {
    worlds.sort((World a, World b) => a.name.compareTo(b.name));
  }
}
