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

  bool matches(String input) => RegExp(pattern).hasMatch(input);

  String transformInput(String input) {
    if (substitution == null) {
      return null;
    }
    return input.replaceAllMapped(RegExp(pattern), (Match m) {
      String r = substitution;
      for (int i = 0; i <= m.groupCount; i++) {
        r = r.replaceFirst('\\$i', m.group(i));
      }
      return r;
    });
  }
}
