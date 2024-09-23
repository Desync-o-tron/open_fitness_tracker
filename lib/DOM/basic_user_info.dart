import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
part 'basic_user_info.g.dart';

/*
to generate new g.dart files run:
dart run build_runner build --delete-conflicting-outputs
to do it continuously run:
dart run build_runner watch --delete-conflicting-outputs
*/

class BasicUserInfoCubit extends Cubit<BasicUserInfo> {
  BasicUserInfoCubit() : super(BasicUserInfo());

  void set(BasicUserInfo userInfo) {
    myStorage.setBasicUserInfo(userInfo);
    emit(userInfo);
  }

  void get() async {
    var userInfo = await myStorage.getBasicUserInfo();
    emit(userInfo);
  }
}

@JsonSerializable()
class BasicUserInfo {
  String? searchableUsername;
  MassUnits preferredMassUnit = MassUnits.lb;
  DistanceUnits preferredDistanceUnit = DistanceUnits.miles;
  BasicUserInfo({
    this.searchableUsername,
    this.preferredDistanceUnit = DistanceUnits.miles,
    this.preferredMassUnit = MassUnits.lb,
  });

  factory BasicUserInfo.fromJson(Map<String, dynamic> json) =>
      _$BasicUserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BasicUserInfoToJson(this);
}
