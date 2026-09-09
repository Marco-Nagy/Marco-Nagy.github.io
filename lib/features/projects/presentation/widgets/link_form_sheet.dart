import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/navigation_extensions.dart';
import '../../../../core/widgets/admin/admin_choice_field.dart';
import '../../../../core/widgets/admin/admin_form_sheet.dart';
import '../../../../core/widgets/common/underline_text_field.dart';
import '../../../portfolio_content/domain/entities/project_link.dart';

/// Add/edit form for one [ProjectLink] — pick what it opens, paste the URL.
///
/// The list this belongs to is edited by plain index, the same as panels and
/// shots. Two entries of the same [ProjectLinkType] are a data-entry mistake
/// rather than a state the form prevents; the render side (`ProjectLinksRow`)
/// keys by type and keeps whichever comes last, so the page never shows two
/// buttons that both say "Source on GitHub" — it just shows one of them.
class LinkFormSheet extends StatefulWidget {
  const LinkFormSheet({this.link, super.key});

  /// Null when adding.
  final ProjectLink? link;

  /// Resolves to the built link, or null if dismissed.
  static Future<ProjectLink?> open(
    BuildContext context, {
    ProjectLink? link,
  }) {
    return AdminFormSheet.show<ProjectLink>(
      context,
      LinkFormSheet(link: link),
    );
  }

  @override
  State<LinkFormSheet> createState() => _LinkFormSheetState();
}

class _LinkFormSheetState extends State<LinkFormSheet> {
  late ProjectLinkType _type = widget.link?.type ?? ProjectLinkType.gitHub;
  late final TextEditingController _url = TextEditingController(
    text: widget.link?.url ?? '',
  );

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  String _typeLabel(ProjectLinkType type) => context.translate(switch (type) {
    ProjectLinkType.gitHub => LangKeys.projectLinkGithub,
    ProjectLinkType.playStore => LangKeys.projectLinkPlayStore,
    ProjectLinkType.appStore => LangKeys.projectLinkAppStore,
    ProjectLinkType.web => LangKeys.projectLinkWeb,
    ProjectLinkType.apk => LangKeys.projectLinkApk,
  });

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      AdminChoiceField<ProjectLinkType>(
        label: context.translate(LangKeys.fieldProjectLinks),
        value: _type,
        options: ProjectLinkType.values,
        labelOf: _typeLabel,
        onChanged: (type) => setState(() => _type = type),
      ),
      UnderlineTextField(
        label: context.translate(LangKeys.fieldLinkUrl),
        controller: _url,
        hint: 'https://…',
        textInputAction: TextInputAction.done,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormSheet(
      title: context.translate(LangKeys.adminAddLink),
      fieldsBuilder: _fields,
      onSave: () => context.pop<ProjectLink>(
        ProjectLink(type: _type, url: _url.text.trim()),
      ),
    );
  }
}
