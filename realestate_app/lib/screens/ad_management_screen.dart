import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/advertisement.dart';
import '../services/ad_storage_service.dart';

class AdManagementScreen extends StatefulWidget {
  const AdManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdManagementScreen> createState() => _AdManagementScreenState();
}

class _AdManagementScreenState extends State<AdManagementScreen> {
  final AdStorageService _storageService = AdStorageService();
  List<Advertisement> _advertisements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  Future<void> _loadAdvertisements() async {
    setState(() => _isLoading = true);
    final ads = await _storageService.loadAdvertisements();
    setState(() {
      _advertisements = ads;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Advertisement? ad}) {
    showDialog(
      context: context,
      builder: (context) => AdEditDialog(
        advertisement: ad,
        onSave: (Advertisement newAd) async {
          bool success;
          if (ad == null) {
            success = await _storageService.addAdvertisement(newAd);
          } else {
            success = await _storageService.updateAdvertisement(newAd);
          }

          if (success) {
            _loadAdvertisements();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ad == null
                      ? 'Advertisement created successfully'
                      : 'Advertisement updated successfully'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteAdvertisement(Advertisement ad) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Advertisement'),
        content: Text('Are you sure you want to delete "${ad.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _storageService.deleteAdvertisement(ad.id);
    if (mounted) {
      if (success) {
        _loadAdvertisements();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Advertisement deleted successfully'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleStatus(Advertisement ad) async {
    final updatedAd = ad.copyWith(isActive: !ad.isActive);
    final success = await _storageService.updateAdvertisement(updatedAd);
    
    if (success) {
      _loadAdvertisements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Manage Advertisements',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF111827)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: const Color(0xFF10B981),
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Advertisement',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF10B981),
                ),
              )
            : _advertisements.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _advertisements.length,
                    itemBuilder: (context, index) {
                      return _buildAdItem(_advertisements[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Advertisements Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first advertisement',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdItem(Advertisement ad) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ad.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (ad.externalLink != null && ad.externalLink!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.link,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ad.externalLink!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF10B981),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ad.isActive
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ad.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ad.isActive
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddEditDialog(ad: ad),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleStatus(ad),
                    icon: Icon(
                      ad.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(ad.isActive ? 'Hide' : 'Show'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _deleteAdvertisement(ad),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Icon(Icons.delete, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdEditDialog extends StatefulWidget {
  final Advertisement? advertisement;
  final Function(Advertisement) onSave;

  const AdEditDialog({
    Key? key,
    this.advertisement,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AdEditDialog> createState() => _AdEditDialogState();
}

class _AdEditDialogState extends State<AdEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _buttonTextController;
  late TextEditingController _buttonLinkController;
  late TextEditingController _externalLinkController;

  String? _mediaBase64;
  String? _mediaType;
  String? _selectedFileName;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.advertisement?.title ?? '',
    );
    _subtitleController = TextEditingController(
      text: widget.advertisement?.subtitle ?? '',
    );
    _buttonTextController = TextEditingController(
      text: widget.advertisement?.buttonText ?? '',
    );
    _buttonLinkController = TextEditingController(
      text: widget.advertisement?.buttonLink ?? '',
    );
    _externalLinkController = TextEditingController(
      text: widget.advertisement?.externalLink ?? '',
    );
    _mediaBase64 = widget.advertisement?.mediaUrl;
    _mediaType = widget.advertisement?.mediaType;
    _isActive = widget.advertisement?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonTextController.dispose();
    _buttonLinkController.dispose();
    _externalLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        
        if (bytes != null) {
          // Check file size (max 5MB)
          if (bytes.length > 5 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File size must be less than 5MB'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          final mimeType = _getMimeType(file.extension ?? '');
          final base64String = 'data:$mimeType;base64,${base64Encode(bytes)}';
          
          setState(() {
            _selectedFileName = file.name;
            _mediaBase64 = base64String;
            
            // Determine if it's image or video
            if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(file.extension?.toLowerCase())) {
              _mediaType = 'image';
            } else {
              _mediaType = 'video';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }

  void _removeFile() {
    setState(() {
      _mediaBase64 = null;
      _mediaType = null;
      _selectedFileName = null;
    });
  }

  void _saveAdvertisement() {
    if (!_formKey.currentState!.validate()) return;

    final ad = Advertisement(
      id: widget.advertisement?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      mediaUrl: _mediaBase64,
      mediaType: _mediaType,
      buttonText: _buttonTextController.text.trim().isEmpty
          ? null
          : _buttonTextController.text.trim(),
      buttonLink: _buttonLinkController.text.trim().isEmpty
          ? null
          : _buttonLinkController.text.trim(),
      externalLink: _externalLinkController.text.trim().isEmpty
          ? null
          : _externalLinkController.text.trim(),
      isActive: _isActive,
      order: widget.advertisement?.order ?? 0,
    );

    widget.onSave(ad);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.advertisement == null
                              ? 'Add Advertisement'
                              : 'Edit Advertisement',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title *',
                      hintText: 'Enter advertisement title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  TextFormField(
                    controller: _subtitleController,
                    decoration: InputDecoration(
                      labelText: 'Subtitle *',
                      hintText: 'Enter advertisement subtitle',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Subtitle is required';
                      }
                      return null;
                    },
                    maxLines: 2,
                    maxLength: 150,
                  ),
                  const SizedBox(height: 16),

                  // File Picker Section - REPLACES Image URL input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.image,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Media (Optional)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_selectedFileName != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _mediaType == 'video' ? Icons.videocam : Icons.image,
                                  color: const Color(0xFF10B981),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedFileName!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF374151),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _mediaType == 'video' ? 'Video file' : 'Image file',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: _removeFile,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          OutlinedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Image'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supported: JPG, PNG, GIF, WEBP (Max 5MB)\nLeave empty for gradient background',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button Text
                  TextFormField(
                    controller: _buttonTextController,
                    decoration: InputDecoration(
                      labelText: 'Button Text (Optional)',
                      hintText: 'e.g., Learn More, Visit Now',
                      prefixIcon: const Icon(Icons.touch_app, color: Color(0xFF10B981)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLength: 20,
                  ),
                  const SizedBox(height: 16),

                  // Button Link
                  TextFormField(
                    controller: _buttonLinkController,
                    decoration: InputDecoration(
                      labelText: 'Button Link URL (Optional)',
                      hintText: 'https://example.com',
                      prefixIcon: const Icon(
                        Icons.link,
                        color: Color(0xFF10B981),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: 'Opens when button is clicked',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.startsWith('http://') && !value.startsWith('https://')) {
                          return 'URL must start with http:// or https://';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // External Link (NEW - for clicking the whole ad)
                  TextFormField(
                    controller: _externalLinkController,
                    decoration: InputDecoration(
                      labelText: 'Advertisement Link (Optional)',
                      hintText: 'https://advertiser-website.com',
                      prefixIcon: const Icon(
                        Icons.open_in_new,
                        color: Color(0xFF3B82F6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: 'Opens when ad is clicked (redirects to advertiser)',
                      helperMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.startsWith('http://') && !value.startsWith('https://')) {
                          return 'URL must start with http:// or https://';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Active Switch
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Active',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('Show this advertisement to users'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      activeColor: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveAdvertisement,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}