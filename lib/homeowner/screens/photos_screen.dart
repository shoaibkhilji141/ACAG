import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../shared/widgets/image_preview_dialog.dart';
import '../../theme/app_theme.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  ProjectModel? _project;
  List<Map<String, dynamic>> _photos = [];
  bool _loading = true;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_badge);
    _badge();
    _load();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_badge);
    super.dispose();
  }

  Future<void> _badge() async {
    final n = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = n);
  }

  Future<void> _load({bool force = false}) async {
    final project = await ProjectService.primaryOwnerProject();
    if (project == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _project = null;
          _photos = [];
        });
      }
      return;
    }

    if (!force) {
      final cached = ProjectService.getCachedBundle(project.id)?.images;
      if (cached != null) {
        setState(() {
          _project = project;
          _photos = cached;
          _loading = false;
        });
      }
    }

    final rows = await ProjectService.listProjectImages(
      project.id,
      forceRefresh: force,
    );
    if (!mounted) return;
    setState(() {
      _project = project;
      _photos = rows;
      _loading = false;
    });
  }

  String _uploaderName(Map<String, dynamic> photo) {
    final uploader = photo['uploader'];
    if (uploader is Map && uploader['full_name'] != null) {
      return uploader['full_name'].toString();
    }
    return 'Engineer';
  }

  String _dateLabel(Map<String, dynamic> photo) {
    final raw = photo['created_at'] as String?;
    if (raw == null) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw.length >= 10 ? raw.substring(0, 10) : raw;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Site Photos',
        showBranding: false,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(force: true),
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _photos.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      EmptyPlaceholder(
                        icon: Icons.photo_library_outlined,
                        message: _project == null
                            ? 'No project linked.'
                            : 'No site photos uploaded yet.',
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      final bytes =
                          decodeBase64Image(photo['image_base64'] as String?);
                      final caption =
                          (photo['caption'] as String?)?.trim() ?? '';
                      final date = _dateLabel(photo);
                      final uploader = _uploaderName(photo);

                      return FluentCard(
                        padding: EdgeInsets.zero,
                        onTap: () => showBase64ImagePreview(
                          context,
                          imageBase64: photo['image_base64'] as String?,
                          caption: caption.isEmpty ? null : caption,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: bytes != null
                                    ? Image.memory(bytes, fit: BoxFit.cover)
                                    : Container(
                                        color: AppColors.primaryContainer
                                            .withValues(alpha: 0.25),
                                        child: const Center(
                                          child: Icon(
                                            Icons.photo_camera_outlined,
                                            size: 40,
                                            color: AppColors.primaryContainer,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    caption.isEmpty ? 'Site photo' : caption,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    date,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                  Text(
                                    uploader,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
