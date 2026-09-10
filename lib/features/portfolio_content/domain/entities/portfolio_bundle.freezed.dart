// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portfolio_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PortfolioBundle {

 List<PersonalProject> get projects; List<Certificate> get certificates; List<WorkHistoryEntry> get workHistory; List<PricingPackage> get pricingPackages; List<PricingAddOn> get pricingAddOns; SiteContent get siteContent; List<SkillGroupEntity> get skillGroups; List<TechBadgeEntity> get techBadges; List<SectionDefinition> get sections; Map<String, List<CustomSectionItem>> get customItems;/// Bumped by hand when the *shape* of this object changes in a way older
/// clients cannot read. A stored bundle from a newer schema is refused
/// rather than silently half-decoded.
 int get schemaVersion;/// Bumped on every admin save. A client whose cached value matches the
/// one in `content/meta` skips fetching the bundle entirely — this single
/// integer is what keeps a returning visitor at 1 read.
 int get contentVersion;/// ISO-8601, matching the stringly-dated convention every other entity
/// here uses. Informational: nothing branches on it.
 String get updatedAt;
/// Create a copy of PortfolioBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfolioBundleCopyWith<PortfolioBundle> get copyWith => _$PortfolioBundleCopyWithImpl<PortfolioBundle>(this as PortfolioBundle, _$identity);

  /// Serializes this PortfolioBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortfolioBundle&&const DeepCollectionEquality().equals(other.projects, projects)&&const DeepCollectionEquality().equals(other.certificates, certificates)&&const DeepCollectionEquality().equals(other.workHistory, workHistory)&&const DeepCollectionEquality().equals(other.pricingPackages, pricingPackages)&&const DeepCollectionEquality().equals(other.pricingAddOns, pricingAddOns)&&(identical(other.siteContent, siteContent) || other.siteContent == siteContent)&&const DeepCollectionEquality().equals(other.skillGroups, skillGroups)&&const DeepCollectionEquality().equals(other.techBadges, techBadges)&&const DeepCollectionEquality().equals(other.sections, sections)&&const DeepCollectionEquality().equals(other.customItems, customItems)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.contentVersion, contentVersion) || other.contentVersion == contentVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(projects),const DeepCollectionEquality().hash(certificates),const DeepCollectionEquality().hash(workHistory),const DeepCollectionEquality().hash(pricingPackages),const DeepCollectionEquality().hash(pricingAddOns),siteContent,const DeepCollectionEquality().hash(skillGroups),const DeepCollectionEquality().hash(techBadges),const DeepCollectionEquality().hash(sections),const DeepCollectionEquality().hash(customItems),schemaVersion,contentVersion,updatedAt);

