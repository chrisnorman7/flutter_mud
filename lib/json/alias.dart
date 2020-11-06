/// Provides the [Alias] class.
import 'package:json_annotation/json_annotation.dart';

part 'alias.g.dart';

@JsonSerializable()
class Alias {
  Alias({this.pattern, this.substitution});

  factory Alias.fromJson(Map<String, dynamic> json) => _$AliasFromJson(json);

  String pattern;
  String substitution;

  Map<String, dynamic> toJson() => _$AliasToJson(this);
}
