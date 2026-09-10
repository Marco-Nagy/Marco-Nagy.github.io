import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../../../../core/utils/responsive/app_breakpoints.dart';
import '../../../../core/widgets/admin/admin_add_button.dart';
import '../../../../core/widgets/admin/admin_confirm_dialog.dart';
import '../../../../core/widgets/common/app_snack_bar.dart';
import '../../../../core/widgets/common/content_container.dart';
import '../../../../core/widgets/motion/motion_durations.dart';
import '../../../../core/widgets/motion/reveal_on_scroll.dart';
import '../../../../core/widgets/section/section_divider_header.dart';
import '../../../../di/di.dart';
import '../../../portfolio_content/domain/entities/certificate.dart';
import '../../../portfolio_content/presentation/view_data/grid_card_data.dart';
import '../view_model/certificates_actions.dart';
import '../view_model/certificates_states.dart';
import '../view_model/certificates_view_model.dart';
import '../widgets/certificate_card.dart';
import '../widgets/certificate_form_screen.dart';

/// Certificates render as a responsive grid of certificate cards — explicitly
/// not the numbered-row pattern used by Projects.
class CertificatesSection extends StatelessWidget {
  const CertificatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CertificatesViewModelCubit>(
      create: (_) =>
          getIt<CertificatesViewModelCubit>()..doAction(LoadCertificates()),
      child: const _CertificatesBody(),
    );
  }
}

class _CertificatesBody extends StatelessWidget {
  const _CertificatesBody();

  @override
  Widget build(BuildContext context) {
    final title = context.sectionTitle(BuiltInSectionIds.certificates);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionDividerHeader(title: title),
        ContentContainer(
          child: BlocBuilder<CertificatesViewModelCubit, CertificatesState>(
            builder: (context, state) => switch (state) {
              CertificatesInitial() || CertificatesLoading() => Padding(
                padding: EdgeInsets.symmetric(vertical: 64.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.accent,
                  ),
                ),
              ),
              CertificatesError() => _CertificatesMessage(text: state.message),
              CertificatesSuccess() => _CertificatesGrid(
                certificates: state.certificates,
              ),
            },
          ),
        ),
        SizedBox(height: 96.h),
      ],
    );
  }
}

class _CertificatesGrid extends StatelessWidget {
  const _CertificatesGrid({required this.certificates});

  final List<Certificate> certificates;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CertificatesViewModelCubit>();

    // The add button sits outside the empty check: an empty grid is exactly
    // when adding the first certificate has to be reachable.
    if (certificates.isEmpty) {
      return Column(
        children: <Widget>[
          _CertificatesMessage(
            text: context.translate(LangKeys.certificatesEmpty),
          ),
          _AddCertificateButton(cubit: cubit),
        ],
      );
    }

    // Two columns on tablet and desktop, one on mobile.
    final columns = context.isWide ? 2 : 1;

    return Column(
      children: <Widget>[
        _CertificatesGridView(
          certificates: certificates,
          columns: columns,
          cubit: cubit,
        ),
        SizedBox(height: 24.h),
        _AddCertificateButton(cubit: cubit),
      ],
    );
  }
}

class _CertificatesGridView extends StatelessWidget {
  const _CertificatesGridView({
    required this.certificates,
    required this.columns,
    required this.cubit,
  });

  final List<Certificate> certificates;
  final int columns;
  final CertificatesViewModelCubit cubit;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: certificates.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.h,
        childAspectRatio: context.isWide ? 1.35 : 1.5,
      ),
      itemBuilder: (context, index) {
        final certificate = certificates[index];
        return RevealOnScroll(
          // Stagger across the row, not the whole grid, so the last card in a
          // long list is not left waiting seconds to appear.
          delay: Motion.stagger * (index % (columns * 2)),
          child: CertificateCard(
            key: ValueKey<String>(certificate.id),
            data: GridCardData.fromCertificate(certificate, context.isArabic),
            onEdit: () => _editCertificate(context, cubit, certificate),
            onDelete: () => _deleteCertificate(context, cubit, certificate.id),
          ),
        );
      },
    );
  }
}

class _AddCertificateButton extends StatelessWidget {
  const _AddCertificateButton({required this.cubit});

  final CertificatesViewModelCubit cubit;

  @override
  Widget build(BuildContext context) {
    return AdminAddButton(
      label: context.translate(LangKeys.adminAdd),
      onPressed: () => _editCertificate(context, cubit, null),
    );
  }
}

/// Opens the form for [certificate] (or a blank one when null) and saves what
/// comes back.
///
/// The cubit is passed in rather than read after the await: the card that owns
/// this context can be rebuilt away while the form is open.
Future<void> _editCertificate(
  BuildContext context,
  CertificatesViewModelCubit cubit,
  Certificate? certificate,
) async {
  final built = await CertificateFormScreen.open(
    context,
    certificate: certificate,
  );
  if (built == null || !context.mounted) return;

  cubit.doAction(SaveCertificate(built));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminSaved),
    kind: SnackKind.success,
  );
}

Future<void> _deleteCertificate(
  BuildContext context,
  CertificatesViewModelCubit cubit,
  String id,
) async {
  final confirmed = await AdminConfirmDialog.show(context);
  if (!confirmed || !context.mounted) return;

  cubit.doAction(DeleteCertificate(id));
  AppSnackBar.show(
    context,
    context.translate(LangKeys.adminDeleted),
    kind: SnackKind.success,
  );
}

class _CertificatesMessage extends StatelessWidget {
  const _CertificatesMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 64.h),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: MyFonts.regular16.copyWith(color: context.colors.onNavyMuted),
        ),
      ),
    );
  }
}
