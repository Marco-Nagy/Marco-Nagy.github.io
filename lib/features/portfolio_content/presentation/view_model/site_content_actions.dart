import '../../domain/entities/site_content.dart';

sealed class SiteContentActions {}

class LoadSiteContent extends SiteContentActions {}

/// Debug-only: replace the whole singleton.
class SaveSiteContent extends SiteContentActions {
  SaveSiteContent(this.content);
  final SiteContent content;
}
