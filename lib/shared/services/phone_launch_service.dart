import 'package:url_launcher/url_launcher.dart';

class PhoneLaunchService {
  PhoneLaunchService._();

  static Future<void> dial(String phoneNumber) async {
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) {
      throw Exception('Owner phone number is not available.');
    }

    final uri = Uri(scheme: 'tel', path: digits);
    final launched = await launchUrl(uri);
    if (!launched) {
      throw Exception('Could not open the phone dialer on this device.');
    }
  }
}
