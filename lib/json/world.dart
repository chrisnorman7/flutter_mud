import 'package:json_annotation/json_annotation.dart';

import 'trigger.dart';

part 'world.g.dart';

@JsonSerializable()
class World {
  World(
      {this.name,
      this.hostname,
      this.port,
      this.aliases,
      this.connectCommands}) {
    triggers ??= <Trigger>[];
    aliases ??= <Trigger>[];
  }

  factory World.fromJson(Map<String, dynamic> json) => _$WorldFromJson(json);

  String name;
  String hostname;
  int port;
  String connectCommands;

  List<Trigger> aliases;
  List<Trigger> triggers;

  Map<String, dynamic> toJson() => _$WorldToJson(this);
}
