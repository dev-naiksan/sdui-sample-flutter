import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';
import 'package:sdui_flutter_sample/models/widget_model.dart';

import '../models/notifications.dart';

Future<DateTime?> _selectDate(
  BuildContext context,
  DateTime initialDate,
) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );
}

class DateInputField extends StatelessWidget {
  final DateFieldModel model;
  final DateFieldValue fieldValue;
  final DateFieldError? error;

  const DateInputField({
    super.key,
    required this.model,
    required this.fieldValue,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final value = fieldValue.value;
    final textValue =
        value == null ? '' : DateFormat('dd/MM/yyyy').format(value);
    return TextFormField(
      controller: TextEditingController(text: textValue),
      keyboardType: TextInputType.none,
      readOnly: true,
      showCursor: false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderSide: BorderSide()),
        labelText: model.placeholder,
        hintText: model.placeholder,
        errorText: error?.value,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final result =
            await _selectDate(context, fieldValue.value ?? DateTime.now());
        if (context.mounted && result != null) {
          DateFieldWidgetNotification(
                  key: model.key, value: DateFieldValue(result))
              .dispatch(context);
        }
      },
    );
  }
}