@override
String toString() {
  return 'PortfolioBundle(projects: $projects, certificates: $certificates, workHistory: $workHistory, pricingPackages: $pricingPackages, pricingAddOns: $pricingAddOns, siteContent: $siteContent, skillGroups: $skillGroups, techBadges: $techBadges, sections: $sections, customItems: $customItems, schemaVersion: $schemaVersion, contentVersion: $contentVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PortfolioBundleCopyWith<$Res>  {
  factory $PortfolioBundleCopyWith(PortfolioBundle value, $Res Function(PortfolioBundle) _then) = _$PortfolioBundleCopyWithImpl;
@useResult
$Res call({
 List<PersonalProject> projects, List<Certificate> certificates, List<WorkHistoryEntry> workHistory, List<PricingPackage> pricingPackages, List<PricingAddOn> pricingAddOns, SiteContent siteContent, List<SkillGroupEntity> skillGroups, List<TechBadgeEntity> techBadges, List<SectionDefinition> sections, Map<String, List<CustomSectionItem>> customItems, int schemaVersion, int contentVersion, String updatedAt
});


$SiteContentCopyWith<$Res> get siteContent;

}
/// @nodoc
class _$PortfolioBundleCopyWithImpl<$Res>
    implements $PortfolioBundleCopyWith<$Res> {
  _$PortfolioBundleCopyWithImpl(this._self, this._then);

  final PortfolioBundle _self;
  final $Res Function(PortfolioBundle) _then;

/// Create a copy of PortfolioBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projects = null,Object? certificates = null,Object? workHistory = null,Object? pricingPackages = null,Object? pricingAddOns = null,Object? siteContent = null,Object? skillGroups = null,Object? techBadges = null,Object? sections = null,Object? customItems = null,Object? schemaVersion = null,Object? contentVersion = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<PersonalProject>,certificates: null == certificates ? _self.certificates : certificates // ignore: cast_nullable_to_non_nullable
as List<Certificate>,workHistory: null == workHistory ? _self.workHistory : workHistory // ignore: cast_nullable_to_non_nullable
as List<WorkHistoryEntry>,pricingPackages: null == pricingPackages ? _self.pricingPackages : pricingPackages // ignore: cast_nullable_to_non_nullable
as List<PricingPackage>,pricingAddOns: null == pricingAddOns ? _self.pricingAddOns : pricingAddOns // ignore: cast_nullable_to_non_nullable
as List<PricingAddOn>,siteContent: null == siteContent ? _self.siteContent : siteContent // ignore: cast_nullable_to_non_nullable
as SiteContent,skillGroups: null == skillGroups ? _self.skillGroups : skillGroups // ignore: cast_nullable_to_non_nullable
as List<SkillGroupEntity>,techBadges: null == techBadges ? _self.techBadges : techBadges // ignore: cast_nullable_to_non_nullable
as List<TechBadgeEntity>,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<SectionDefinition>,customItems: null == customItems ? _self.customItems : customItems // ignore: cast_nullable_to_non_nullable
as Map<String, List<CustomSectionItem>>,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,contentVersion: null == contentVersion ? _self.contentVersion : contentVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PortfolioBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteContentCopyWith<$Res> get siteContent {
  
  return $SiteContentCopyWith<$Res>(_self.siteContent, (value) {
    return _then(_self.copyWith(siteContent: value));
  });
}
}


