import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../services/owner_service.dart';
import '../utils/image_base64.dart';
import '../widgets/acag_app_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_placeholder.dart';
import '../../theme/app_theme.dart';

String documentTypeLabel(String type) {
  return switch (type) {
    'cnic' => 'CNIC',
    'property' => 'Property',
    'plan' => 'Construction Plan',
    'noc' => 'NOC',
    'loan' => 'Loan / Grant',
    'engineer_report' => 'Engineer Report',
    'completion_cert' => 'Completion Certificate',
    _ => type,
  };
}

IconData documentTypeIcon(String type) {
  return switch (type) {
    'cnic' => Icons.badge_outlined,
    'property' => Icons.home_work_outlined,
    'plan' => Icons.architecture_outlined,
    'noc' => Icons.verified_outlined,
    'loan' => Icons.account_balance_outlined,
    'engineer_report' => Icons.assignment_outlined,
    'completion_cert' => Icons.workspace_premium_outlined,
    _ => Icons.folder_outlined,
  };
}

Color documentStatusColor(String status) {
  return switch (status) {
    'approved' => AppColors.success,
    'rejected' => AppColors.error,
    'submitted' => AppColors.primary,
    _ => AppColors.warning,
  };
}

String documentStatusLabel(String status) {
  return switch (status) {
    'approved' => 'Approved',
    'rejected' => 'Rejected',
    'submitted' => 'Submitted',
    'pending' => 'Pending',
    _ => status,
  };
}

/// Shared documents list used from Profile (owner + engineer).
class ProfileDocumentsSection extends StatelessWidget {
  const ProfileDocumentsSection({
    super.key,
    required this.documents,
    required this.loading,
    this.emptyMessage = 'No documents uploaded yet.',
  });

  final List<Map<String, dynamic>> documents;
  final bool loading;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (documents.isEmpty) {
      return EmptyPlaceholder(
        icon: Icons.folder_outlined,
        message: emptyMessage,
      );
    }

    return FluentCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < documents.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            _DocTile(doc: documents[i]),
          ],
        ],
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.doc});

  final Map<String, dynamic> doc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = (doc['doc_type'] as String?) ?? 'other';
    final status = (doc['status'] as String?) ?? 'pending';
    final title = doc['title'] as String? ?? documentTypeLabel(type);
    final color = documentStatusColor(status);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(documentTypeIcon(type), color: color, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        documentTypeLabel(type),
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              documentStatusLabel(status),
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
      onTap: () {
        final id = doc['id'] as String?;
        if (id == null) return;
        Navigator.of(context).pushNamed(
          AppRoutes.documentViewer,
          arguments: {
            'documentId': id,
            'title': title,
            'docType': type,
          },
        );
      },
    );
  }
}

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _loading = true;
  bool _started = false;
  String? _error;
  String _title = 'Document';
  String _docType = 'other';
  final List<({String label, String? data})> _pages = [];
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _title = (args['title'] as String?) ?? _title;
      _docType = (args['docType'] as String?) ?? _docType;
      final id = args['documentId'] as String?;
      if (id != null) {
        _load(id);
        return;
      }
    }
    setState(() {
      _loading = false;
      _error = 'Document not found';
    });
  }

  Future<void> _load(String id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final doc = await OwnerService.getDocument(id);
    if (!mounted) return;
    if (doc == null) {
      setState(() {
        _loading = false;
        _error = 'Could not load document';
      });
      return;
    }

    final pages = <({String label, String? data})>[];
    final files = doc['files_json'];
    if (files is List && files.isNotEmpty) {
      for (final item in files) {
        if (item is Map) {
          pages.add((
            label: (item['label'] as String?) ?? 'Page',
            data: item['data'] as String?,
          ));
        }
      }
    }
    final single = doc['file_base64'] as String?;
    if (pages.isEmpty && single != null && single.isNotEmpty) {
      pages.add((label: 'Document', data: single));
    }
    if (pages.isEmpty) {
      // Fallback demo pages so CNIC / docs always open a picture screen.
      if (_docType == 'cnic') {
        pages.addAll(const [
          (label: 'Front', data: null),
          (label: 'Back', data: null),
        ]);
      } else {
        pages.add((label: documentTypeLabel(_docType), data: null));
      }
    }

    setState(() {
      _title = (doc['title'] as String?) ?? _title;
      _docType = (doc['doc_type'] as String?) ?? _docType;
      _pages
        ..clear()
        ..addAll(pages);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: _title,
        showBranding: false,
        showBack: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              documentTypeLabel(_docType),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${_index + 1} / ${_pages.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        itemCount: _pages.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (context, i) {
                          final page = _pages[i];
                          final provider =
                              imageProviderFromBase64(page.data);
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: FluentCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    page.label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: provider != null
                                          ? InteractiveViewer(
                                              child: Image(
                                                image: provider,
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          : _PlaceholderDoc(
                                              title: _title,
                                              label: page.label,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _PlaceholderDoc extends StatelessWidget {
  const _PlaceholderDoc({required this.title, required this.label});

  final String title;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: AppColors.surfaceLow,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
