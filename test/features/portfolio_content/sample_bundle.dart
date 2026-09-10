import 'package:marco_portfolio/features/portfolio_content/domain/entities/certificate.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/custom_section_item.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/image_ref.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/media_ref.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/media_shot.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/personal_project.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/portfolio_bundle.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/pricing_add_on.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/pricing_package.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/project_link.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/project_video.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/section_definition.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/shot_background.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/showcase_panel.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/site_content.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/skill_group_entity.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/tech_badge_entity.dart';
import 'package:marco_portfolio/features/portfolio_content/domain/entities/work_history_entry.dart';

/// Hand-built fixtures for tests that need realistic, non-default content
/// without depending on `lib/features/portfolio_content/data/seed/` — deleted
/// in Phase 1 of the Firebase migration (see docs/firebase-migration-plan.md)
/// once its content was exported once to bootstrap Firestore.
///
/// Every field on every entity here is set away from its default, including
/// nested ones (a project's panels/shots/links, a background's gradient
/// colours). A round-trip test built on all-default fixtures would pass even
/// if a field's `toJson`/`fromJson` pair silently dropped it, because the
/// decoded default and the missing-key default look identical.

PersonalProject sampleProject({String id = 'proj-1'}) => PersonalProject(
  id: id,
  title: 'Flowery Store',
  titleAr: 'متجر فلاورى',
  description: 'A flower e-commerce app.',
  descriptionAr: 'تطبيق تجارة إلكترونية للزهور.',
  features: const <String>['Cart', 'Checkout'],
  featuresAr: const <String>['السلة', 'الدفع'],
  category: 'E-commerce',
  categoryAr: 'تجارة إلكترونية',
  cover: MediaRef.asset('assets/projects/$id/cover.png'),
  panels: <ShowcasePanel>[
    ShowcasePanel(
      id: '$id-panel-1',
      format: ShowcaseFormat.screenshot,
      backgroundOverride: const ShotBackground(
        style: ShotBackgroundStyle.linearGradient,
        colorHex: '112233',
        colorHex2: '445566',
        overlayOpacity: 0.4,
        blurSigma: 2,
      ),
      shots: <MediaShot>[
        MediaShot(
          image: MediaRef.asset('assets/projects/$id/shot_1.png'),
          frame: DeviceFrameType.iphone,
          rotationDegrees: 4,
          scale: 1.05,
          offsetX: 0.1,
          offsetY: -0.1,
        ),
      ],
      captionEn: 'Home screen',
      captionAr: 'الشاشة الرئيسية',
      subtitleEn: 'Browse flowers by category',
      subtitleAr: 'تصفح الزهور حسب الفئة',
      captionPlacement: CaptionPlacement.bottom,
      captionColorHex: '112233',
      order: 1,
    ),
  ],
  videos: <ProjectVideo>[
    ProjectVideo(
      id: '$id-video-1',
      media: MediaRef.videoFile(
        'assets/projects/$id/demo.mp4',
        poster: ImageRef.asset('assets/projects/$id/poster.png'),
      ),
      aspectRatio: 16 / 9,
      captionEn: 'Checkout flow',
      captionAr: 'مسار الدفع',
      subtitleEn: 'End to end purchase',
      subtitleAr: 'عملية شراء كاملة',
      captionPlacement: CaptionPlacement.start,
      captionColorHex: 'FFFFFF',
      backgroundOverride: const ShotBackground(
        style: ShotBackgroundStyle.solid,
        colorHex: '000000',
      ),
      order: 2,
    ),
  ],
  showcaseBackground: const ShotBackground(
    style: ShotBackgroundStyle.radialGradient,
    colorHex: '0A1533',
    colorHex2: '1B3F8F',
    overlayOpacity: 0.25,
    blurSigma: 1.5,
  ),
  links: <ProjectLink>[
    const ProjectLink(type: ProjectLinkType.gitHub, url: 'https://github.com/x'),
    const ProjectLink(
      type: ProjectLinkType.playStore,
      url: 'https://play.google.com/x',
    ),
  ],
  skills: const <String>['Clean Architecture', 'State management'],
  skillsAr: const <String>['العمارة النظيفة', 'إدارة الحالة'],
  technologies: const <String>['Flutter', 'Firebase'],
  tools: const <String>['Git', 'Figma'],
  accentHex: 'AB12CD',
  order: 1,
);

Certificate sampleCertificate({String id = 'cert-1'}) => Certificate(
  id: id,
  title: 'Flutter Bootcamp',
  titleAr: 'معسكر فلاتر',
  provider: 'Udemy',
  providerAr: 'يوديمي',
  year: '2024',
  location: 'Online',
  locationAr: 'أونلاين',
  imageAsset: 'assets/certificates/$id.png',
  order: 1,
);

WorkHistoryEntry sampleWorkHistoryEntry({String id = 'work-1'}) =>
    WorkHistoryEntry(
      id: id,
      company: 'Steps',
      role: 'Flutter Developer',
      roleAr: 'مطور فلاتر',
      startDate: '2023-01',
      endDate: '2024-06',
      location: 'Cairo',
      locationAr: 'القاهرة',
      bullets: const <String>['Shipped 3 apps'],
      bulletsAr: const <String>['أطلقت 3 تطبيقات'],
      order: 1,
    );

PricingPackage samplePricingPackage({String id = 'pkg-1'}) => PricingPackage(
  id: id,
  name: 'Starter',
  nameAr: 'مبتدئ',
  basePrice: 400,
  timelineLabel: '2 weeks',
  timelineLabelAr: 'أسبوعين',
  description: 'A small app.',
  descriptionAr: 'تطبيق صغير.',
  order: 1,
);

