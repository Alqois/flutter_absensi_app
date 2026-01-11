// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_attendance_by_date_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetAttendanceByDateEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAttendanceByDateEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAttendanceByDateEvent()';
}


}

/// @nodoc
class $GetAttendanceByDateEventCopyWith<$Res>  {
$GetAttendanceByDateEventCopyWith(GetAttendanceByDateEvent _, $Res Function(GetAttendanceByDateEvent) __);
}


/// Adds pattern-matching-related methods to [GetAttendanceByDateEvent].
extension GetAttendanceByDateEventPatterns on GetAttendanceByDateEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _GetAttendanceByDate value)?  getAttendanceByDate,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _GetAttendanceByDate() when getAttendanceByDate != null:
return getAttendanceByDate(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _GetAttendanceByDate value)  getAttendanceByDate,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _GetAttendanceByDate():
return getAttendanceByDate(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _GetAttendanceByDate value)?  getAttendanceByDate,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _GetAttendanceByDate() when getAttendanceByDate != null:
return getAttendanceByDate(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( String date)?  getAttendanceByDate,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _GetAttendanceByDate() when getAttendanceByDate != null:
return getAttendanceByDate(_that.date);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( String date)  getAttendanceByDate,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _GetAttendanceByDate():
return getAttendanceByDate(_that.date);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( String date)?  getAttendanceByDate,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _GetAttendanceByDate() when getAttendanceByDate != null:
return getAttendanceByDate(_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _Started implements GetAttendanceByDateEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAttendanceByDateEvent.started()';
}


}




/// @nodoc


class _GetAttendanceByDate implements GetAttendanceByDateEvent {
  const _GetAttendanceByDate(this.date);
  

 final  String date;

/// Create a copy of GetAttendanceByDateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetAttendanceByDateCopyWith<_GetAttendanceByDate> get copyWith => __$GetAttendanceByDateCopyWithImpl<_GetAttendanceByDate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetAttendanceByDate&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,date);

@override
String toString() {
  return 'GetAttendanceByDateEvent.getAttendanceByDate(date: $date)';
}


}

/// @nodoc
abstract mixin class _$GetAttendanceByDateCopyWith<$Res> implements $GetAttendanceByDateEventCopyWith<$Res> {
  factory _$GetAttendanceByDateCopyWith(_GetAttendanceByDate value, $Res Function(_GetAttendanceByDate) _then) = __$GetAttendanceByDateCopyWithImpl;
@useResult
$Res call({
 String date
});




}
/// @nodoc
class __$GetAttendanceByDateCopyWithImpl<$Res>
    implements _$GetAttendanceByDateCopyWith<$Res> {
  __$GetAttendanceByDateCopyWithImpl(this._self, this._then);

  final _GetAttendanceByDate _self;
  final $Res Function(_GetAttendanceByDate) _then;

/// Create a copy of GetAttendanceByDateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? date = null,}) {
  return _then(_GetAttendanceByDate(
null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GetAttendanceByDateState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAttendanceByDateState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAttendanceByDateState()';
}


}

/// @nodoc
class $GetAttendanceByDateStateCopyWith<$Res>  {
$GetAttendanceByDateStateCopyWith(GetAttendanceByDateState _, $Res Function(GetAttendanceByDateState) __);
}


/// Adds pattern-matching-related methods to [GetAttendanceByDateState].
extension GetAttendanceByDateStatePatterns on GetAttendanceByDateState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,TResult Function( _Empty value)?  empty,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _Empty() when empty != null:
return empty(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,required TResult Function( _Empty value)  empty,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);case _Empty():
return empty(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,TResult? Function( _Empty value)?  empty,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _Empty() when empty != null:
return empty(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Attendance attendance)?  loaded,TResult Function( String message)?  error,TResult Function()?  empty,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.attendance);case _Error() when error != null:
return error(_that.message);case _Empty() when empty != null:
return empty();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Attendance attendance)  loaded,required TResult Function( String message)  error,required TResult Function()  empty,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.attendance);case _Error():
return error(_that.message);case _Empty():
return empty();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Attendance attendance)?  loaded,TResult? Function( String message)?  error,TResult? Function()?  empty,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.attendance);case _Error() when error != null:
return error(_that.message);case _Empty() when empty != null:
return empty();case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements GetAttendanceByDateState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAttendanceByDateState.initial()';
}


}




/// @nodoc


class _Loading implements GetAttendanceByDateState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAttendanceByDateState.loading()';
}


}




/// @nodoc


class _Loaded implements GetAttendanceByDateState {
  const _Loaded(this.attendance);
  

 final  Attendance attendance;

/// Create a copy of GetAttendanceByDateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.attendance, attendance) || other.attendance == attendance));
}


@override
int get hashCode => Object.hash(runtimeType,attendance);

@override
String toString() {
  return 'GetAttendanceByDateState.loaded(attendance: $attendance)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $GetAttendanceByDateStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 Attendance attendance
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of GetAttendanceByDateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? attendance = null,}) {
  return _then(_Loaded(
null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as Attendance,
  ));
}


}

/// @nodoc


class _Error implements GetAttendanceByDateState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of GetAttendanceByDateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GetAttendanceByDateState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $GetAttendanceByDateStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of GetAttendanceByDateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Empty implements GetAttendanceByDateState {
  const _Empty();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Empty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAttendanceByDateState.empty()';
}


}




// dart format on
