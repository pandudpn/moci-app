import 'package:flutter/services.dart' show TextCapitalization;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show InputBorder, InputDecoration, TextField;

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';

const _fill = Color(0xFFF8F6FD);
const _border = Color(0xFFEEE9F7);
const _focusBorder = Color(0xFF1C7ED6);

/// Kolom nama anak: maksimal 20 karakter, tepi biru saat fokus.
class NameField extends StatefulWidget {
  const NameField({
    super.key,
    required this.controller,
    required this.hint,
    required this.label,
    this.onChanged,
  });

  /// Panjang maksimal nama.
  static const maxLength = 20;

  final TextEditingController controller;
  final String hint;
  final String label;
  final ValueChanged<String>? onChanged;

  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = MociText.button.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w600,
    );
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _focus.hasFocus ? _focusBorder : _border,
          width: 4,
        ),
      ),
      child: Semantics(
        label: widget.label,
        child: TextField(
          controller: widget.controller,
          focusNode: _focus,
          maxLength: NameField.maxLength,
          onChanged: widget.onChanged,
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          style: style,
          cursorColor: _focusBorder,
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            counterText: '',
            hintText: widget.hint,
            hintStyle: style.copyWith(color: MociColors.inkSoft),
          ),
        ),
      ),
    );
  }
}
