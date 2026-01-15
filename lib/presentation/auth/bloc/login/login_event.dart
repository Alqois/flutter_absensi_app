part of 'login_bloc.dart';

@freezed
sealed class LoginEvent with _$LoginEvent {
  const factory LoginEvent({
    required String email,
    required String password,
  }) = _LoginEvent;
}
