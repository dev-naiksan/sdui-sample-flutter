import 'package:sdui_flutter_sample/models/error_model.dart';
import 'package:sdui_flutter_sample/models/widget_model.dart';

class ValidationUtils {
  static TextFieldError? validateTextField(
      TextFieldModel model, TextFieldValue value) {
    final max = model.max;
    final min = model.min;
    if (model.type == TextFieldType.email) {
      return validateEmail(value);
    } else if (model.type == TextFieldType.password) {
      return validatePassword(value.value);
    } else if (max != null && max == min && value.value.length != max) {
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

  static TextFieldError? validateEmail(TextFieldValue value) {
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value.value)
        ? null
        : TextFieldError("Enter valid email");
  }

  static SelectionError? validateSelection(
      SelectionModel model, SelectionValue result) {
    if (result.value.isEmpty) {
      return SelectionError("Select option");
    }
    return null;
  }

  static SelectionError? validateRemoteSelection(
      RemoteSelectionModel model, SelectionValue result) {
    if (result.value.isEmpty) {
      return SelectionError("Select option");
    }
    return null;
  }

  static PasswordConfirmationError? validateConfirmationPassword(
      PasswordConfirmationModel model, PasswordConfirmationValue result) {
    final error = validatePassword(result.value1);
    if (error != null) {
      return PasswordConfirmationError(error.value, null);
    } else if (result.value1 != result.value2) {
      return PasswordConfirmationError(
          null, "Confirm password is not same as above");
    }
    return null;
  }

  static TextFieldError? validatePassword(String str) {
    if (!PasswordValidator.hasAtLeastOneUpCase(str)) {
      return TextFieldError(PasswordValidator.msgAtLeastOneUpCase);
    } else if (!PasswordValidator.hasAtLeastOneLoCase(str)) {
      return TextFieldError(PasswordValidator.msgAtLeastOneLoCase);
    } else if (!PasswordValidator.hasAtLeastOneNumber(str)) {
      return TextFieldError(PasswordValidator.msgAtLeastOneNumber);
    } else if (!PasswordValidator.hasAtLeastOneSymbol(str)) {
      return TextFieldError(PasswordValidator.msgAtLeastOneSymbol);
    } else if (!PasswordValidator.hasValidLength(str)) {
      return TextFieldError(PasswordValidator.msgValidLength);
    }
    return null;
  }

  static DateFieldError? validateDate(
      DateFieldModel model, DateFieldValue result) {
    if (result.value == null) {
      return DateFieldError('Select valid date');
    }
    return null;
  }
}

class PasswordValidator {
  static const minLength = 8;
  static const validCharacters = '@#&.=+-';
  static final _rgxAtLeastOneUpCase = RegExp(r'[A-Z]+');
  static final _rgxAtLeastOneLoCase = RegExp(r'[a-z]+');
  static final _rgxAtLeastOneNumber = RegExp(r'[0-9]+');
  static final _rgxAtLeastOneSymbol = RegExp('[$validCharacters]');

  static const msgAtLeastOneUpCase =
      "Password must contain at least one uppercase character (A-Z)";

  static const msgAtLeastOneLoCase =
      "Password must contain at least one lowercase character (a-z)";

  static const msgAtLeastOneNumber =
      "Password must contain at least one number (0-9)";

  static const msgAtLeastOneSymbol =
      "Password at least one symbol (${PasswordValidator.validCharacters})";

  static const msgValidLength =
      "Password needs to be ${PasswordValidator.minLength} characters long";

  static bool hasAtLeastOneUpCase(String str) =>
      _rgxAtLeastOneUpCase.hasMatch(str);

  static bool hasAtLeastOneLoCase(String str) =>
      _rgxAtLeastOneLoCase.hasMatch(str);

  static bool hasAtLeastOneNumber(String str) =>
      _rgxAtLeastOneNumber.hasMatch(str);

  static bool hasAtLeastOneSymbol(String str) =>
      _rgxAtLeastOneSymbol.hasMatch(str);

  static bool hasValidLength(String str) => str.length >= minLength;
}
