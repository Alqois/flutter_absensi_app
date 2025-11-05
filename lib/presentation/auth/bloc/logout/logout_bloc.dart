import 'package:bloc/bloc.dart';
import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_event.dart';
part 'logout_state.dart';
part 'logout_bloc.freezed.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDataSource _authRemoteDataSource;
  LogoutBloc(
    this._authRemoteDataSource,
  ) : super(const _Initial()) {
    on<_Logout>((event, emit) async{
      emit(const _Loading());
      final result = await _authRemoteDataSource.logout();
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(const _Success()),
      );
    });
  }
}
