import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';

import '../models/notifications.dart';
import '../models/widget_model.dart';

class TextFieldWidget extends StatefulWidget {
  final TextFieldModel model;
  final TextFieldValue fieldValue;
  final TextFieldError? error;

  const TextFieldWidget({
    super.key,
    required this.model,
    required this.fieldValue,
    required this.error,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void didUpdateWidget(covariant TextFieldWidget oldWidget) {
    _controller.text = widget.fieldValue.value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _controller.text = widget.fieldValue.value;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final TextInputType? keyboardType;
    final TextInputFormatter? inputFormatter;
    switch (widget.model.type) {
      case TextFieldType.integer:
        keyboardType = const TextInputType.numberWithOptions(
            signed: false, decimal: false);
        inputFormatter = FilteringTextInputFormatter.allow(RegExp('[0-9]'));
      case TextFieldType.decimal:
        keyboardType =
            const TextInputType.numberWithOptions(signed: false, decimal: true);
        inputFormatter = FilteringTextInputFormatter.allow(RegExp('[0-9.]'));
      case TextFieldType.email:
        keyboardType = TextInputType.emailAddress;
        inputFormatter = null;
      case TextFieldType.password:
        keyboardType = TextInputType.visiblePassword;
        inputFormatter =
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9!.@#]'));
      default:
        keyboardType = null;
        inputFormatter = null;
    }
    return TextField(
      controller: _controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          errorText: widget.error?.value,
          hintText: widget.model.placeholder,
          counter: null),
      inputFormatters: [
        LengthLimitingTextInputFormatter(widget.model.max),
        FilteringTextInputFormatter.singleLineFormatter,
        if (inputFormatter != null) inputFormatter
      ],
      onChanged: (text) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(seconds: 1), () {
          TextFieldWidgetNotification(
            key: widget.model.key,
            value: TextFieldValue(_controller.text),
          ).dispatch(context);
        });
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
