part of 'update_user_register_face_bloc.dart';

@freezed
sealed class UpdateUserRegisterFaceEvent
    with _$UpdateUserRegisterFaceEvent {
  const factory UpdateUserRegisterFaceEvent.updateProfileRegisterFace(
    List<double> embedding,
    Uint8List imageBytes,
  ) = _UpdateProfileRegisterFace;
}
