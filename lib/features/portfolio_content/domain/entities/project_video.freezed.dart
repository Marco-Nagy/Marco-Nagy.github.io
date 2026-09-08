// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectVideo {

 String get id; MediaRef get media;/// Width ÷ height. Defaults to a vertical 9:16 — the phone screen
/// recording most of these are.
 double get aspectRatio; String get captionEn; String get captionAr; String get subtitleEn; String get subtitleAr; CaptionPlacement get captionPlacement; String get captionColorHex;/// Overrides the owning project's background when set.
 ShotBackground? get backgroundOverride; int get order;
/// Create a copy of ProjectVideo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectVideoCopyWith<ProjectVideo> get copyWith => _$ProjectVideoCopyWithImpl<ProjectVideo>(this as ProjectVideo, _$identity);

  /// Serializes this ProjectVideo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectVideo&&(identical(other.id, id) || other.id == id)&&(identical(other.media, media) || other.media == media)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.captionEn, captionEn) || other.captionEn == captionEn)&&(identical(other.captionAr, captionAr) || other.captionAr == captionAr)&&(identical(other.subtitleEn, subtitleEn) || other.subtitleEn == subtitleEn)&&(identical(other.subtitleAr, subtitleAr) || other.subtitleAr == subtitleAr)&&(identical(other.captionPlacement, captionPlacement) || other.captionPlacement == captionPlacement)&&(identical(other.captionColorHex, captionColorHex) || other.captionColorHex == captionColorHex)&&(identical(other.backgroundOverride, backgroundOverride) || other.backgroundOverride == backgroundOverride)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,media,aspectRatio,captionEn,captionAr,subtitleEn,subtitleAr,captionPlacement,captionColorHex,backgroundOverride,order);

@override
String toString() {
  return 'ProjectVideo(id: $id, media: $media, aspectRatio: $aspectRatio, captionEn: $captionEn, captionAr: $captionAr, subtitleEn: $subtitleEn, subtitleAr: $subtitleAr, captionPlacement: $captionPlacement, captionColorHex: $captionColorHex, backgroundOverride: $backgroundOverride, order: $order)';
}


}

