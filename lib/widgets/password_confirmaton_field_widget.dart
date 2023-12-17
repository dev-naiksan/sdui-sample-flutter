import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';
import 'package:sdui_flutter_sample/validation_utils.dart';

import '../models/notifications.dart';
import '../models/widget_model.dart';

class PasswordConfirmationWidget extends StatefulWidget {
  final PasswordConfirmationModel model;
  final PasswordConfirmationValue fieldValue;
  final PasswordConfirmationError? error;

  const PasswordConfirmationWidget({
    super.key,
    required this.model,
    required this.fieldValue,
    required this.error,
  });

  @override
  State<PasswordConfirmationWidget> createState() =>
      _PasswordConfirmationWidgetState();
}

class _PasswordConfirmationWidgetState
    extends State<PasswordConfirmationWidget> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  Timer? _debounce;

  @override
  void didUpdateWidget(covariant PasswordConfirmationWidget oldWidget) {
    _controller1.text = widget.fieldValue.value1;
    _controller2.text = widget.fieldValue.value2;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _controller1.text = widget.fieldValue.value1;
    _controller2.text = widget.fieldValue.value2;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller1,
          decoration: InputDecoration(
            labelText: widget.model.placeholder,
            border: const OutlineInputBorder(borderSide: BorderSide()),
            errorText: widget.error?.value1,
            hintText: widget.model.placeholder,
          ),
          onChanged: (text) {
            _onChanged();
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller2,
          decoration: InputDecoration(
            labelText: widget.model.placeholder2,
            border: const OutlineInputBorder(borderSide: BorderSide()),
            errorText: widget.error?.value2,
            hintText: widget.model.placeholder2,
          ),
          onChanged: (text) {
            _onChanged();
          },
        ),
        const SizedBox(height: 4),
        _buildPasswordHint(PasswordValidator.msgAtLeastOneUpCase,
            PasswordValidator.hasAtLeastOneUpCase(_controller1.text)),
        _buildPasswordHint(PasswordValidator.msgAtLeastOneLoCase,
            PasswordValidator.hasAtLeastOneLoCase(_controller1.text)),
        _buildPasswordHint(PasswordValidator.msgAtLeastOneNumber,
            PasswordValidator.hasAtLeastOneNumber(_controller1.text)),
        _buildPasswordHint(PasswordValidator.msgAtLeastOneSymbol,
            PasswordValidator.hasAtLeastOneSymbol(_controller1.text)),
        _buildPasswordHint(PasswordValidator.msgValidLength,
            PasswordValidator.hasValidLength(_controller1.text)),
      ],
    );
  }

  Widget _buildPasswordHint(String msg, bool valid) {
    return Text(
      msg,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 10,
        color: valid ? Colors.green : Colors.red,
      ),
    );
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      PasswordConfirmationNotification(
        key: widget.model.key,
        value: PasswordConfirmationValue(_controller1.text, _controller2.text),
      ).dispatch(context);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }
}
