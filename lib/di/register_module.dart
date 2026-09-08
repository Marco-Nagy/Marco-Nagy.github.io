import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../core/services/shared_preference/shared_preference_helper.dart';

/// Third-party / hand-built singletons that injectable can't construct itself.
@module
abstract class RegisterModule {
  @lazySingleton
  SharedPrefHelper get sharedPrefHelper => SharedPrefHelper();

  /// Only the admin forms resolve the service that wraps this, but registering
  /// it unconditionally keeps the DI graph identical across build modes.
  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();
}
