import 'package:flutter/material.dart';

class SignatureField extends StatefulWidget {
  final String label;
  final String? hint;
  final Function(String) onChanged;
  final bool isRequired;
  final bool enabled;
  final String? Function(String?)? validator;

  const SignatureField({
    super.key,
    this.label = 'Electronic Signature',
    this.hint = 'Type your full legal name',
    required this.onChanged,
    this.isRequired = true,
    this.enabled = true,
    this.validator,
  });

  @override
  State<SignatureField> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<SignatureField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
    if (_controller.text.isNotEmpty && _hasError) {
      setState(() {
        _hasError = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _hasError ? Colors.red : Colors.grey.shade300,
              width: _hasError ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: widget.enabled ? Colors.white : Colors.grey.shade100,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: 'serif',
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: _controller.text.isNotEmpty
                  ? Icon(
                      Icons.verified_outlined,
                      color: Colors.green.shade600,
                      size: 20,
                    )
                  : null,
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              if (widget.validator != null) {
                final error = widget.validator!(value);
                setState(() {
                  _hasError = error != null;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'By typing your name above, you acknowledge that this constitutes your legal electronic signature.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class AttestationCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const AttestationCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: enabled
                    ? (newValue) => onChanged(newValue ?? false)
                    : null,
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: enabled ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
