import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../common/pill_button.dart';

/// Shared chrome for every debug-mode add/edit form: a scrollable sheet with a
/// title, the bilingual fields, and Cancel / Save.
///
/// Each feature supplies its own fields and its own [onSave]; this holds the
/// [Form] key and validation so no feature re-implements it.
class AdminFormSheet extends StatefulWidget {
  const AdminFormSheet({
    required this.title,
    required this.fieldsBuilder,
    required this.onSave,
    super.key,
  });

  final String title;

  /// Built inside the sheet's [Form].
  final List<Widget> Function(BuildContext context) fieldsBuilder;

  /// Called only after validation passes. The callback is responsible for
  /// popping with its built value, so each form decides what it returns.
  final VoidCallback onSave;

  /// Opens any form sheet as a modal, typed by what that form pops with.
  ///
  /// Cancel and the close button pop `null` rather than a "dismissed" flag:
  /// the modal route casts its result to `T?`, so popping any value that is
  /// not a [T] throws mid-pop and leaves the navigator locked.
  static Future<T?> show<T>(BuildContext context, Widget sheet) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  @override
  State<AdminFormSheet> createState() => _AdminFormSheetState();
}

class _AdminFormSheetState extends State<AdminFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // onSave pops with the built value; popping here too would close twice.
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      // Keep the fields above the keyboard on mobile.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          maxWidth: 720.w,
        ),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: colors.surfaceHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 12.w, 8.h),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: MyFonts.bold22.copyWith(color: colors.onNavy),
                      ),
                    ),
                    IconButton(
                      // Pops null, not `false` — see [show].
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.onNavyMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: colors.divider, height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.fieldsBuilder(context),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        context.translate(LangKeys.adminCancel),
                        style: MyFonts.semi16.copyWith(
                          color: colors.onNavyMuted,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    PillButton(
                      label: context.translate(LangKeys.adminSave),
                      showArrow: false,
                      dense: true,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
