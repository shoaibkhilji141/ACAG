import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';

class ShareDownloadService {
  ShareDownloadService._();

  static Future<void> shareProjectDetails(ProjectModel project) async {
    final text = '''
ACAG Project Details
--------------------
Project ID: ${project.id}
Title: ${project.title}
Owner: ${project.ownerName}
Engineer: ${project.engineerName}
Address: ${project.address}, ${project.city}
Status: ${project.statusLabel}
Current Phase: ${project.phase}
Progress: ${(project.progress * 100).round()}%
Next Inspection: ${project.nextInspection}
'''.trim();

    await Share.share(text, subject: 'ACAG ${project.id}');
  }

  static Future<void> sharePlainText({
    required String title,
    required String body,
  }) async {
    await Share.share(body, subject: title);
  }

  static Future<void> downloadTextFile({
    required String fileName,
    required String content,
  }) async {
    final dir = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final file = File('${dir.path}/$safeName');
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: fileName,
      text: 'Download $fileName',
    );
  }
}