/// Adds pattern-matching-related methods to [PortfolioBundle].
extension PortfolioBundlePatterns on PortfolioBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortfolioBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortfolioBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortfolioBundle value)  $default,){
final _that = this;
switch (_that) {
case _PortfolioBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortfolioBundle value)?  $default,){
final _that = this;
switch (_that) {
case _PortfolioBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PersonalProject> projects,  List<Certificate> certificates,  List<WorkHistoryEntry> workHistory,  List<PricingPackage> pricingPackages,  List<PricingAddOn> pricingAddOns,  SiteContent siteContent,  List<SkillGroupEntity> skillGroups,  List<TechBadgeEntity> techBadges,  List<SectionDefinition> sections,  Map<String, List<CustomSectionItem>> customItems,  int schemaVersion,  int contentVersion,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortfolioBundle() when $default != null:
return $default(_that.projects,_that.certificates,_that.workHistory,_that.pricingPackages,_that.pricingAddOns,_that.siteContent,_that.skillGroups,_that.techBadges,_that.sections,_that.customItems,_that.schemaVersion,_that.contentVersion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PersonalProject> projects,  List<Certificate> certificates,  List<WorkHistoryEntry> workHistory,  List<PricingPackage> pricingPackages,  List<PricingAddOn> pricingAddOns,  SiteContent siteContent,  List<SkillGroupEntity> skillGroups,  List<TechBadgeEntity> techBadges,  List<SectionDefinition> sections,  Map<String, List<CustomSectionItem>> customItems,  int schemaVersion,  int contentVersion,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PortfolioBundle():
return $default(_that.projects,_that.certificates,_that.workHistory,_that.pricingPackages,_that.pricingAddOns,_that.siteContent,_that.skillGroups,_that.techBadges,_that.sections,_that.customItems,_that.schemaVersion,_that.contentVersion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PersonalProject> projects,  List<Certificate> certificates,  List<WorkHistoryEntry> workHistory,  List<PricingPackage> pricingPackages,  List<PricingAddOn> pricingAddOns,  SiteContent siteContent,  List<SkillGroupEntity> skillGroups,  List<TechBadgeEntity> techBadges,  List<SectionDefinition> sections,  Map<String, List<CustomSectionItem>> customItems,  int schemaVersion,  int contentVersion,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PortfolioBundle() when $default != null:
return $default(_that.projects,_that.certificates,_that.workHistory,_that.pricingPackages,_that.pricingAddOns,_that.siteContent,_that.skillGroups,_that.techBadges,_that.sections,_that.customItems,_that.schemaVersion,_that.contentVersion,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortfolioBundle extends PortfolioBundle {
  const _PortfolioBundle({final  List<PersonalProject> projects = const <PersonalProject>[], final  List<Certificate> certificates = const <Certificate>[], final  List<WorkHistoryEntry> workHistory = const <WorkHistoryEntry>[], final  List<PricingPackage> pricingPackages = const <PricingPackage>[], final  List<PricingAddOn> pricingAddOns = const <PricingAddOn>[], this.siteContent = const SiteContent(), final  List<SkillGroupEntity> skillGroups = const <SkillGroupEntity>[], final  List<TechBadgeEntity> techBadges = const <TechBadgeEntity>[], final  List<SectionDefinition> sections = const <SectionDefinition>[], final  Map<String, List<CustomSectionItem>> customItems = const <String, List<CustomSectionItem>>{}, this.schemaVersion = 1, this.contentVersion = 0, this.updatedAt = ''}): _projects = projects,_certificates = certificates,_workHistory = workHistory,_pricingPackages = pricingPackages,_pricingAddOns = pricingAddOns,_skillGroups = skillGroups,_techBadges = techBadges,_sections = sections,_customItems = customItems,super._();
  factory _PortfolioBundle.fromJson(Map<String, dynamic> json) => _$PortfolioBundleFromJson(json);

 final  List<PersonalProject> _projects;
@override@JsonKey() List<PersonalProject> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

 final  List<Certificate> _certificates;
@override@JsonKey() List<Certificate> get certificates {
  if (_certificates is EqualUnmodifiableListView) return _certificates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_certificates);
}

 final  List<WorkHistoryEntry> _workHistory;
@override@JsonKey() List<WorkHistoryEntry> get workHistory {
  if (_workHistory is EqualUnmodifiableListView) return _workHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workHistory);
}

 final  List<PricingPackage> _pricingPackages;
@override@JsonKey() List<PricingPackage> get pricingPackages {
  if (_pricingPackages is EqualUnmodifiableListView) return _pricingPackages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pricingPackages);
}

 final  List<PricingAddOn> _pricingAddOns;
@override@JsonKey() List<PricingAddOn> get pricingAddOns {
  if (_pricingAddOns is EqualUnmodifiableListView) return _pricingAddOns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pricingAddOns);
}

@override@JsonKey() final  SiteContent siteContent;
 final  List<SkillGroupEntity> _skillGroups;
@override@JsonKey() List<SkillGroupEntity> get skillGroups {
  if (_skillGroups is EqualUnmodifiableListView) return _skillGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skillGroups);
}

 final  List<TechBadgeEntity> _techBadges;
@override@JsonKey() List<TechBadgeEntity> get techBadges {
  if (_techBadges is EqualUnmodifiableListView) return _techBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_techBadges);
}

 final  List<SectionDefinition> _sections;
@override@JsonKey() List<SectionDefinition> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

 final  Map<String, List<CustomSectionItem>> _customItems;
@override@JsonKey() Map<String, List<CustomSectionItem>> get customItems {
  if (_customItems is EqualUnmodifiableMapView) return _customItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customItems);
}

/// Bumped by hand when the *shape* of this object changes in a way older
/// clients cannot read. A stored bundle from a newer schema is refused
/// rather than silently half-decoded.
@override@JsonKey() final  int schemaVersion;
/// Bumped on every admin save. A client whose cached value matches the
/// one in `content/meta` skips fetching the bundle entirely — this single
/// integer is what keeps a returning visitor at 1 read.
@override@JsonKey() final  int contentVersion;
/// ISO-8601, matching the stringly-dated convention every other entity
/// here uses. Informational: nothing branches on it.
@override@JsonKey() final  String updatedAt;

