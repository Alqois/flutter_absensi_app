import 'package:bloc/bloc.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDataSource _authRemoteDataSource;
  LoginBloc(
    this._authRemoteDataSource,
  ) : super(const _Initial()) {
    on<_Login>((event, emit) async {
      emit(const _Loading());
      final result = await _authRemoteDataSource.login(event.email, event.password);
    
      result.fold(
        (error) => emit(_Error(error)),
        (authResponse) async {
          
          // SIMPAN AUTH LOCAL
          await AuthLocalDataSource().saveAuthData(authResponse.toJson());
    
          emit(_Success(authResponse));
        },
      );
    });
  }
}
