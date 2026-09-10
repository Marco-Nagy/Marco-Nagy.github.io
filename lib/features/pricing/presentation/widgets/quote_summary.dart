import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../../core/utils/url_opener.dart';
import '../../../../core/widgets/common/pill_button.dart';
import '../view_model/pricing_states.dart';

/// Live quote total. Sticky at the bottom on mobile, a side panel on desktop.
class QuoteSummary extends StatelessWidget {
  const QuoteSummary({
    required this.state,
    required this.onReset,
    this.compact = false,
    super.key,
  });

  final PricingReady state;
  final VoidCallback onReset;
  final bool compact;

  String _timeline(BuildContext context) {
    final packageLabel = state.selection.package == null
        ? ''
        : context.localized(
            state.selection.package!.timelineLabel,
            state.selection.package!.timelineLabelAr,
          );
    if (state.addOnDays == 0) return packageLabel;

    final dayLabel = context.translate(
      state.addOnDays == 1 ? LangKeys.pricingDay : LangKeys.pricingDays,
    );
    final extra = '+ ${state.addOnDays} $dayLabel';
    return packageLabel.isEmpty ? extra : '$packageLabel  $extra';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(compact ? 18.r : 24.r),
      decoration: BoxDecoration(
        gradient: context.gradients.surfacePanel,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            context.translate(LangKeys.pricingEstimatedTotal).toUpperCase(),
            style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
          ),
          SizedBox(height: 8.h),
          Text(
            '\$${state.total}',
            style: MyFonts.display48.copyWith(color: colors.accent),
          ),
          SizedBox(height: 14.h),
          Text(
            context.translate(LangKeys.pricingEstimatedTimeline).toUpperCase(),
            style: MyFonts.caps10.copyWith(color: colors.onNavyFaint),
          ),
          SizedBox(height: 6.h),
          Text(
            _timeline(context),
            style: MyFonts.semi16.copyWith(color: colors.onNavy),
          ),
          SizedBox(height: 20.h),
          PillButton(
            label: context.translate(LangKeys.pricingRequestQuote),
            onPressed: () => UrlOpener.open(
              context.siteLinks.mailto(
                subject: context.translate(LangKeys.pricingRequestQuote),
                body: _quoteBody(context),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: onReset,
            child: Text(
              context.translate(LangKeys.pricingReset),
              style: MyFonts.regular14.copyWith(color: colors.onNavyMuted),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.translate(LangKeys.pricingNote),
            style: MyFonts.regular12.copyWith(color: colors.onNavyFaint),
          ),
        ],
      ),
    );
  }

  /// Prefills the email so an enquiry arrives with the picked scope attached.
  String _quoteBody(BuildContext context) {
    final lines = <String>[];
    final package = state.selection.package;
    if (package != null) {
      lines.add(
        '${context.localized(package.name, package.nameAr)} — '
        '\$${package.basePrice}',
      );
    }
    for (final addOn in state.addOns) {
      final quantity = state.selection.quantityOf(addOn.id);
      if (quantity == 0) continue;
      final name = context.localized(addOn.name, addOn.nameAr);
      lines.add(
        addOn.hasCounter
            ? '$name x$quantity — \$${addOn.unitPrice * quantity}'
            : '$name — \$${addOn.unitPrice}',
      );
    }
    lines.add('');
    lines.add(
      '${context.translate(LangKeys.pricingEstimatedTotal)}: \$${state.total}',
    );
    return lines.join('\n');
  }
}
