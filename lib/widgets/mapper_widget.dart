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
  final FieldValue value;

  const MapperWidget({
    super.key,
    required this.model,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final error = model.error;
    FieldModel m = model;
    switch (m) {
      case TextFieldModel():
        return TextFieldWidget(
          model: m,
          fieldValue: value as TextFieldValue,
          error: error as TextFieldError?,
        );
      case SelectionModel():
        if (m.type == SelectionType.dropdownMulti ||
            m.type == SelectionType.dropdownSingle) {
          return DropdownField(
            model: m,
            fieldValue: value as SelectionValue,
            error: error as SelectionError?,
          );
        } else {
          return SelectionWidget(
            model: m,
            fieldValue: value as SelectionValue,
            error: error as SelectionError?,
          );
        }
      case RemoteSelectionModel():
        return RemoteDropdownField(
          model: m,
          fieldValue: value as SelectionValue,
          error: error as SelectionError?,
        );
      case TextModel():
        return TextWidget(model: m);

      case PasswordConfirmationModel():
        return PasswordConfirmationWidget(
          model: m,
          fieldValue: value as PasswordConfirmationValue,
          error: error as PasswordConfirmationError?,
        );
      case DateFieldModel():
        return DateInputField(
          model: m,
          fieldValue: value as DateFieldValue,
          error: error as DateFieldError?,
        );
      case PickLocationModel():
        return PickLocationWidget(
          model: m,
          fieldValue: value as PickLocationValue,
          error: error as PickLocationError?,
        );
    }
  }
}
