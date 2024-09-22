import 'package:json_annotation/json_annotation.dart';
part 'basic_user_info.g.dart';

/*
to generate new g.dart files run:
dart run build_runner build --delete-conflicting-outputs
to do it continuously run:
dart run build_runner watch --delete-conflicting-outputs
*/

@JsonSerializable()
class BasicUserInfo {
  String? searchableUsername;
  MassUnits preferredMassUnit = MassUnits.lb;
  DistanceUnits preferredDistanceUnit = DistanceUnits.miles;
  BasicUserInfo({
    this.searchableUsername,
    required this.preferredDistanceUnit,
    required this.preferredMassUnit,
  });

  factory BasicUserInfo.fromJson(Map<String, dynamic> json) =>
      _$BasicUserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BasicUserInfoToJson(this);
}

enum MassUnits {
  kg('kg'),
  lb('lb');

  const MassUnits(this.text);
  final String text;
}

enum DistanceUnits {
  miles('mi'),
  feet('ft'),
  kilometers('km');

  const DistanceUnits(this.text);
  final String text;
}
