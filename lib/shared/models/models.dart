enum ProjectStatus { pending, inProgress, completed, overdue }

class MaterialLine {
  const MaterialLine({
    required this.name,
    required this.unit,
    required this.qty,
  });

  final String name;
  final String unit;
  final String qty;
}

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.title,
    required this.address,
    required this.city,
    required this.ownerName,
    required this.engineerName,
    required this.progress,
    required this.status,
    required this.phase,
    required this.nextInspection,
    this.ownerPhone,
    this.imageUrl,
    this.lat = 31.5204,
    this.lng = 74.3587,
    this.district,
    this.tehsil,
    this.plotSizeLabel,
    this.coveredAreaLabel,
    this.startDateLabel,
    this.estimatedCompletionLabel,
    this.storiesLabel,
    this.lastVisitLabel,
  });

  final String id;
  final String title;
  final String address;
  final String city;
  final String ownerName;
  final String? ownerPhone;
  final String engineerName;
  final double progress;
  final ProjectStatus status;
  final String phase;
  final String nextInspection;
  final String? imageUrl;
  final double lat;
  final double lng;
  final String? district;
  final String? tehsil;
  final String? plotSizeLabel;
  final String? coveredAreaLabel;
  final String? startDateLabel;
  final String? estimatedCompletionLabel;
  final String? storiesLabel;
  final String? lastVisitLabel;

  String get statusLabel => switch (status) {
        ProjectStatus.pending => 'Pending',
        ProjectStatus.inProgress => 'In Progress',
        ProjectStatus.completed => 'Completed',
        ProjectStatus.overdue => 'Overdue',
      };

  String get locationLine {
    final parts = <String>[
      if (address.trim().isNotEmpty) address.trim(),
      if (tehsil != null && tehsil!.trim().isNotEmpty) tehsil!.trim(),
      if (district != null && district!.trim().isNotEmpty) district!.trim(),
      if (city.trim().isNotEmpty) city.trim(),
    ];
    return parts.isEmpty ? '—' : parts.join(', ');
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? address,
    String? city,
    String? ownerName,
    String? ownerPhone,
    String? engineerName,
    double? progress,
    ProjectStatus? status,
    String? phase,
    String? nextInspection,
    String? imageUrl,
    double? lat,
    double? lng,
    String? district,
    String? tehsil,
    String? plotSizeLabel,
    String? coveredAreaLabel,
    String? startDateLabel,
    String? estimatedCompletionLabel,
    String? storiesLabel,
    String? lastVisitLabel,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      city: city ?? this.city,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      engineerName: engineerName ?? this.engineerName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      nextInspection: nextInspection ?? this.nextInspection,
      imageUrl: imageUrl ?? this.imageUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      district: district ?? this.district,
      tehsil: tehsil ?? this.tehsil,
      plotSizeLabel: plotSizeLabel ?? this.plotSizeLabel,
      coveredAreaLabel: coveredAreaLabel ?? this.coveredAreaLabel,
      startDateLabel: startDateLabel ?? this.startDateLabel,
      estimatedCompletionLabel:
          estimatedCompletionLabel ?? this.estimatedCompletionLabel,
      storiesLabel: storiesLabel ?? this.storiesLabel,
      lastVisitLabel: lastVisitLabel ?? this.lastVisitLabel,
    );
  }
}

class NotificationModel {
  const NotificationModel({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.type,
    this.id,
    this.isRead = true,
    this.category,
    this.projectId,
    this.createdAt,
  });

  final String? id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final NotificationType type;
  final bool isRead;
  final String? category;
  final String? projectId;
  final DateTime? createdAt;
}

class ModuleReportItem {
  const ModuleReportItem({
    required this.project,
    required this.moduleNo,
    required this.completedAt,
  });

  final ProjectModel project;
  final int moduleNo;
  final DateTime completedAt;
}

enum NotificationType { warning, info, success }

class ProgressStage {
  const ProgressStage({
    required this.title,
    required this.date,
    required this.completed,
    this.note,
  });

  final String title;
  final String date;
  final bool completed;
  final String? note;
}

class MaterialItem {
  const MaterialItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.date,
  });

  final String name;
  final String quantity;
  final String unit;
  final String status;
  final String date;
}

class ReportItem {
  const ReportItem({
    required this.id,
    required this.title,
    required this.date,
    required this.result,
    required this.score,
  });

  final String id;
  final String title;
  final String date;
  final String result;
  final int score;
}

class PhotoItem {
  const PhotoItem({
    required this.label,
    required this.date,
    required this.phase,
  });

  final String label;
  final String date;
  final String phase;
}
