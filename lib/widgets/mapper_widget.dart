import 'package:flutter/cupertino.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';
import 'package:sdui_flutter_sample/widgets/dropdown_widget.dart';
import 'package:sdui_flutter_sample/widgets/password_confirmaton_field_widget.dart';
import 'package:sdui_flutter_sample/widgets/pick_location_widget.dart';
import 'package:sdui_flutter_sample/widgets/remote_dropdown_widget.dart';
import 'package:sdui_flutter_sample/widgets/selection_widget.dart';
import 'package:sdui_flutter_sample/widgets/text_field_widget.dart';

import '../models/widget_model.dart';
import 'date_field.dart';
import 'text_widget.dart';

class MapperWidget extends StatelessWidget {
  final FieldModel model;
  final Map<String, FieldValue> values;

  const MapperWidget({
    super.key,
    required this.model,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final error = model.error;
    FieldModel m = model;
    switch (m) {
      case TextFieldModel():
        TextFieldValue value = values[model.key] as TextFieldValue;
        return TextFieldWidget(
          model: m,
          fieldValue: value,
          error: error as TextFieldError?,
        );
      case SelectionModel():
        SelectionValue value = values[model.key] as SelectionValue;
        if (m.type == SelectionType.dropdownMulti ||
            m.type == SelectionType.dropdownSingle) {
          return DropdownField(
            model: m,
            fieldValue: value,
            error: error as SelectionError?,
          );
        } else {
          return SelectionWidget(
            model: m,
            fieldValue: value,
            error: error as SelectionError?,
          );
        }
      case RemoteSelectionModel():
        SelectionValue value = values[model.key] as SelectionValue;
        return RemoteDropdownField(
          model: m,
          fieldValue: value,
          error: error as SelectionError?,
        );
      case TextModel():
        TextValue value = values[model.key] as TextValue;
        return TextWidget(model: m);

      case PasswordConfirmationModel():
        PasswordConfirmationValue value =
            values[model.key] as PasswordConfirmationValue;
        return PasswordConfirmationWidget(
          model: m,
          fieldValue: value,
          error: error as PasswordConfirmationError?,
        );
      case DateFieldModel():
        DateFieldValue value = values[model.key] as DateFieldValue;
        return DateInputField(
          model: m,
          fieldValue: value,
          error: error as DateFieldError?,
        );
      case PickLocationModel():
        PickLocationValue value = values[model.key] as PickLocationValue;
        return PickLocationWidget(
          model: m,
          fieldValue: value,
          error: error as PickLocationError?,
        );
    }
  }
}
