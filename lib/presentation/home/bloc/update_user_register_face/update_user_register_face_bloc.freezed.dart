// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_user_register_face_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateUserRegisterFaceEvent {

 List<double> get embedding; Uint8List get imageBytes;
/// Create a copy of UpdateUserRegisterFaceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserRegisterFaceEventCopyWith<UpdateUserRegisterFaceEvent> get copyWith => _$UpdateUserRegisterFaceEventCopyWithImpl<UpdateUserRegisterFaceEvent>(this as UpdateUserRegisterFaceEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserRegisterFaceEvent&&const DeepCollectionEquality().equals(other.embedding, embedding)&&const DeepCollectionEquality().equals(other.imageBytes, imageBytes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(embedding),const DeepCollectionEquality().hash(imageBytes));

@override
String toString() {
  return 'UpdateUserRegisterFaceEvent(embedding: $embedding, imageBytes: $imageBytes)';
}


}

/// @nodoc
abstract mixin class $UpdateUserRegisterFaceEventCopyWith<$Res>  {
  factory $UpdateUserRegisterFaceEventCopyWith(UpdateUserRegisterFaceEvent value, $Res Function(UpdateUserRegisterFaceEvent) _then) = _$UpdateUserRegisterFaceEventCopyWithImpl;
@useResult
$Res call({
 List<double> embedding, Uint8List imageBytes
});




}
/// @nodoc
class _$UpdateUserRegisterFaceEventCopyWithImpl<$Res>
    implements $UpdateUserRegisterFaceEventCopyWith<$Res> {
  _$UpdateUserRegisterFaceEventCopyWithImpl(this._self, this._then);

  final UpdateUserRegisterFaceEvent _self;
  final $Res Function(UpdateUserRegisterFaceEvent) _then;

/// Create a copy of UpdateUserRegisterFaceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? embedding = null,Object? imageBytes = null,}) {
  return _then(_self.copyWith(
embedding: null == embedding ? _self.embedding : embedding // ignore: cast_nullable_to_non_nullable
as List<double>,imageBytes: null == imageBytes ? _self.imageBytes : imageBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateUserRegisterFaceEvent].
extension UpdateUserRegisterFaceEventPatterns on UpdateUserRegisterFaceEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _UpdateProfileRegisterFace value)?  updateProfileRegisterFace,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProfileRegisterFace() when updateProfileRegisterFace != null:
return updateProfileRegisterFace(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _UpdateProfileRegisterFace value)  updateProfileRegisterFace,}){
final _that = this;
switch (_that) {
case _UpdateProfileRegisterFace():
return updateProfileRegisterFace(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _UpdateProfileRegisterFace value)?  updateProfileRegisterFace,}){
final _that = this;
switch (_that) {
case _UpdateProfileRegisterFace() when updateProfileRegisterFace != null:
return updateProfileRegisterFace(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<double> embedding,  Uint8List imageBytes)?  updateProfileRegisterFace,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProfileRegisterFace() when updateProfileRegisterFace != null:
return updateProfileRegisterFace(_that.embedding,_that.imageBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<double> embedding,  Uint8List imageBytes)  updateProfileRegisterFace,}) {final _that = this;
switch (_that) {
case _UpdateProfileRegisterFace():
return updateProfileRegisterFace(_that.embedding,_that.imageBytes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<double> embedding,  Uint8List imageBytes)?  updateProfileRegisterFace,}) {final _that = this;
switch (_that) {
case _UpdateProfileRegisterFace() when updateProfileRegisterFace != null:
return updateProfileRegisterFace(_that.embedding,_that.imageBytes);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateProfileRegisterFace implements UpdateUserRegisterFaceEvent {
  const _UpdateProfileRegisterFace(final  List<double> embedding, this.imageBytes): _embedding = embedding;
  

 final  List<double> _embedding;
@override List<double> get embedding {
  if (_embedding is EqualUnmodifiableListView) return _embedding;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_embedding);
}

@override final  Uint8List imageBytes;

/// Create a copy of UpdateUserRegisterFaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProfileRegisterFaceCopyWith<_UpdateProfileRegisterFace> get copyWith => __$UpdateProfileRegisterFaceCopyWithImpl<_UpdateProfileRegisterFace>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProfileRegisterFace&&const DeepCollectionEquality().equals(other._embedding, _embedding)&&const DeepCollectionEquality().equals(other.imageBytes, imageBytes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_embedding),const DeepCollectionEquality().hash(imageBytes));

@override
String toString() {
  return 'UpdateUserRegisterFaceEvent.updateProfileRegisterFace(embedding: $embedding, imageBytes: $imageBytes)';
}


}

/// @nodoc
abstract mixin class _$UpdateProfileRegisterFaceCopyWith<$Res> implements $UpdateUserRegisterFaceEventCopyWith<$Res> {
  factory _$UpdateProfileRegisterFaceCopyWith(_UpdateProfileRegisterFace value, $Res Function(_UpdateProfileRegisterFace) _then) = __$UpdateProfileRegisterFaceCopyWithImpl;
@override @useResult
$Res call({
 List<double> embedding, Uint8List imageBytes
});




}
/// @nodoc
class __$UpdateProfileRegisterFaceCopyWithImpl<$Res>
    implements _$UpdateProfileRegisterFaceCopyWith<$Res> {
  __$UpdateProfileRegisterFaceCopyWithImpl(this._self, this._then);

  final _UpdateProfileRegisterFace _self;
  final $Res Function(_UpdateProfileRegisterFace) _then;

/// Create a copy of UpdateUserRegisterFaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? embedding = null,Object? imageBytes = null,}) {
  return _then(_UpdateProfileRegisterFace(
null == embedding ? _self._embedding : embedding // ignore: cast_nullable_to_non_nullable
as List<double>,null == imageBytes ? _self.imageBytes : imageBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

/// @nodoc
mixin _$UpdateUserRegisterFaceState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserRegisterFaceState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserRegisterFaceState()';
}


}

/// @nodoc
class $UpdateUserRegisterFaceStateCopyWith<$Res>  {
$UpdateUserRegisterFaceStateCopyWith(UpdateUserRegisterFaceState _, $Res Function(UpdateUserRegisterFaceState) __);
}


/// Adds pattern-matching-related methods to [UpdateUserRegisterFaceState].
extension UpdateUserRegisterFaceStatePatterns on UpdateUserRegisterFaceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Error value)?  error,TResult Function( _Success value)?  success,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Error() when error != null:
return error(_that);case _Success() when success != null:
return success(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Error value)  error,required TResult Function( _Success value)  success,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Error():
return error(_that);case _Success():
return success(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Error value)?  error,TResult? Function( _Success value)?  success,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Error() when error != null:
return error(_that);case _Success() when success != null:
return success(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String message)?  error,TResult Function( User user)?  success,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Error() when error != null:
return error(_that.message);case _Success() when success != null:
return success(_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function( User user)  success,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Error():
return error(_that.message);case _Success():
return success(_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function( User user)?  success,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Error() when error != null:
return error(_that.message);case _Success() when success != null:
return success(_that.user);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements UpdateUserRegisterFaceState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserRegisterFaceState.initial()';
}


}




/// @nodoc


class _Loading implements UpdateUserRegisterFaceState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserRegisterFaceState.loading()';
}


}




/// @nodoc


class _Error implements UpdateUserRegisterFaceState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of UpdateUserRegisterFaceState
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
  return 'UpdateUserRegisterFaceState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $UpdateUserRegisterFaceStateCopyWith<$Res> {
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

/// Create a copy of UpdateUserRegisterFaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Success implements UpdateUserRegisterFaceState {
  const _Success(this.user);
  

 final  User user;

/// Create a copy of UpdateUserRegisterFaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'UpdateUserRegisterFaceState.success(user: $user)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $UpdateUserRegisterFaceStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 User user
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of UpdateUserRegisterFaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(_Success(
null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}


}

// dart format on
