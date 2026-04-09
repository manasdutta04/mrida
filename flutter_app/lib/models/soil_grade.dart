import 'package:json_annotation/json_annotation.dart';

enum SoilGrade {
  @JsonValue('A')
  a,
  @JsonValue('B')
  b,
  @JsonValue('C')
  c,
  @JsonValue('D')
  d,
}
