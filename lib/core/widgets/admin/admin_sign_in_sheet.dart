import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../di/di.dart';
import '../../common/data_result.dart';
import '../../localization/lang_keys.dart';
import '../../services/auth/admin_auth_service.dart';
import '../../styles/fonts/my_fonts.dart';
import '../../utils/extension/context_extensions.dart';
import '../../utils/validators.dart';
import '../common/pill_button.dart';
import '../common/underline_text_field.dart';

/// Email/password sign-in for the single owner account.
///
/// Not built on [AdminFormSheet]: that scaffold assumes a synchronous
/// `onSave` that pops immediately, which fits a form collecting local data
/// but not a network call that can fail (wrong password, no connection) and
/// needs to show that failure in place rather than closing first.
class AdminSignInSheet extends StatefulWidget {
  const AdminSignInSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AdminSignInSheet(),
    );
  }

  @override
  State<AdminSignInSheet> createState() => _AdminSignInSheetState();
}

class _AdminSignInSheetState extends State<AdminSignInSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await getIt<AdminAuthService>().signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;

    switch (result) {
      case Success<void>():
        Navigator.of(context).pop();
      case Fail<void>(:final message):
        setState(() {
          _busy = false;
          _error = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxWidth: 420.w),
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
                        context.translate(LangKeys.adminSignIn),
                        style: MyFonts.bold22.copyWith(color: colors.onNavy),
                      ),
                    ),
                    IconButton(
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
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      UnderlineTextField(
                        label: context.translate(LangKeys.adminSignInEmail),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                        validator: (value) => Validators.email(context, value),
                      ),
                      UnderlineTextField(
                        label: context.translate(LangKeys.adminSignInPassword),
                        controller: _password,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.password],
                        validator: (value) =>
                            Validators.required(context, value),
                        onChanged: (_) {
                          // Clears a stale "wrong password" message the
                          // instant the admin starts correcting it, rather
                          // than leaving it up until the next failed submit.
                          if (_error != null) setState(() => _error = null);
                        },
                      ),
                      if (_error != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Text(
                            _error!,
                            style: MyFonts.regular14.copyWith(
                              color: colors.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        context.translate(LangKeys.adminCancel),
                        style: MyFonts.semi16.copyWith(
                          color: colors.onNavyMuted,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    PillButton(
                      label: context.translate(LangKeys.adminSignIn),
                      showArrow: false,
                      dense: true,
                      onPressed: _busy ? null : _submit,
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
