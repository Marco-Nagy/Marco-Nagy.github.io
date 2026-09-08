// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaRef {

 MediaKind get kind;/// The still, or a video's poster frame.
 ImageRef get image;/// Asset path or URL of the video. Empty for [MediaKind.image].
 String get videoUrl; bool get muted; bool get loop;/// Plays as soon as the media is revealed — hovering a project row, opening
/// the detail view — instead of waiting for a tap.
 bool get autoplay;
/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaRefCopyWith<MediaRef> get copyWith => _$MediaRefCopyWithImpl<MediaRef>(this as MediaRef, _$identity);

  /// Serializes this MediaRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaRef&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.image, image) || other.image == image)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.loop, loop) || other.loop == loop)&&(identical(other.autoplay, autoplay) || other.autoplay == autoplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,image,videoUrl,muted,loop,autoplay);

@override
String toString() {
  return 'MediaRef(kind: $kind, image: $image, videoUrl: $videoUrl, muted: $muted, loop: $loop, autoplay: $autoplay)';
}


}

/// @nodoc
abstract mixin class $MediaRefCopyWith<$Res>  {
  factory $MediaRefCopyWith(MediaRef value, $Res Function(MediaRef) _then) = _$MediaRefCopyWithImpl;
@useResult
$Res call({
 MediaKind kind, ImageRef image, String videoUrl, bool muted, bool loop, bool autoplay
});


$ImageRefCopyWith<$Res> get image;

}
/// @nodoc
class _$MediaRefCopyWithImpl<$Res>
    implements $MediaRefCopyWith<$Res> {
  _$MediaRefCopyWithImpl(this._self, this._then);

  final MediaRef _self;
  final $Res Function(MediaRef) _then;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? image = null,Object? videoUrl = null,Object? muted = null,Object? loop = null,Object? autoplay = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MediaKind,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as ImageRef,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,loop: null == loop ? _self.loop : loop // ignore: cast_nullable_to_non_nullable
as bool,autoplay: null == autoplay ? _self.autoplay : autoplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageRefCopyWith<$Res> get image {
  
  return $ImageRefCopyWith<$Res>(_self.image, (value) {
    return _then(_self.copyWith(image: value));
  });
}
}


/// Adds pattern-matching-related methods to [MediaRef].
extension MediaRefPatterns on MediaRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaRef value)  $default,){
final _that = this;
switch (_that) {
case _MediaRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaRef value)?  $default,){
final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MediaKind kind,  ImageRef image,  String videoUrl,  bool muted,  bool loop,  bool autoplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
return $default(_that.kind,_that.image,_that.videoUrl,_that.muted,_that.loop,_that.autoplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MediaKind kind,  ImageRef image,  String videoUrl,  bool muted,  bool loop,  bool autoplay)  $default,) {final _that = this;
switch (_that) {
case _MediaRef():
return $default(_that.kind,_that.image,_that.videoUrl,_that.muted,_that.loop,_that.autoplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MediaKind kind,  ImageRef image,  String videoUrl,  bool muted,  bool loop,  bool autoplay)?  $default,) {final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
return $default(_that.kind,_that.image,_that.videoUrl,_that.muted,_that.loop,_that.autoplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaRef extends MediaRef {
  const _MediaRef({this.kind = MediaKind.image, this.image = const ImageRef(), this.videoUrl = '', this.muted = true, this.loop = true, this.autoplay = true}): super._();
  factory _MediaRef.fromJson(Map<String, dynamic> json) => _$MediaRefFromJson(json);

@override@JsonKey() final  MediaKind kind;
/// The still, or a video's poster frame.
@override@JsonKey() final  ImageRef image;
/// Asset path or URL of the video. Empty for [MediaKind.image].
@override@JsonKey() final  String videoUrl;
@override@JsonKey() final  bool muted;
@override@JsonKey() final  bool loop;
/// Plays as soon as the media is revealed — hovering a project row, opening
/// the detail view — instead of waiting for a tap.
@override@JsonKey() final  bool autoplay;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaRefCopyWith<_MediaRef> get copyWith => __$MediaRefCopyWithImpl<_MediaRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaRef&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.image, image) || other.image == image)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.loop, loop) || other.loop == loop)&&(identical(other.autoplay, autoplay) || other.autoplay == autoplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,image,videoUrl,muted,loop,autoplay);

@override
String toString() {
  return 'MediaRef(kind: $kind, image: $image, videoUrl: $videoUrl, muted: $muted, loop: $loop, autoplay: $autoplay)';
}


}

/// @nodoc
abstract mixin class _$MediaRefCopyWith<$Res> implements $MediaRefCopyWith<$Res> {
  factory _$MediaRefCopyWith(_MediaRef value, $Res Function(_MediaRef) _then) = __$MediaRefCopyWithImpl;
@override @useResult
$Res call({
 MediaKind kind, ImageRef image, String videoUrl, bool muted, bool loop, bool autoplay
});


@override $ImageRefCopyWith<$Res> get image;

}
/// @nodoc
class __$MediaRefCopyWithImpl<$Res>
    implements _$MediaRefCopyWith<$Res> {
  __$MediaRefCopyWithImpl(this._self, this._then);

  final _MediaRef _self;
  final $Res Function(_MediaRef) _then;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? image = null,Object? videoUrl = null,Object? muted = null,Object? loop = null,Object? autoplay = null,}) {
  return _then(_MediaRef(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MediaKind,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as ImageRef,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,loop: null == loop ? _self.loop : loop // ignore: cast_nullable_to_non_nullable
as bool,autoplay: null == autoplay ? _self.autoplay : autoplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageRefCopyWith<$Res> get image {
  
  return $ImageRefCopyWith<$Res>(_self.image, (value) {
    return _then(_self.copyWith(image: value));
  });
}
}

// dart format on
