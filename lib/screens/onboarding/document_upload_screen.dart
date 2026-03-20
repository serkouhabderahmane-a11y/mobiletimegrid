import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  PlatformFile? _idDocument;
  PlatformFile? _additionalDoc;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingService>(
      builder: (context, onboarding, _) {
        final isComplete = onboarding.getTaskStatus('task-docs') == TaskStatus.completed;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        isComplete ? Icons.check_circle : Icons.upload_file,
                        size: 48,
                        color: isComplete ? Colors.green : Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isComplete ? 'Documents Submitted' : 'Document Upload',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please upload the required identification documents to complete your onboarding.',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FileUploadWidget(
                label: 'Government-Issued ID',
                hint: 'Upload a photo of your driver\'s license or passport',
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                selectedFile: _idDocument,
                isRequired: true,
                enabled: !isComplete,
                onFileSelected: (file) {
                  setState(() => _idDocument = file);
                },
                onFileRemoved: (value) {
                  setState(() => _idDocument = null);
                },
              ),
              const SizedBox(height: 16),
              FileUploadWidget(
                label: 'Social Security Card or Birth Certificate',
                hint: 'Upload a copy of your SSN card or birth certificate',
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                selectedFile: _additionalDoc,
                isRequired: true,
                enabled: !isComplete,
                onFileSelected: (file) {
                  setState(() => _additionalDoc = file);
                },
                onFileRemoved: (value) {
                  setState(() => _additionalDoc = null);
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Important Information',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem('Documents must be clear and legible'),
                      _buildInfoItem('Acceptable formats: JPG, PNG, PDF'),
                      _buildInfoItem('Maximum file size: 10MB per document'),
                      _buildInfoItem('Your documents will be securely stored and encrypted'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!isComplete)
                ElevatedButton(
                  onPressed: _isSubmitting || _idDocument == null || _additionalDoc == null
                      ? null
                      : () async {
                          setState(() => _isSubmitting = true);
                          
                          final onboarding = context.read<OnboardingService>();
                          await onboarding.updateTaskStatus(
                            'task-docs',
                            TaskStatus.completed,
                          );
                          
                          setState(() => _isSubmitting = false);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Documents submitted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Documents'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
