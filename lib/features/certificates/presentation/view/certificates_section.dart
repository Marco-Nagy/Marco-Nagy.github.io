import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../portfolio_content/domain/entities/section_definition.dart';
import '../../../../core/utils/responsive/app_breakpoints.dart';
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
    if (certificates.isEmpty) {
      return _CertificatesMessage(
        text: context.translate(LangKeys.certificatesEmpty),
      );
    }

    final cubit = context.read<CertificatesViewModelCubit>();
    // Two columns on tablet and desktop, one on mobile.
    final columns = context.isWide ? 2 : 1;

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
            onEdit: () {},
            onDelete: () => cubit.doAction(DeleteCertificate(certificate.id)),
          ),
        );
      },
    );
  }
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
