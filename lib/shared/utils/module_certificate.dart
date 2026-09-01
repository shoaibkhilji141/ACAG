import '../constants/construction_modules.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

class ModuleCertificate {
  ModuleCertificate._();

  static String titleForModule(int moduleNo) {
    if (moduleNo < 1 || moduleNo > constructionModules.length) {
      return 'Construction Module';
    }
    return constructionModules[moduleNo - 1].title;
  }

  static String formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String buildText({
    required ProjectModel project,
    required int moduleNo,
    required DateTime completedAt,
  }) {
    final moduleTitle = titleForModule(moduleNo);
    final completionDate = formatDate(completedAt);
    final ownerPhone = project.ownerPhone?.trim();
    final phoneLine = ownerPhone != null && ownerPhone.isNotEmpty
        ? 'Owner Contact: $ownerPhone\n'
        : '';

    return '''
GOVERNMENT OF PUNJAB — ${AppConstants.appName}
Module Completion Certificate
-----------------------------
Module: $moduleTitle (Module ${moduleNo.toString().padLeft(2, '0')})
Status: Completed Successfully

Project ID: ${project.id}
Project Title: ${project.title}
Plot / Address: ${project.address}, ${project.city}

Home Owner: ${project.ownerName}
${phoneLine}Certifying Engineer: ${project.engineerName}
Completion Date: $completionDate

This certificate confirms that the above module has been completed
in accordance with ACAG construction validation requirements.

Consultancy: ${AppConstants.urbanUnit}
'''.trim();
  }
}
