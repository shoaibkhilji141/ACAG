import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';

class MapLaunchService {
  MapLaunchService._();

  /// Opens the device maps app (Google Maps / Apple Maps) at the project pin.
  static Future<void> openProjectLocation(ProjectModel project) async {
    final lat = project.lat;
    final lng = project.lng;
    final label = Uri.encodeComponent(
      '${project.title} — ${project.address}, ${project.city}',
    );

    // Prefer geo: (Android Maps / chooser). Fallback to Google Maps HTTPS.
    final candidates = <Uri>[
      Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)'),
      Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      ),
      Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=$label'),
    ];

    Object? lastError;
    for (final uri in candidates) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception(
      lastError?.toString() ?? 'Could not open Maps on this device.',
    );
  }
}
