/// Provides the [Trigger] class.
import 'package:json_annotation/json_annotation.dart';

part 'trigger.g.dart';

@JsonSerializable()
class Trigger {
  Trigger({this.pattern, this.substitution, this.sound, this.active}) {
    active ??= true;
  }

  factory Trigger.fromJson(Map<String, dynamic> json) =>
      _$TriggerFromJson(json);

  String pattern;
  String substitution;
  String sound;
  bool active;

  Map<String, dynamic> toJson() => _$TriggerToJson(this);
}
