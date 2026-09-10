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
import '../view_model/pricing_actions.dart';
import '../view_model/pricing_states.dart';
import '../view_model/pricing_view_model.dart';
import '../widgets/pricing_add_on_tile.dart';
import '../widgets/pricing_package_card.dart';
import '../widgets/quote_summary.dart';

/// Pricing lives on its own screen reached from the nav, never inline on Home.
class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PricingViewModelCubit>(
      create: (_) => getIt<PricingViewModelCubit>()..doAction(LoadPricing()),
      child: const _PricingBodyRoot(),
    );
  }
}

class _PricingBodyRoot extends StatelessWidget {
  const _PricingBodyRoot();

  @override
  Widget build(BuildContext context) {
    final title = context.sectionTitle(BuiltInSectionIds.pricing);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionDividerHeader(title: title),
        ContentContainer(
          child: BlocBuilder<PricingViewModelCubit, PricingState>(
            builder: (context, state) => switch (state) {
              PricingInitial() || PricingLoading() => Padding(
                padding: EdgeInsets.symmetric(vertical: 64.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.accent,
                  ),
                ),
              ),
              PricingError() => _PricingMessage(text: state.message),
              PricingReady() => _PricingBody(state: state),
            },
          ),
        ),
        SizedBox(height: 96.h),
      ],
    );
  }
}

class _PricingBody extends StatelessWidget {
  const _PricingBody({required this.state});

  final PricingReady state;

  @override
  Widget build(BuildContext context) {
    if (state.packages.isEmpty && state.addOns.isEmpty) {
      return _PricingMessage(text: context.translate(LangKeys.pricingEmpty));
    }

    final cubit = context.read<PricingViewModelCubit>();
    final summary = QuoteSummary(
      state: state,
      onReset: () => cubit.doAction(ResetQuote()),
      compact: !context.isWide,
    );

    final selectors = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate(LangKeys.pricingLead),
          style: MyFonts.statement20.copyWith(
            color: context.colors.onNavyMuted,
          ),
        ),
        SizedBox(height: 36.h),
        _SectionLabel(text: context.translate(LangKeys.pricingBasePackages)),
        SizedBox(height: 16.h),
        _PackageGrid(state: state, cubit: cubit),
        SizedBox(height: 40.h),
        _SectionLabel(text: context.translate(LangKeys.pricingAddOns)),
        SizedBox(height: 16.h),
        _AddOnList(state: state, cubit: cubit),
      ],
    );

    if (!context.isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RevealOnScroll(child: selectors),
          SizedBox(height: 32.h),
          RevealOnScroll(delay: Motion.stagger, child: summary),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(flex: 7, child: RevealOnScroll(child: selectors)),
        SizedBox(width: 36.w),
        Expanded(
          flex: 4,
          // Stays in view while the long add-on list scrolls past it.
          child: RevealOnScroll(delay: Motion.stagger, child: summary),
        ),
      ],
    );
  }
}

class _PackageGrid extends StatelessWidget {
  const _PackageGrid({required this.state, required this.cubit});

  final PricingReady state;
  final PricingViewModelCubit cubit;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      for (final package in state.packages)
        PricingPackageCard(
          key: ValueKey<String>(package.id),
          package: package,
          isSelected: state.selection.package?.id == package.id,
          onSelected: () => cubit.doAction(SelectPackage(package)),
          onEdit: () {},
          onDelete: () => cubit.doAction(DeletePackage(package.id)),
        ),
    ];

    if (!context.isDesktop) {
      return Column(
        children: <Widget>[
          for (final card in cards)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: card,
            ),
        ],
      );
    }

    // IntrinsicHeight gives the row a real height to stretch into. Without it,
    // `stretch` inside the page's unbounded-height scroll view asks for
    // infinite height and the whole pricing section fails to lay out.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < cards.length; i++) ...<Widget>[
            Expanded(child: cards[i]),
            if (i != cards.length - 1) SizedBox(width: 16.w),
          ],
        ],
      ),
    );
  }
}

class _AddOnList extends StatelessWidget {
  const _AddOnList({required this.state, required this.cubit});

  final PricingReady state;
  final PricingViewModelCubit cubit;

  @override
  Widget build(BuildContext context) {
    // Group by category so a long flat list stays scannable.
    final grouped = <String, List<int>>{};
    for (var i = 0; i < state.addOns.length; i++) {
      final addOn = state.addOns[i];
      final label = context.localized(addOn.category, addOn.categoryAr);
      grouped.putIfAbsent(label, () => <int>[]).add(i);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final entry in grouped.entries) ...<Widget>[
          if (entry.key.trim().isNotEmpty) ...<Widget>[
            SizedBox(height: 8.h),
            Text(
              entry.key.toUpperCase(),
              style: MyFonts.caps10.copyWith(color: context.colors.accent),
            ),
            SizedBox(height: 12.h),
          ],
          for (final index in entry.value)
            PricingAddOnTile(
              key: ValueKey<String>(state.addOns[index].id),
              addOn: state.addOns[index],
              quantity: state.selection.quantityOf(state.addOns[index].id),
              onToggle: () =>
                  cubit.doAction(ToggleAddOn(state.addOns[index].id)),
              onQuantityChanged: (quantity) => cubit.doAction(
                ChangeAddOnQuantity(state.addOns[index].id, quantity),
              ),
              onEdit: () {},
              onDelete: () =>
                  cubit.doAction(DeleteAddOn(state.addOns[index].id)),
            ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: MyFonts.bold22.copyWith(color: context.colors.onNavy),
    );
  }
}

class _PricingMessage extends StatelessWidget {
  const _PricingMessage({required this.text});

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
