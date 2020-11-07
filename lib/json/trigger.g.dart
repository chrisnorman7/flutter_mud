// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trigger _$TriggerFromJson(Map<String, dynamic> json) {
  return Trigger(
    pattern: json['pattern'] as String,
    substitution: json['substitution'] as String,
    sound: json['sound'] as String,
    active: json['active'] as bool,
  );
}

Map<String, dynamic> _$TriggerToJson(Trigger instance) => <String, dynamic>{
      'pattern': instance.pattern,
      'substitution': instance.substitution,
      'sound': instance.sound,
      'active': instance.active,
    };
