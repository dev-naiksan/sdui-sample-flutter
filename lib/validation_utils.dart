import 'package:sdui_flutter_sample/models/error_model.dart';
import 'package:sdui_flutter_sample/models/widget_model.dart';

class ValidationUtils {
  static TextFieldError? validateTextField(
      TextFieldModel model, TextFieldValue value) {
    final max = model.max;
    final min = model.min;
    if (model.type == TextFieldType.email && !value.raw.contains('@')) {
      return TextFieldError("Enter valid email");
    } else if (model.type == TextFieldType.password && value.raw.length < 6) {
      return TextFieldError(
          "Enter valid password (at least 6 characters long)");
    }else if (max != null && max == min && value.value.length != max) {
      return TextFieldError("Must be $max character long");
    } else if (max != null && value.value.length > max) {
      return TextFieldError("Max $max characters allowed");
    } else if (min != null && value.value.length < min) {
      return TextFieldError("Min $min characters required");
    } else if (value.value.isEmpty) {
      return TextFieldError("Enter valid");
    }
    return null;
  }

  static SelectionError? validateSelection(
      SelectionModel model, SelectionValue result) {
    if (result.value.isEmpty) {
      return SelectionError("Select option");
    }
    return null;
  }

  static PasswordConfirmationError? validateConfirmationPassword(
      PasswordConfirmationModel model, PasswordConfirmationValue result) {
    if (result.value1.length < 6) {
      return PasswordConfirmationError(
          "Password length must be greater than 6", null);
    } else if (result.value1 != result.value2) {
      return PasswordConfirmationError(
          null, "Confirm password is not same as above");
    }
    return null;
  }
}
