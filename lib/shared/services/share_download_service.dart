import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../utils/module_certificate.dart';

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

  static Future<void> shareModuleCertificateWithOwner({
    required ProjectModel project,
    required int moduleNo,
    DateTime? completedAt,
  }) async {
    final completed = completedAt ?? DateTime.now();
    final moduleTitle = ModuleCertificate.titleForModule(moduleNo);
    final certificate = ModuleCertificate.buildText(
      project: project,
      moduleNo: moduleNo,
      completedAt: completed,
    );
    final ownerPhone = project.ownerPhone?.trim();
    final intro = ownerPhone != null && ownerPhone.isNotEmpty
        ? 'Dear ${project.ownerName} ($ownerPhone),\n\n'
        : 'Dear ${project.ownerName},\n\n';

    await Share.share(
      '$intro'
      'Your ACAG project module has been completed successfully.\n\n'
      '$certificate',
      subject:
          'ACAG Module Certificate — ${project.id} — $moduleTitle',
    );
  }

  static Future<void> shareModuleCertificateFile({
    required ProjectModel project,
    required int moduleNo,
    DateTime? completedAt,
  }) async {
    final completed = completedAt ?? DateTime.now();
    final moduleTitle = ModuleCertificate.titleForModule(moduleNo);
    final content = ModuleCertificate.buildText(
      project: project,
      moduleNo: moduleNo,
      completedAt: completed,
    );

    await downloadTextFile(
      fileName:
          '${project.id}_module_${moduleNo.toString().padLeft(2, '0')}_certificate.txt',
      content: content,
      shareText:
          'ACAG module completion certificate for ${project.ownerName} — $moduleTitle',
    );
  }

  static Future<void> downloadTextFile({
    required String fileName,
    required String content,
    String? shareText,
  }) async {
    final dir = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final file = File('${dir.path}/$safeName');
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: fileName,
      text: shareText ?? 'Download $fileName',
    );
  }
}
