import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';

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
  State<PasswordConfirmationWidget> createState() => _PasswordConfirmationWidgetState();
}

class _PasswordConfirmationWidgetState extends State<PasswordConfirmationWidget> {
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
      children: [
        TextField(
          controller: _controller1,
          decoration: InputDecoration(
            errorText: widget.error?.value1,
            hintText: widget.model.placeholder,
          ),
          onChanged: (text) {
            _onChanged();
          },
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _controller2,
          decoration: InputDecoration(
            errorText: widget.error?.value2,
            hintText: widget.model.placeholder2,
          ),
          onChanged: (text) {
            _onChanged();
          },
        ),
      ],
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
