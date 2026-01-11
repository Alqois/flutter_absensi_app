import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/models/response/user_response_model.dart';

part 'update_user_register_face_event.dart';
part 'update_user_register_face_state.dart';
part 'update_user_register_face_bloc.freezed.dart';

class UpdateUserRegisterFaceBloc
    extends Bloc<UpdateUserRegisterFaceEvent, UpdateUserRegisterFaceState> {
  final AuthRemoteDataSource authRemoteDataSource;

  UpdateUserRegisterFaceBloc(this.authRemoteDataSource)
      : super(const _Initial()) {
    on<_UpdateProfileRegisterFace>((event, emit) async {
      emit(const _Loading());
    
      final result = await authRemoteDataSource.updateProfileRegisterFace(
        event.embedding,
        event.imageBytes,
      );
    
      if (result.isLeft()) {
        emit(_Error(result.swap().getOrElse(() => 'Unknown error')));
        return;
      }
    
      final user = result.getOrElse(() => throw Exception('User null'));
    
      // Simpan embedding
      await AuthLocalDataSource().updateFaceEmbedding(event.embedding);
    
      // Emit sukses
      emit(_Success(user));
    });

  }
}
