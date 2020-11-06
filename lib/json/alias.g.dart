// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alias.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alias _$AliasFromJson(Map<String, dynamic> json) {
  return Alias(
    pattern: json['pattern'] as String,
    substitution: json['substitution'] as String,
  );
}

Map<String, dynamic> _$AliasToJson(Alias instance) => <String, dynamic>{
      'pattern': instance.pattern,
      'substitution': instance.substitution,
    };