/// Create a copy of PortfolioBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfolioBundleCopyWith<_PortfolioBundle> get copyWith => __$PortfolioBundleCopyWithImpl<_PortfolioBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortfolioBundleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortfolioBundle&&const DeepCollectionEquality().equals(other._projects, _projects)&&const DeepCollectionEquality().equals(other._certificates, _certificates)&&const DeepCollectionEquality().equals(other._workHistory, _workHistory)&&const DeepCollectionEquality().equals(other._pricingPackages, _pricingPackages)&&const DeepCollectionEquality().equals(other._pricingAddOns, _pricingAddOns)&&(identical(other.siteContent, siteContent) || other.siteContent == siteContent)&&const DeepCollectionEquality().equals(other._skillGroups, _skillGroups)&&const DeepCollectionEquality().equals(other._techBadges, _techBadges)&&const DeepCollectionEquality().equals(other._sections, _sections)&&const DeepCollectionEquality().equals(other._customItems, _customItems)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.contentVersion, contentVersion) || other.contentVersion == contentVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_projects),const DeepCollectionEquality().hash(_certificates),const DeepCollectionEquality().hash(_workHistory),const DeepCollectionEquality().hash(_pricingPackages),const DeepCollectionEquality().hash(_pricingAddOns),siteContent,const DeepCollectionEquality().hash(_skillGroups),const DeepCollectionEquality().hash(_techBadges),const DeepCollectionEquality().hash(_sections),const DeepCollectionEquality().hash(_customItems),schemaVersion,contentVersion,updatedAt);

