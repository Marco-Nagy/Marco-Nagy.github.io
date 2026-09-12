import 'package:http/http.dart' as http;
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

  /// [CloudinaryUploadService] takes its client as a constructor argument so a
  /// test can hand in a MockClient; in a real run injectable resolves that
  /// parameter from here, and without this registration it throws instead.
  @lazySingleton
  http.Client get httpClient => http.Client();
}
