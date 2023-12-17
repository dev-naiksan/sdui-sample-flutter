sealed class FieldError {}

class TextFieldError extends FieldError {
  final String? value;

  TextFieldError(this.value);
}

class DateFieldError extends FieldError {
  final String? value;

  DateFieldError(this.value);
}

class SelectionError extends FieldError {
  final String? value;

  SelectionError(this.value);
}

class PasswordConfirmationError extends FieldError {
  final String? value1;
  final String? value2;

  PasswordConfirmationError(this.value1, this.value2);
}
