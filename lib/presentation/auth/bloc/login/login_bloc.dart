import 'package:bloc/bloc.dart';
import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDataSource _authRemoteDataSource;

  LoginBloc(this._authRemoteDataSource) : super(const LoginState.initial()) {
    on<LoginEvent>((event, emit) async {
      emit(const LoginState.loading());

      final result =
          await _authRemoteDataSource.login(event.email, event.password);

      result.fold(
        (error) => emit(LoginState.error(error)),
        (authResponse) => emit(LoginState.success(authResponse)),
      );
    });
  }
}
