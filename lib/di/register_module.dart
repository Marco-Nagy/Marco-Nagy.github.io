import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../core/services/shared_preference/shared_preference_helper.dart';

/// Third-party / hand-built singletons that injectable can't construct itself.
@module
abstract class RegisterModule {
  @lazySingleton
  SharedPrefHelper get sharedPrefHelper => SharedPrefHelper();

  /// Debug-only in practice — only the admin forms resolve the service that
  /// wraps it — but registering it unconditionally keeps DI wiring identical
  /// across build modes.
  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();
}
