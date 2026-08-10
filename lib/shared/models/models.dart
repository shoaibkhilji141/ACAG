enum ProjectStatus { pending, inProgress, completed, overdue }

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
    this.imageUrl,
    this.lat = 31.5204,
    this.lng = 74.3587,
  });

  final String id;
  final String title;
  final String address;
  final String city;
  final String ownerName;
  final String engineerName;
  final double progress;
  final ProjectStatus status;
  final String phase;
  final String nextInspection;
  final String? imageUrl;
  final double lat;
  final double lng;

  String get statusLabel => switch (status) {
        ProjectStatus.pending => 'Pending',
        ProjectStatus.inProgress => 'In Progress',
        ProjectStatus.completed => 'Completed',
        ProjectStatus.overdue => 'Overdue',
      };
}

class NotificationModel {
  const NotificationModel({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.type,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final NotificationType type;
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
