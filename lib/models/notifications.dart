import 'package:flutter/widgets.dart';
import 'package:sdui_flutter_sample/models/widget_model.dart';

sealed class FieldNotification extends Notification {
  String get key;

  FieldValue get value;
}

class TextFieldWidgetNotification extends FieldNotification {
  @override
  final String key;
  @override
  final TextFieldValue value;

  TextFieldWidgetNotification({
    required this.key,
    required this.value,
  });

  @override
  String toString() {
    return 'TextFieldWidgetNotification(key=$key, value=$value)';
  }
}

class DateFieldWidgetNotification extends FieldNotification {
  @override
  final String key;
  @override
  final DateFieldValue value;

  DateFieldWidgetNotification({
    required this.key,
    required this.value,
  });

  @override
  String toString() {
    return 'DateFieldWidgetNotification(key=$key, value=$value)';
  }
}

class PasswordConfirmationNotification extends FieldNotification {
  @override
  final String key;
  @override
  final PasswordConfirmationValue value;

  PasswordConfirmationNotification({
    required this.key,
    required this.value,
  });

  @override
  String toString() {
    return 'PasswordConfirmationNotification(key=$key, value=$value)';
  }
}

class SelectionWidgetNotification extends FieldNotification {
  @override
  final String key;
  @override
  final SelectionValue value;

  SelectionWidgetNotification({
    required this.key,
    required this.value,
  });

  @override
  String toString() {
    return 'TextFieldWidgetNotification(key=$key, value=$value)';
  }
}