PricingAddOn samplePricingAddOn({String id = 'addon-1'}) => PricingAddOn(
  id: id,
  name: 'Push notifications',
  nameAr: 'إشعارات',
  unitPrice: 50,
  unitTimeDays: 2,
  hasCounter: true,
  category: 'Feature',
  categoryAr: 'ميزة',
  order: 1,
);

SkillGroupEntity sampleSkillGroup({String id = 'skillgroup-1'}) =>
    SkillGroupEntity(
      id: id,
      labelEn: 'State management',
      labelAr: 'إدارة الحالة',
      skills: const <String>['Bloc', 'Provider'],
      order: 1,
    );

TechBadgeEntity sampleTechBadge({String id = 'badge-1'}) => TechBadgeEntity(
  id: id,
  label: 'Flutter',
  iconKey: 'flutter',
  order: 1,
);

SectionDefinition sampleSection({String id = 'section-1'}) => SectionDefinition(
  id: id,
  type: SectionType.listRows,
  kind: SectionKind.custom,
  titleEn: 'Extras',
  titleAr: 'إضافات',
  order: 1,
  visible: true,
);

CustomSectionItem sampleCustomSectionItem({
  String id = 'item-1',
  String sectionId = 'section-1',
}) => CustomSectionItem(
  id: id,
  sectionId: sectionId,
  titleEn: 'Title',
  titleAr: 'عنوان',
  subtitleEn: 'Subtitle',
  subtitleAr: 'عنوان فرعي',
  descriptionEn: 'Description',
  descriptionAr: 'وصف',
  bulletsEn: const <String>['one', 'two'],
  bulletsAr: const <String>['واحد', 'اثنان'],
  tagEn: 'Tag',
  tagAr: 'وسم',
  dateStart: '2024-01',
  dateEnd: '2025-06',
  year: '2025',
  images: <ImageRef>[ImageRef.asset('assets/custom/$id.png')],
  accentHex: 'FF00AA',
  linkUrl: 'https://example.com',
  order: 3,
);

SiteContent sampleSiteContent() => SiteContent(
  fullNameEn: 'Marco Nagy',
  fullNameAr: 'ماركو نجى',
  roleEn: 'Flutter Developer',
  roleAr: 'مطور فلاتر',
  // Not 'MN': that is the entity's own default, and a fixture that matches
  // the default proves nothing about whether the field serialises.
  monogram: 'MNL',
  locationEn: 'Cairo, Egypt',
  locationAr: 'القاهرة، مصر',
  profileImage: ImageRef.asset('assets/images/profile.png'),
  aboutPhotoImage: ImageRef.asset('assets/images/about.png'),
  email: 'marco@example.com',
  phone: '+201234567890',
  gitHubUrl: 'https://github.com/marco',
  linkedInUrl: 'https://linkedin.com/in/marco',
  hostedCvUrl: 'https://example.com/cv.pdf',
  heroGreetingEn: "Hi, I'm",
  heroGreetingAr: 'مرحباً، أنا',
  heroNameEn: 'Marco.',
  heroNameAr: 'ماركو.',
  heroRoleEn: 'Flutter Developer.',
  heroRoleAr: 'مطور فلاتر.',
  roleTagsEn: <String>['Flutter Developer', 'Mobile Engineer'],
  roleTagsAr: <String>['مطور فلاتر', 'مهندس موبايل'],
  summaryEn: 'Building clean, tested apps.',
  summaryAr: 'أبني تطبيقات نظيفة ومختبرة.',
  aboutLeadEn: 'A bit about me.',
  aboutLeadAr: 'نبذة عني.',
  aboutStatementsEn: <String>['I ship fast.'],
  aboutStatementsAr: <String>['أشحن بسرعة.'],
  footerHeadlineEn: "Let's build something.",
  footerHeadlineAr: 'خلينا نبني حاجة.',
  footerAvailabilityEn: 'Available for freelance',
  footerAvailabilityAr: 'متاح للعمل الحر',
  contactTitleEn: 'Contact',
  contactTitleAr: 'تواصل',
  contactSubtitleEn: "Let's talk",
  contactSubtitleAr: 'يلا نتكلم',
  homeWorksHeadlineEn: 'Crafted with care.',
  homeWorksHeadlineAr: 'مصنوع بعناية.',
  homeWorksSubtitleEn: 'A selection of recent work.',
  homeWorksSubtitleAr: 'مختارات من أعمالي الأخيرة.',
  homeWorksMoreLabelEn: "There's more",
  homeWorksMoreLabelAr: 'وهناك المزيد',
  homeWorksViewAllEn: 'View all projects',
  homeWorksViewAllAr: 'عرض كل المشاريع',
);

/// A full bundle composed from the fixtures above — one item per collection,
/// which exercises every level of nesting without recreating seed-scale data.
PortfolioBundle sampleBundle({
  int contentVersion = 0,
  int schemaVersion = PortfolioBundle.currentSchemaVersion,
}) => PortfolioBundle(
  projects: <PersonalProject>[sampleProject()],
  certificates: <Certificate>[sampleCertificate()],
  workHistory: <WorkHistoryEntry>[sampleWorkHistoryEntry()],
  pricingPackages: <PricingPackage>[samplePricingPackage()],
  pricingAddOns: <PricingAddOn>[samplePricingAddOn()],
  siteContent: sampleSiteContent(),
  skillGroups: <SkillGroupEntity>[sampleSkillGroup()],
  techBadges: <TechBadgeEntity>[sampleTechBadge()],
  sections: <SectionDefinition>[sampleSection()],
  customItems: <String, List<CustomSectionItem>>{
    'section-1': <CustomSectionItem>[sampleCustomSectionItem()],
  },
  contentVersion: contentVersion,
  schemaVersion: schemaVersion,
);
