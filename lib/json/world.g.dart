// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

World _$WorldFromJson(Map<String, dynamic> json) {
  return World(
    name: json['name'] as String,
    hostname: json['hostname'] as String,
    port: json['port'] as int,
    aliases: (json['aliases'] as List)
        ?.map(
            (e) => e == null ? null : Alias.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    connectCommands: json['connectCommands'] as String,
  )..triggers = (json['triggers'] as List)
      ?.map(
          (e) => e == null ? null : Trigger.fromJson(e as Map<String, dynamic>))
      ?.toList();
}

Map<String, dynamic> _$WorldToJson(World instance) => <String, dynamic>{
      'name': instance.name,
      'hostname': instance.hostname,
      'port': instance.port,
      'connectCommands': instance.connectCommands,
      'aliases': instance.aliases,
      'triggers': instance.triggers,
    };
