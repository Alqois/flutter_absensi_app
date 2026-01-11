import 'package:bloc/bloc.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/checkinout_response_model.dart';
import 'package:flutter_absensi_app/presentation/home/models/absent_status.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_checkin_page.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'is_checkedin_event.dart';
part 'is_checkedin_state.dart';
part 'is_checkedin_bloc.freezed.dart';

class IsCheckedinBloc extends Bloc<IsCheckedinEvent, IsCheckedinState> {
  final AttendanceRemoteDatasource datasource;

  IsCheckedinBloc(this.datasource) : super(const _Initial()) {
    on<IsCheckedinEvent>((event, emit) async {
      emit(const _Loading());

      final result = await datasource.IsCheckedin();

      result.fold(
        (error) => emit(_Error(error)),
        (status) => emit(_Success(status)),
      );
    });
  }
}

