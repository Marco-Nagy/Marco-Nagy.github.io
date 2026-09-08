import '../../../../core/styles/app_images.dart';
import '../../domain/entities/media_ref.dart';
import '../../domain/entities/media_shot.dart';
import '../../domain/entities/personal_project.dart';
import '../../domain/entities/shot_background.dart';
import '../../domain/entities/showcase_panel.dart';

/// The complete Projects showcase. Employer work (GARAS ERP, Royal Tents) is
/// intentionally absent — it appears only as Work History bullets.
class SeedProjects {
  const SeedProjects._();

  /// Builds a portrait screenshot panel from an asset path.
  static ShowcasePanel _panel(
    String id,
    String assetPath, {
    required DeviceFrameType frame,
    String captionEn = '',
    String captionAr = '',
    int order = 0,
  }) {
    return ShowcasePanel(
      id: id,
      captionEn: captionEn,
      captionAr: captionAr,
      order: order,
      shots: <MediaShot>[
        MediaShot(
          image: MediaRef.asset(assetPath),
          frame: frame,
          // Slightly oversized so the device crops at the panel's bottom edge,
          // the way the reference store graphics do.
          scale: 1.12,
          offsetY: 0.16,
        ),
      ],
    );
  }

  static List<PersonalProject> get all => <PersonalProject>[
    PersonalProject(
      id: 'flowery_store',
      title: 'Flowery Store',
      titleAr: 'فلاوري ستور',
      category: 'E-Commerce.',
      categoryAr: 'تجارة إلكترونية.',
      description:
          'E-commerce platform for floral products, delivering a smooth '
          'shopping experience with live order tracking, secure payments and a '
          'clean, simple interface.',
      descriptionAr:
          'منصة تجارة إلكترونية لبيع الزهور، توفر تجربة تسوّق سلسة مع تتبع '
          'مباشر للطلبات ومدفوعات آمنة وواجهة استخدام بسيطة.',
      features: const <String>[
        'User Authentication',
        'Product Browsing',
        'Shopping Cart',
        'Real-Time Order Tracking',
        'Secure Payment Processing',
        'Delivery Notifications',
      ],
      featuresAr: const <String>[
        'تسجيل الدخول والمصادقة',
        'تصفح المنتجات',
        'سلة التسوق',
        'تتبع الطلبات في الوقت الفعلي',
        'معالجة مدفوعات آمنة',
        'إشعارات التوصيل',
      ],
      skills: const <String>[
        'Clean Architecture',
        'State Management (Bloc)',
        'REST API Integration',
        'Real-Time Data Sync',
        'Secure Payment Integration',
      ],
      skillsAr: const <String>[
        'العمارة النظيفة',
        'إدارة الحالة (Bloc)',
        'ربط REST APIs',
        'مزامنة بيانات لحظية',
        'تكامل مدفوعات آمنة',
      ],
      technologies: const <String>['Flutter', 'Dart', 'Firebase'],
      tools: const <String>['Git', 'Figma'],
      cover: MediaRef.asset(AppImages.floweryStoreShots.first),
      showcaseBackground: const ShotBackground(
        style: ShotBackgroundStyle.linearGradient,
        colorHex: 'FF6FA5',
        colorHex2: 'FFC2D8',
        overlayOpacity: 0.05,
      ),
      panels: <ShowcasePanel>[
        for (var i = 0; i < AppImages.floweryStoreShots.length; i++)
          _panel(
            'flowery_store_$i',
            AppImages.floweryStoreShots[i],
            frame: DeviceFrameType.iphone,
            order: i,
          ),
      ],
      accentHex: 'FF6FA5',
      order: 0,
    ),
    PersonalProject(
      id: 'flowery_delivery',
      title: 'Flowery Delivery',
      titleAr: 'فلاوري ديليفري',
      category: 'Delivery / Tracking.',
      categoryAr: 'توصيل / تتبع.',
      description:
          'Real-time flower delivery tracking app that helps drivers navigate '
          'efficiently with live maps, keeps customers updated on order status, '
          'and onboards drivers automatically by scanning ID and licence.',
      descriptionAr:
          'تطبيق موبايل لتتبع توصيل الزهور في الوقت الفعلي، يساعد السائقين على '
          'التنقل بكفاءة عبر خرائط حية، ويُبقي العملاء على اطلاع بحالة الطلب، '
          'مع تسجيل تلقائي للسائقين عبر مسح الهوية والرخصة.',
      features: const <String>[
        'Real-Time Tracking',
        'Notification System',
        'Map Integration',
        'Order Management',
        'Automated Driver Registration (ID/licence scan)',
      ],
      featuresAr: const <String>[
        'تتبع في الوقت الفعلي',
        'نظام الإشعارات',
        'تكامل الخرائط',
        'إدارة الطلبات',
        'تسجيل تلقائي للسائقين (مسح الهوية والرخصة)',
      ],
      skills: const <String>[
        'Clean Architecture',
        'Live Location Tracking',
        'Maps Integration',
        'Push Notifications',
        'Document/ID Scanning',
      ],
      skillsAr: const <String>[
        'العمارة النظيفة',
        'تتبع الموقع اللحظي',
        'تكامل الخرائط',
        'إشعارات فورية',
        'مسح المستندات',
      ],
      technologies: const <String>[
        'Flutter',
        'Dart',
        'Firebase',
        'Google Maps',
      ],
      tools: const <String>['Git', 'Figma'],
      cover: MediaRef.asset(AppImages.floweryDeliveryShots.first),
      showcaseBackground: const ShotBackground(
        style: ShotBackgroundStyle.linearGradient,
        colorHex: 'E91E63',
        colorHex2: 'F8BBD0',
        overlayOpacity: 0.05,
      ),
      panels: <ShowcasePanel>[
        for (var i = 0; i < AppImages.floweryDeliveryShots.length; i++)
          _panel(
            'flowery_delivery_$i',
            AppImages.floweryDeliveryShots[i],
            frame: DeviceFrameType.iphone,
            order: i,
          ),
      ],
      accentHex: '3DDC97',
      order: 1,
    ),
    PersonalProject(
      id: 'fitness_app',
      title: 'Fitness App',
      titleAr: 'تطبيق اللياقة',
      category: 'Fitness.',
      categoryAr: 'لياقة.',
      description:
          'Structured workout plans with instructional videos for every level, '
          'meal preparation guides with nutrition info, and a Gemini-powered AI '
          'chatbot that supports fitness and diet questions personally.',
      descriptionAr:
          'تطبيق يقدّم خطط تمارين منظمة مع فيديوهات تعليمية لكل المستويات، '
          'وأدلة تحضير وجبات بمعلومات غذائية، وشات بوت ذكاء اصطناعي (مدعوم بـ '
          'Gemini) لدعم اللياقة والنظام الغذائي بشكل شخصي.',
      features: const <String>[
        'User Authentication',
        'Structured Workout Plans',
        'Instructional Workout Videos',
        'Meal Preparation Guides',
        'AI-Powered Chatbot Assistance',
        'Progress Tracking',
      ],
      featuresAr: const <String>[
        'تسجيل الدخول والمصادقة',
        'خطط تمارين منظمة',
        'فيديوهات تعليمية للتمارين',
        'أدلة تحضير الوجبات',
        'مساعدة عبر شات بوت ذكاء اصطناعي',
        'تتبع التقدم',
      ],
      skills: const <String>[
        'Clean Architecture',
        'Video Playback',
        'AI Chat Integration',
        'Progress Analytics',
      ],
      skillsAr: const <String>[
        'العمارة النظيفة',
        'تشغيل الفيديو',
        'تكامل شات بوت ذكاء اصطناعي',
        'تحليلات التقدم',
      ],
      technologies: const <String>['Flutter', 'Dart', 'Firebase', 'Gemini API'],
      tools: const <String>['Git', 'Figma'],
      cover: MediaRef.asset(AppImages.fitnessAppShots.first),
      showcaseBackground: const ShotBackground(
        style: ShotBackgroundStyle.linearGradient,
        colorHex: '3A1C71',
        colorHex2: 'FFAF7B',
        overlayOpacity: 0.1,
      ),
      panels: <ShowcasePanel>[
        for (var i = 0; i < AppImages.fitnessAppShots.length; i++)
          _panel(
            'fitness_app_$i',
            AppImages.fitnessAppShots[i],
            frame: DeviceFrameType.samsungS,
            order: i,
          ),
      ],
      accentHex: 'FFB020',
      order: 2,
    ),
  ];
}