/// @nodoc
abstract mixin class $ProjectVideoCopyWith<$Res>  {
  factory $ProjectVideoCopyWith(ProjectVideo value, $Res Function(ProjectVideo) _then) = _$ProjectVideoCopyWithImpl;
@useResult
$Res call({
 String id, MediaRef media, double aspectRatio, String captionEn, String captionAr, String subtitleEn, String subtitleAr, CaptionPlacement captionPlacement, String captionColorHex, ShotBackground? backgroundOverride, int order
});


$MediaRefCopyWith<$Res> get media;$ShotBackgroundCopyWith<$Res>? get backgroundOverride;

}
/// @nodoc
class _$ProjectVideoCopyWithImpl<$Res>
    implements $ProjectVideoCopyWith<$Res> {
  _$ProjectVideoCopyWithImpl(this._self, this._then);

  final ProjectVideo _self;
  final $Res Function(ProjectVideo) _then;

/// Create a copy of ProjectVideo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? media = null,Object? aspectRatio = null,Object? captionEn = null,Object? captionAr = null,Object? subtitleEn = null,Object? subtitleAr = null,Object? captionPlacement = null,Object? captionColorHex = null,Object? backgroundOverride = freezed,Object? order = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaRef,aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double,captionEn: null == captionEn ? _self.captionEn : captionEn // ignore: cast_nullable_to_non_nullable
as String,captionAr: null == captionAr ? _self.captionAr : captionAr // ignore: cast_nullable_to_non_nullable
as String,subtitleEn: null == subtitleEn ? _self.subtitleEn : subtitleEn // ignore: cast_nullable_to_non_nullable
as String,subtitleAr: null == subtitleAr ? _self.subtitleAr : subtitleAr // ignore: cast_nullable_to_non_nullable
as String,captionPlacement: null == captionPlacement ? _self.captionPlacement : captionPlacement // ignore: cast_nullable_to_non_nullable
as CaptionPlacement,captionColorHex: null == captionColorHex ? _self.captionColorHex : captionColorHex // ignore: cast_nullable_to_non_nullable
as String,backgroundOverride: freezed == backgroundOverride ? _self.backgroundOverride : backgroundOverride // ignore: cast_nullable_to_non_nullable
as ShotBackground?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ProjectVideo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaRefCopyWith<$Res> get media {
  
  return $MediaRefCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}/// Create a copy of ProjectVideo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShotBackgroundCopyWith<$Res>? get backgroundOverride {
    if (_self.backgroundOverride == null) {
    return null;
  }

  return $ShotBackgroundCopyWith<$Res>(_self.backgroundOverride!, (value) {
    return _then(_self.copyWith(backgroundOverride: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProjectVideo].
extension ProjectVideoPatterns on ProjectVideo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectVideo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectVideo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectVideo value)  $default,){
final _that = this;
switch (_that) {
case _ProjectVideo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectVideo value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectVideo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MediaRef media,  double aspectRatio,  String captionEn,  String captionAr,  String subtitleEn,  String subtitleAr,  CaptionPlacement captionPlacement,  String captionColorHex,  ShotBackground? backgroundOverride,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectVideo() when $default != null:
return $default(_that.id,_that.media,_that.aspectRatio,_that.captionEn,_that.captionAr,_that.subtitleEn,_that.subtitleAr,_that.captionPlacement,_that.captionColorHex,_that.backgroundOverride,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MediaRef media,  double aspectRatio,  String captionEn,  String captionAr,  String subtitleEn,  String subtitleAr,  CaptionPlacement captionPlacement,  String captionColorHex,  ShotBackground? backgroundOverride,  int order)  $default,) {final _that = this;
switch (_that) {
case _ProjectVideo():
return $default(_that.id,_that.media,_that.aspectRatio,_that.captionEn,_that.captionAr,_that.subtitleEn,_that.subtitleAr,_that.captionPlacement,_that.captionColorHex,_that.backgroundOverride,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MediaRef media,  double aspectRatio,  String captionEn,  String captionAr,  String subtitleEn,  String subtitleAr,  CaptionPlacement captionPlacement,  String captionColorHex,  ShotBackground? backgroundOverride,  int order)?  $default,) {final _that = this;
switch (_that) {
case _ProjectVideo() when $default != null:
return $default(_that.id,_that.media,_that.aspectRatio,_that.captionEn,_that.captionAr,_that.subtitleEn,_that.subtitleAr,_that.captionPlacement,_that.captionColorHex,_that.backgroundOverride,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectVideo implements ProjectVideo {
  const _ProjectVideo({required this.id, this.media = const MediaRef(), this.aspectRatio = 9 / 16, this.captionEn = '', this.captionAr = '', this.subtitleEn = '', this.subtitleAr = '', this.captionPlacement = CaptionPlacement.top, this.captionColorHex = 'FFFFFF', this.backgroundOverride, this.order = 0});
  factory _ProjectVideo.fromJson(Map<String, dynamic> json) => _$ProjectVideoFromJson(json);

@override final  String id;
@override@JsonKey() final  MediaRef media;
/// Width ÷ height. Defaults to a vertical 9:16 — the phone screen
/// recording most of these are.
@override@JsonKey() final  double aspectRatio;
@override@JsonKey() final  String captionEn;
@override@JsonKey() final  String captionAr;
@override@JsonKey() final  String subtitleEn;
@override@JsonKey() final  String subtitleAr;
@override@JsonKey() final  CaptionPlacement captionPlacement;
@override@JsonKey() final  String captionColorHex;
/// Overrides the owning project's background when set.
@override final  ShotBackground? backgroundOverride;
@override@JsonKey() final  int order;

/// Create a copy of ProjectVideo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectVideoCopyWith<_ProjectVideo> get copyWith => __$ProjectVideoCopyWithImpl<_ProjectVideo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectVideoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectVideo&&(identical(other.id, id) || other.id == id)&&(identical(other.media, media) || other.media == media)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.captionEn, captionEn) || other.captionEn == captionEn)&&(identical(other.captionAr, captionAr) || other.captionAr == captionAr)&&(identical(other.subtitleEn, subtitleEn) || other.subtitleEn == subtitleEn)&&(identical(other.subtitleAr, subtitleAr) || other.subtitleAr == subtitleAr)&&(identical(other.captionPlacement, captionPlacement) || other.captionPlacement == captionPlacement)&&(identical(other.captionColorHex, captionColorHex) || other.captionColorHex == captionColorHex)&&(identical(other.backgroundOverride, backgroundOverride) || other.backgroundOverride == backgroundOverride)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,media,aspectRatio,captionEn,captionAr,subtitleEn,subtitleAr,captionPlacement,captionColorHex,backgroundOverride,order);

@override
String toString() {
  return 'ProjectVideo(id: $id, media: $media, aspectRatio: $aspectRatio, captionEn: $captionEn, captionAr: $captionAr, subtitleEn: $subtitleEn, subtitleAr: $subtitleAr, captionPlacement: $captionPlacement, captionColorHex: $captionColorHex, backgroundOverride: $backgroundOverride, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ProjectVideoCopyWith<$Res> implements $ProjectVideoCopyWith<$Res> {
  factory _$ProjectVideoCopyWith(_ProjectVideo value, $Res Function(_ProjectVideo) _then) = __$ProjectVideoCopyWithImpl;
@override @useResult
$Res call({
 String id, MediaRef media, double aspectRatio, String captionEn, String captionAr, String subtitleEn, String subtitleAr, CaptionPlacement captionPlacement, String captionColorHex, ShotBackground? backgroundOverride, int order
});


@override $MediaRefCopyWith<$Res> get media;@override $ShotBackgroundCopyWith<$Res>? get backgroundOverride;

}
/// @nodoc
class __$ProjectVideoCopyWithImpl<$Res>
    implements _$ProjectVideoCopyWith<$Res> {
  __$ProjectVideoCopyWithImpl(this._self, this._then);

  final _ProjectVideo _self;
  final $Res Function(_ProjectVideo) _then;

/// Create a copy of ProjectVideo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? media = null,Object? aspectRatio = null,Object? captionEn = null,Object? captionAr = null,Object? subtitleEn = null,Object? subtitleAr = null,Object? captionPlacement = null,Object? captionColorHex = null,Object? backgroundOverride = freezed,Object? order = null,}) {
  return _then(_ProjectVideo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaRef,aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double,captionEn: null == captionEn ? _self.captionEn : captionEn // ignore: cast_nullable_to_non_nullable
as String,captionAr: null == captionAr ? _self.captionAr : captionAr // ignore: cast_nullable_to_non_nullable
as String,subtitleEn: null == subtitleEn ? _self.subtitleEn : subtitleEn // ignore: cast_nullable_to_non_nullable
as String,subtitleAr: null == subtitleAr ? _self.subtitleAr : subtitleAr // ignore: cast_nullable_to_non_nullable
as String,captionPlacement: null == captionPlacement ? _self.captionPlacement : captionPlacement // ignore: cast_nullable_to_non_nullable
as CaptionPlacement,captionColorHex: null == captionColorHex ? _self.captionColorHex : captionColorHex // ignore: cast_nullable_to_non_nullable
as String,backgroundOverride: freezed == backgroundOverride ? _self.backgroundOverride : backgroundOverride // ignore: cast_nullable_to_non_nullable
as ShotBackground?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ProjectVideo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaRefCopyWith<$Res> get media {
  
  return $MediaRefCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}/// Create a copy of ProjectVideo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShotBackgroundCopyWith<$Res>? get backgroundOverride {
    if (_self.backgroundOverride == null) {
    return null;
  }

  return $ShotBackgroundCopyWith<$Res>(_self.backgroundOverride!, (value) {
    return _then(_self.copyWith(backgroundOverride: value));
  });
}
}

// dart format on