@override
String toString() {
  return 'PortfolioBundle(projects: $projects, certificates: $certificates, workHistory: $workHistory, pricingPackages: $pricingPackages, pricingAddOns: $pricingAddOns, siteContent: $siteContent, skillGroups: $skillGroups, techBadges: $techBadges, sections: $sections, customItems: $customItems, schemaVersion: $schemaVersion, contentVersion: $contentVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PortfolioBundleCopyWith<$Res> implements $PortfolioBundleCopyWith<$Res> {
  factory _$PortfolioBundleCopyWith(_PortfolioBundle value, $Res Function(_PortfolioBundle) _then) = __$PortfolioBundleCopyWithImpl;
@override @useResult
$Res call({
 List<PersonalProject> projects, List<Certificate> certificates, List<WorkHistoryEntry> workHistory, List<PricingPackage> pricingPackages, List<PricingAddOn> pricingAddOns, SiteContent siteContent, List<SkillGroupEntity> skillGroups, List<TechBadgeEntity> techBadges, List<SectionDefinition> sections, Map<String, List<CustomSectionItem>> customItems, int schemaVersion, int contentVersion, String updatedAt
});


@override $SiteContentCopyWith<$Res> get siteContent;

}
/// @nodoc
class __$PortfolioBundleCopyWithImpl<$Res>
    implements _$PortfolioBundleCopyWith<$Res> {
  __$PortfolioBundleCopyWithImpl(this._self, this._then);

  final _PortfolioBundle _self;
  final $Res Function(_PortfolioBundle) _then;

/// Create a copy of PortfolioBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projects = null,Object? certificates = null,Object? workHistory = null,Object? pricingPackages = null,Object? pricingAddOns = null,Object? siteContent = null,Object? skillGroups = null,Object? techBadges = null,Object? sections = null,Object? customItems = null,Object? schemaVersion = null,Object? contentVersion = null,Object? updatedAt = null,}) {
  return _then(_PortfolioBundle(
projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<PersonalProject>,certificates: null == certificates ? _self._certificates : certificates // ignore: cast_nullable_to_non_nullable
as List<Certificate>,workHistory: null == workHistory ? _self._workHistory : workHistory // ignore: cast_nullable_to_non_nullable
as List<WorkHistoryEntry>,pricingPackages: null == pricingPackages ? _self._pricingPackages : pricingPackages // ignore: cast_nullable_to_non_nullable
as List<PricingPackage>,pricingAddOns: null == pricingAddOns ? _self._pricingAddOns : pricingAddOns // ignore: cast_nullable_to_non_nullable
as List<PricingAddOn>,siteContent: null == siteContent ? _self.siteContent : siteContent // ignore: cast_nullable_to_non_nullable
as SiteContent,skillGroups: null == skillGroups ? _self._skillGroups : skillGroups // ignore: cast_nullable_to_non_nullable
as List<SkillGroupEntity>,techBadges: null == techBadges ? _self._techBadges : techBadges // ignore: cast_nullable_to_non_nullable
as List<TechBadgeEntity>,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<SectionDefinition>,customItems: null == customItems ? _self._customItems : customItems // ignore: cast_nullable_to_non_nullable
as Map<String, List<CustomSectionItem>>,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,contentVersion: null == contentVersion ? _self.contentVersion : contentVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PortfolioBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteContentCopyWith<$Res> get siteContent {
  
  return $SiteContentCopyWith<$Res>(_self.siteContent, (value) {
    return _then(_self.copyWith(siteContent: value));
  });
}
}


/// @nodoc
mixin _$PortfolioMeta {

 int get contentVersion; int get schemaVersion; String get updatedAt;
/// Create a copy of PortfolioMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfolioMetaCopyWith<PortfolioMeta> get copyWith => _$PortfolioMetaCopyWithImpl<PortfolioMeta>(this as PortfolioMeta, _$identity);

  /// Serializes this PortfolioMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortfolioMeta&&(identical(other.contentVersion, contentVersion) || other.contentVersion == contentVersion)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentVersion,schemaVersion,updatedAt);

@override
String toString() {
  return 'PortfolioMeta(contentVersion: $contentVersion, schemaVersion: $schemaVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PortfolioMetaCopyWith<$Res>  {
  factory $PortfolioMetaCopyWith(PortfolioMeta value, $Res Function(PortfolioMeta) _then) = _$PortfolioMetaCopyWithImpl;
@useResult
$Res call({
 int contentVersion, int schemaVersion, String updatedAt
});




}
/// @nodoc
class _$PortfolioMetaCopyWithImpl<$Res>
    implements $PortfolioMetaCopyWith<$Res> {
  _$PortfolioMetaCopyWithImpl(this._self, this._then);

  final PortfolioMeta _self;
  final $Res Function(PortfolioMeta) _then;

/// Create a copy of PortfolioMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentVersion = null,Object? schemaVersion = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
contentVersion: null == contentVersion ? _self.contentVersion : contentVersion // ignore: cast_nullable_to_non_nullable
as int,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PortfolioMeta].
extension PortfolioMetaPatterns on PortfolioMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortfolioMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortfolioMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortfolioMeta value)  $default,){
final _that = this;
switch (_that) {
case _PortfolioMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortfolioMeta value)?  $default,){
final _that = this;
switch (_that) {
case _PortfolioMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int contentVersion,  int schemaVersion,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortfolioMeta() when $default != null:
return $default(_that.contentVersion,_that.schemaVersion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int contentVersion,  int schemaVersion,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PortfolioMeta():
return $default(_that.contentVersion,_that.schemaVersion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int contentVersion,  int schemaVersion,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PortfolioMeta() when $default != null:
return $default(_that.contentVersion,_that.schemaVersion,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortfolioMeta extends PortfolioMeta {
  const _PortfolioMeta({this.contentVersion = 0, this.schemaVersion = 1, this.updatedAt = ''}): super._();
  factory _PortfolioMeta.fromJson(Map<String, dynamic> json) => _$PortfolioMetaFromJson(json);

@override@JsonKey() final  int contentVersion;
@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  String updatedAt;

/// Create a copy of PortfolioMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfolioMetaCopyWith<_PortfolioMeta> get copyWith => __$PortfolioMetaCopyWithImpl<_PortfolioMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortfolioMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortfolioMeta&&(identical(other.contentVersion, contentVersion) || other.contentVersion == contentVersion)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentVersion,schemaVersion,updatedAt);

@override
String toString() {
  return 'PortfolioMeta(contentVersion: $contentVersion, schemaVersion: $schemaVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PortfolioMetaCopyWith<$Res> implements $PortfolioMetaCopyWith<$Res> {
  factory _$PortfolioMetaCopyWith(_PortfolioMeta value, $Res Function(_PortfolioMeta) _then) = __$PortfolioMetaCopyWithImpl;
@override @useResult
$Res call({
 int contentVersion, int schemaVersion, String updatedAt
});




}
/// @nodoc
class __$PortfolioMetaCopyWithImpl<$Res>
    implements _$PortfolioMetaCopyWith<$Res> {
  __$PortfolioMetaCopyWithImpl(this._self, this._then);

  final _PortfolioMeta _self;
  final $Res Function(_PortfolioMeta) _then;

/// Create a copy of PortfolioMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentVersion = null,Object? schemaVersion = null,Object? updatedAt = null,}) {
  return _then(_PortfolioMeta(
contentVersion: null == contentVersion ? _self.contentVersion : contentVersion // ignore: cast_nullable_to_non_nullable
as int,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
