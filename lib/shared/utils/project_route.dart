import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/mock_data.dart';

ProjectModel projectFromRoute(BuildContext context) {
  final args = ModalRoute.of(context)?.settings.arguments;
  return args is ProjectModel ? args : MockData.primaryProject;
}
