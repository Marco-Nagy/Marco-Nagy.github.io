import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../localization/lang_keys.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../common/pill_button.dart';

/// Full-screen chrome for an add/edit form heavy enough to earn its own page —
/// a project, whose panels/shots/background/links sub-editors already run
/// three sheets deep before you reach a single text field.
///
/// [AdminFormSheet] is still the right chrome for those nested editors: a
/// quick, single-purpose edit that closes in one save. This is for the form
/// that opens them — long enough to scroll, worth a real back button, and
/// worth a title bar that stays in view instead of one that scrolls away with
/// the fields.
class AdminFormScreen extends StatefulWidget {
  const AdminFormScreen({
    required this.title,
    required this.fieldsBuilder,
    required this.onSave,
    this.previewBuilder,
    super.key,
  });

  final String title;

  /// Built inside the page's [Form].
  final List<Widget> Function(BuildContext context) fieldsBuilder;

  /// Called only after validation passes. The callback is responsible for
  /// popping with its built value, so each form decides what it returns.
  final VoidCallback onSave;

  /// When given, the fields sit in a left column and this builds a right
  /// column beside them instead of centring the fields alone — chrome for the
  /// handful of forms (a project's media items) where seeing the result live
  /// matters more than a single narrow measure. The preview column does not
  /// scroll with the fields; it is meant to stay in view the whole time a
  /// value beside it is being tuned.
  final WidgetBuilder? previewBuilder;

  /// Pushes any full-screen form, typed by what that form pops with.
  static Future<T?> open<T>(BuildContext context, Widget screen) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute<T>(builder: (_) => screen));
  }

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // onSave pops with the built value; popping here too would close twice.
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageTop,
      appBar: AppBar(
        backgroundColor: colors.pageTop,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: Icon(Icons.close_rounded, color: colors.onNavyMuted),
        ),
        title: Text(
          widget.title,
          style: MyFonts.bold22.copyWith(color: colors.onNavy),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _Body(formKey: _formKey, screen: widget),
            ),
            // Docked rather than scrolling away with the fields — a form long
            // enough to need its own screen is exactly the one where Save
            // should never require scrolling back down to find it.
            Container(
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 12.h),
              decoration: BoxDecoration(
                color: colors.surfaceHigh,
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.previewBuilder == null ? 720.w : 1100.w,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The scrollable form area, below the app bar and above the docked save bar.
/// A single centred column when there is no preview; a fields column beside a
/// fixed preview column when there is.
class _Body extends StatelessWidget {
  const _Body({required this.formKey, required this.screen});

  final GlobalKey<FormState> formKey;
  final AdminFormScreen screen;

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: screen.fieldsBuilder(context),
      ),
    );

    final previewBuilder = screen.previewBuilder;
    if (previewBuilder == null) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 720.w),
            child: form,
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1100.w),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.only(
                    start: 24.w,
                    end: 24.w,
                    bottom: 24.h,
                  ),
                  child: form,
                ),
              ),
              SizedBox(width: 32.w),
              Padding(
                padding: EdgeInsetsDirectional.only(end: 24.w),
                child: SizedBox(width: 340.w, child: previewBuilder(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
