import 'package:flutter/material.dart';

import '../../localization/lang_keys.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/extension/site_content_extensions.dart';
import '../../utils/url_opener.dart';
import '../common/app_snack_bar.dart';
import '../common/pill_button.dart';

/// Opens the CV PDF in a new tab. It is a static asset link, not an in-app
/// viewer — matching the reference site's behaviour.
class ResumeButton extends StatelessWidget {
  const ResumeButton({this.dense = false, super.key});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    // Null off the web with no hosted CV set — a bundled asset has no URL to
    // open there, and the button reports that rather than doing nothing.
    final resumeUrl = context.siteLinks.resumeUrl;

    return PillButton(
      label: context.translate(LangKeys.navResume),
      variant: PillButtonVariant.outlined,
      showArrow: false,
      icon: Icons.description_outlined,
      dense: dense,
      onPressed: () async {
        final messengerContext = context;
        final opened = resumeUrl != null && await UrlOpener.open(resumeUrl);
        if (!opened && messengerContext.mounted) {
          AppSnackBar.show(
            messengerContext,
            messengerContext.translate(LangKeys.commonError),
            kind: SnackKind.error,
          );
        }
      },
    );
  }
}
