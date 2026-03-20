import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadWidget extends StatefulWidget {
  final String label;
  final String? hint;
  final List<String> allowedExtensions;
  final Function(PlatformFile)? onFileSelected;
  final Function(String)? onFileRemoved;
  final PlatformFile? selectedFile;
  final bool isRequired;
  final bool enabled;
  final bool multiple;

  const FileUploadWidget({
    super.key,
    this.label = 'Upload File',
    this.hint,
    this.allowedExtensions = const [],
    this.onFileSelected,
    this.onFileRemoved,
    this.selectedFile,
    this.isRequired = false,
    this.enabled = true,
    this.multiple = false,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  bool _isUploading = false;

  Future<void> _pickFile() async {
    if (!widget.enabled || _isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: widget.allowedExtensions.isEmpty
            ? FileType.any
            : FileType.custom,
        allowedExtensions: widget.allowedExtensions.isEmpty
            ? null
            : widget.allowedExtensions,
        allowMultiple: widget.multiple,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        widget.onFileSelected?.call(result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.enabled ? Colors.black87 : Colors.grey,
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.selectedFile != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileIcon(widget.selectedFile!.extension),
                  color: Colors.green.shade700,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedFile!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.selectedFile!.size > 0)
                        Text(
                          _formatFileSize(widget.selectedFile!.size),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.enabled) ...[
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => widget.onFileRemoved?.call(''),
                    tooltip: 'Remove file',
                  ),
                ],
              ],
            ),
          )
        else
          InkWell(
            onTap: widget.enabled ? _pickFile : null,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.enabled ? Colors.grey.shade300 : Colors.grey.shade200,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
                color: widget.enabled ? Colors.grey.shade50 : Colors.grey.shade100,
              ),
              child: Column(
                children: [
                  if (_isUploading)
                    const CircularProgressIndicator()
                  else
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: widget.enabled ? Colors.grey.shade400 : Colors.grey.shade300,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _isUploading ? 'Uploading...' : widget.hint ?? 'Click to select a file',
                    style: TextStyle(
                      color: widget.enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                  ),
                  if (widget.allowedExtensions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Allowed: ${widget.allowedExtensions.map((e) => '.$e').join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
