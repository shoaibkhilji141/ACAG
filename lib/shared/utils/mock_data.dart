import '../models/models.dart';

class MockData {
  static const engineerName = 'Shoaib Khilji';
  static const engineerLocation = 'Lahore, Punjab';
  static const ownerName = 'Ali Raza';
  static const ownerLocation = 'Raiwind Road, Lahore';

  static const kpis = (
    assigned: 1,
    todayInspections: 1,
    pending: 0,
    completed: 0,
    completionPercent: 15,
  );

  static final projects = <ProjectModel>[
    ProjectModel(
      id: 'ACAG-1',
      title: 'House #ACAG-1',
      address: 'Johar Town, Block A',
      city: 'Lahore',
      ownerName: 'Ali Raza',
      engineerName: 'Shoaib Khilji',
      progress: 0.15,
      status: ProjectStatus.inProgress,
      phase: 'Foundation',
      nextInspection: 'Next week',
      lat: 31.4697,
      lng: 74.2728,
    ),
  ];

  static ProjectModel get primaryProject => projects.first;

  static const notifications = <NotificationModel>[
    NotificationModel(
      title: 'Inspection pending at House #ACAG-1',
      subtitle: 'Johar Town, Lahore',
      timeAgo: '30m ago',
      type: NotificationType.warning,
    ),
    NotificationModel(
      title: 'New project assigned to you',
      subtitle: 'House #ACAG-1 added to queue',
      timeAgo: '1h ago',
      type: NotificationType.info,
    ),
  ];

  static const ownerUpdates = <NotificationModel>[
    NotificationModel(
      title: 'Brick work completed',
      subtitle: 'Stage updated by Engineer after site visit on May 18.',
      timeAgo: '10:30 AM',
      type: NotificationType.success,
    ),
    NotificationModel(
      title: 'Inspection scheduled',
      subtitle: 'Next inspection for roof leveling set for May 20, 2025.',
      timeAgo: '04:15 PM',
      type: NotificationType.info,
    ),
    NotificationModel(
      title: 'Material delivery',
      subtitle: 'Consignment of 5000 A-grade bricks delivered successfully.',
      timeAgo: '01:20 PM',
      type: NotificationType.warning,
    ),
  ];

  static const stages = <ProgressStage>[
    ProgressStage(
      title: 'Site Clearance',
      date: '01 Mar 2025',
      completed: true,
    ),
    ProgressStage(
      title: 'Foundation',
      date: '15 Mar 2025',
      completed: true,
    ),
    ProgressStage(
      title: 'Plinth Beam',
      date: '02 Apr 2025',
      completed: true,
    ),
    ProgressStage(
      title: 'Brick Work',
      date: '18 May 2025',
      completed: true,
      note: 'Verified by Engr. Usman',
    ),
    ProgressStage(
      title: 'Roof Casting',
      date: 'Scheduled',
      completed: false,
    ),
    ProgressStage(
      title: 'Finishing',
      date: 'Pending',
      completed: false,
    ),
  ];

  static const materials = <MaterialItem>[
    MaterialItem(
      name: 'A-Grade Bricks',
      quantity: '5,000',
      unit: 'pcs',
      status: 'Delivered',
      date: '16 May 2025',
    ),
    MaterialItem(
      name: 'Cement Bags',
      quantity: '120',
      unit: 'bags',
      status: 'Delivered',
      date: '14 May 2025',
    ),
    MaterialItem(
      name: 'Steel Bars (10mm)',
      quantity: '2.5',
      unit: 'tons',
      status: 'In Transit',
      date: 'Expected 21 May',
    ),
    MaterialItem(
      name: 'Sand',
      quantity: '8',
      unit: 'trucks',
      status: 'Delivered',
      date: '12 May 2025',
    ),
  ];

  static const reports = <ReportItem>[
    ReportItem(
      id: 'RPT-1042',
      title: 'Brick Work Inspection',
      date: '18 May 2025',
      result: 'Approved',
      score: 92,
    ),
    ReportItem(
      id: 'RPT-1031',
      title: 'Plinth Beam Validation',
      date: '02 Apr 2025',
      result: 'Approved',
      score: 88,
    ),
    ReportItem(
      id: 'RPT-1018',
      title: 'Foundation Check',
      date: '15 Mar 2025',
      result: 'Approved',
      score: 95,
    ),
  ];

  static const photos = <PhotoItem>[
    PhotoItem(label: 'Front elevation', date: '18 May 2025', phase: 'Brick Work'),
    PhotoItem(label: 'Side wall progress', date: '18 May 2025', phase: 'Brick Work'),
    PhotoItem(label: 'Foundation pour', date: '15 Mar 2025', phase: 'Foundation'),
    PhotoItem(label: 'Site overview', date: '01 Mar 2025', phase: 'Clearance'),
  ];

  static const aiChecks = <(String, bool, String)>[
    ('GPS location match', true, 'Within 12m of registered plot'),
    ('Stage visual match', true, 'Brick work pattern detected'),
    ('Image quality', true, 'Sharpness & lighting OK'),
    ('Duplicate detection', true, 'No duplicate upload found'),
    ('Safety hazards', false, 'Scaffolding incomplete — review'),
  ];
}
