// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_shot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaShot {

 MediaRef get image; DeviceFrameType get frame; double get rotationDegrees; double get scale;/// Fractional offset inside the panel: 0 is centred, 1 is a full panel
/// width/height away.
 double get offsetX; double get offsetY;
/// Create a copy of MediaShot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaShotCopyWith<MediaShot> get copyWith => _$MediaShotCopyWithImpl<MediaShot>(this as MediaShot, _$identity);

  /// Serializes this MediaShot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaShot&&(identical(other.image, image) || other.image == image)&&(identical(other.frame, frame) || other.frame == frame)&&(identical(other.rotationDegrees, rotationDegrees) || other.rotationDegrees == rotationDegrees)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.offsetX, offsetX) || other.offsetX == offsetX)&&(identical(other.offsetY, offsetY) || other.offsetY == offsetY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,image,frame,rotationDegrees,scale,offsetX,offsetY);

@override
String toString() {
  return 'MediaShot(image: $image, frame: $frame, rotationDegrees: $rotationDegrees, scale: $scale, offsetX: $offsetX, offsetY: $offsetY)';
}


}

/// @nodoc
abstract mixin class $MediaShotCopyWith<$Res>  {
  factory $MediaShotCopyWith(MediaShot value, $Res Function(MediaShot) _then) = _$MediaShotCopyWithImpl;
@useResult
$Res call({
 MediaRef image, DeviceFrameType frame, double rotationDegrees, double scale, double offsetX, double offsetY
});


$MediaRefCopyWith<$Res> get image;

}
/// @nodoc
class _$MediaShotCopyWithImpl<$Res>
    implements $MediaShotCopyWith<$Res> {
  _$MediaShotCopyWithImpl(this._self, this._then);

  final MediaShot _self;
  final $Res Function(MediaShot) _then;

/// Create a copy of MediaShot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? image = null,Object? frame = null,Object? rotationDegrees = null,Object? scale = null,Object? offsetX = null,Object? offsetY = null,}) {
  return _then(_self.copyWith(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as MediaRef,frame: null == frame ? _self.frame : frame // ignore: cast_nullable_to_non_nullable
as DeviceFrameType,rotationDegrees: null == rotationDegrees ? _self.rotationDegrees : rotationDegrees // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,offsetX: null == offsetX ? _self.offsetX : offsetX // ignore: cast_nullable_to_non_nullable
as double,offsetY: null == offsetY ? _self.offsetY : offsetY // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of MediaShot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaRefCopyWith<$Res> get image {
  
  return $MediaRefCopyWith<$Res>(_self.image, (value) {
    return _then(_self.copyWith(image: value));
  });
}
}


/// Adds pattern-matching-related methods to [MediaShot].
extension MediaShotPatterns on MediaShot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaShot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaShot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaShot value)  $default,){
final _that = this;
switch (_that) {
case _MediaShot():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaShot value)?  $default,){
final _that = this;
switch (_that) {
case _MediaShot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MediaRef image,  DeviceFrameType frame,  double rotationDegrees,  double scale,  double offsetX,  double offsetY)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaShot() when $default != null:
return $default(_that.image,_that.frame,_that.rotationDegrees,_that.scale,_that.offsetX,_that.offsetY);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MediaRef image,  DeviceFrameType frame,  double rotationDegrees,  double scale,  double offsetX,  double offsetY)  $default,) {final _that = this;
switch (_that) {
case _MediaShot():
return $default(_that.image,_that.frame,_that.rotationDegrees,_that.scale,_that.offsetX,_that.offsetY);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MediaRef image,  DeviceFrameType frame,  double rotationDegrees,  double scale,  double offsetX,  double offsetY)?  $default,) {final _that = this;
switch (_that) {
case _MediaShot() when $default != null:
return $default(_that.image,_that.frame,_that.rotationDegrees,_that.scale,_that.offsetX,_that.offsetY);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaShot implements MediaShot {
  const _MediaShot({this.image = const MediaRef(), this.frame = DeviceFrameType.none, this.rotationDegrees = 0, this.scale = 1, this.offsetX = 0, this.offsetY = 0});
  factory _MediaShot.fromJson(Map<String, dynamic> json) => _$MediaShotFromJson(json);

@override@JsonKey() final  MediaRef image;
@override@JsonKey() final  DeviceFrameType frame;
@override@JsonKey() final  double rotationDegrees;
@override@JsonKey() final  double scale;
/// Fractional offset inside the panel: 0 is centred, 1 is a full panel
/// width/height away.
@override@JsonKey() final  double offsetX;
@override@JsonKey() final  double offsetY;

/// Create a copy of MediaShot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaShotCopyWith<_MediaShot> get copyWith => __$MediaShotCopyWithImpl<_MediaShot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaShotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaShot&&(identical(other.image, image) || other.image == image)&&(identical(other.frame, frame) || other.frame == frame)&&(identical(other.rotationDegrees, rotationDegrees) || other.rotationDegrees == rotationDegrees)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.offsetX, offsetX) || other.offsetX == offsetX)&&(identical(other.offsetY, offsetY) || other.offsetY == offsetY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,image,frame,rotationDegrees,scale,offsetX,offsetY);

@override
String toString() {
  return 'MediaShot(image: $image, frame: $frame, rotationDegrees: $rotationDegrees, scale: $scale, offsetX: $offsetX, offsetY: $offsetY)';
}


}

/// @nodoc
abstract mixin class _$MediaShotCopyWith<$Res> implements $MediaShotCopyWith<$Res> {
  factory _$MediaShotCopyWith(_MediaShot value, $Res Function(_MediaShot) _then) = __$MediaShotCopyWithImpl;
@override @useResult
$Res call({
 MediaRef image, DeviceFrameType frame, double rotationDegrees, double scale, double offsetX, double offsetY
});


@override $MediaRefCopyWith<$Res> get image;

}
/// @nodoc
class __$MediaShotCopyWithImpl<$Res>
    implements _$MediaShotCopyWith<$Res> {
  __$MediaShotCopyWithImpl(this._self, this._then);

  final _MediaShot _self;
  final $Res Function(_MediaShot) _then;

/// Create a copy of MediaShot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? image = null,Object? frame = null,Object? rotationDegrees = null,Object? scale = null,Object? offsetX = null,Object? offsetY = null,}) {
  return _then(_MediaShot(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as MediaRef,frame: null == frame ? _self.frame : frame // ignore: cast_nullable_to_non_nullable
as DeviceFrameType,rotationDegrees: null == rotationDegrees ? _self.rotationDegrees : rotationDegrees // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,offsetX: null == offsetX ? _self.offsetX : offsetX // ignore: cast_nullable_to_non_nullable
as double,offsetY: null == offsetY ? _self.offsetY : offsetY // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of MediaShot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaRefCopyWith<$Res> get image {
  
  return $MediaRefCopyWith<$Res>(_self.image, (value) {
    return _then(_self.copyWith(image: value));
  });
}
}

// dart format on
