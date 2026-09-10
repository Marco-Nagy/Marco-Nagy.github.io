import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styles/fonts/my_fonts.dart';
import '../../../../core/utils/extension/context_extensions.dart';
import '../../../../core/utils/extension/site_content_extensions.dart';
import '../../../../core/widgets/common/app_image.dart';
import '../../../../core/widgets/common/hatched_circle.dart';

/// Rounded-square portrait sitting on a textured accent backdrop, offset so the
/// backdrop peeks out behind it.
class AboutPhotoCard extends StatelessWidget {
  const AboutPhotoCard({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: size + 40.w,
      height: size + 40.h,
      child: Stack(
        children: <Widget>[
          // Textured backdrop, offset behind the photo.
          PositionedDirectional(
            end: 0,
            top: 0,
            child: Opacity(
              opacity: 0.5,
              child: HatchedCircle(diameter: size * 0.55),
            ),
          ),
          PositionedDirectional(
            start: 0,
            bottom: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.r),
                gradient: context.gradients.surfacePanel,
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.35),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colors.pageTop.withValues(alpha: 0.55),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27.r),
                child: AppImage(
                  image: context.site.aboutPhoto,
                  width: size,
                  height: size,
                  fallback: Center(
                    child: Text(
                      context.site.monogram,
                      style: MyFonts.display48.copyWith(color: colors.accent),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
