import 'package:flutter/cupertino.dart';
import 'package:sdui_flutter_sample/extensions.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';

sealed class FieldModel {
  String get key;

  FieldValue get defaultValue;

  FieldError? get error;

  void setError(covariant FieldError? e);

  static FieldModel fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case TextFieldModel.widgetType:
        return TextFieldModel.fromJson(json);
      case SelectionModel.widgetType:
        return SelectionModel.fromJson(json);
      case TextModel.widgetType:
        return TextModel.fromJson(json);
      case PasswordConfirmationModel.widgetType:
        return PasswordConfirmationModel.fromJson(json);
      default:
        return TextModel(
          key: 'unknown',
          defaultValue: TextValue('Unknown widget type: $type'),
          type: TextType.body,
        );
    }
  }
}

sealed class FieldValue<T> {
  T get value;

  String get raw;
}

class TextFieldValue extends FieldValue<String> {
  @override
  final String value;

  TextFieldValue(this.value);

  @override
  String get raw => value;
}

class PasswordConfirmationValue extends FieldValue<String> {
  final String value1;
  final String value2;

  PasswordConfirmationValue(this.value1, this.value2);

  @override
  String get raw => value1;

  @override
  String get value => value1;
}

enum TextFieldType { text, email, integer, decimal, password }

class TextFieldModel extends FieldModel {
  static const widgetType = 'text_field';

  @override
  final String key;
  final String placeholder;
  @override
  final TextFieldValue defaultValue;
  final TextFieldType type;

  final int? min;
  final int? max;

  TextFieldError? _error;

  @override
  void setError(TextFieldError? e) {
    _error = e;
  }

  factory TextFieldModel.fromJson(Map<String, dynamic> json) {
    return TextFieldModel(
      key: json['key'],
      placeholder: json['placeholder'],
      type: TextFieldType.values.firstWhere(
          (element) => element.name == json['subtype'],
          orElse: () => TextFieldType.text),
      defaultValue: TextFieldValue(json.getOrEmpty('initial_value')),
      min: json['min'],
      max: json['max'],
    );
  }

  TextFieldModel({
    required this.key,
    required this.placeholder,
    required this.type,
    required this.defaultValue,
    this.min,
    this.max,
  });

  @override
  TextFieldError? get error => _error;
}

enum SelectionType {
  single('single'),
  multi('multi'),
  dropdownSingle('dropdown_single'),
  dropdownMulti('dropdown_multi');

  final String value;

  const SelectionType(this.value);
}

class OptionModel {
  final String key;
  final String value;

  OptionModel({required this.key, required this.value});
}

class SelectionValue extends FieldValue<Set<OptionModel>> {
  @override
  final Set<OptionModel> value;

  SelectionValue(this.value);

  @override
  String get raw => value.map((e) => e.key).join(",");
}

class SelectionModel extends FieldModel {
  static const widgetType = 'selection';

  @override
  final String key;
  @override
  final SelectionValue defaultValue;

  final String placeholder;
  final List<OptionModel> options;
  final SelectionType type;

  SelectionError? _error;

  @override
  void setError(SelectionError? e) {
    _error = e;
  }

  @override
  FieldError? get error => _error;

  factory SelectionModel.fromJson(Map<String, dynamic> json) {
    List<OptionModel> o = [];
    List<dynamic> oRaw = json['options'];
    Set<OptionModel> selected = {};

    for (var element in oRaw) {
      final option = OptionModel(key: element['key'], value: element['value']);
      if (element['selected'] == true) {
        selected.add(option);
      }
      o.add(option);
    }

    return SelectionModel(
      key: json['key'],
      placeholder: json['placeholder'],
      type: SelectionType.values.firstWhere(
          (element) => element.value == json['subtype'],
          orElse: () => SelectionType.multi),
      options: o,
      defaultValue: SelectionValue(selected),
    );
  }

  SelectionModel({
    required this.key,
    required this.placeholder,
    required this.options,
    required this.type,
    required this.defaultValue,
  });
}

class TextValue extends FieldValue<String> {
  @override
  String value;

  TextValue(this.value);

  @override
  String get raw => value;
}

enum TextType { title, subtitle, body }

class TextModel extends FieldModel {
  static const widgetType = 'text';

  @override
  final String key;

  @override
  final TextValue defaultValue;

  final TextType type;

  @override
  FieldError? get error => null;

  @override
  void setError(FieldError? e) {}

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      key: json['key'],
      defaultValue: TextValue(json.getOrEmpty('initial_value')),
      type: TextType.values.firstWhere(
          (element) => element.name == json['subtype'],
          orElse: () => TextType.body),
    );
  }

  TextModel({
    required this.key,
    required this.defaultValue,
    required this.type,
  });
}

class PasswordConfirmationModel extends FieldModel {
  static const widgetType = 'password_confirmation';

  @override
  final String key;
  final String placeholder;
  final String placeholder2;
  @override
  final PasswordConfirmationValue defaultValue;

  PasswordConfirmationError? _error;

  @override
  void setError(PasswordConfirmationError? e) {
    _error = e;
  }

  @override
  FieldError? get error => _error;

  factory PasswordConfirmationModel.fromJson(Map<String, dynamic> json) {
    return PasswordConfirmationModel(
      key: json['key'],
      placeholder: json['placeholder'],
      placeholder2: json['placeholder2'],
      defaultValue: PasswordConfirmationValue(
        json.getOrEmpty('initial_value'),
        json.getOrEmpty('initial_value'),
      ),
    );
  }

  PasswordConfirmationModel({
    required this.key,
    required this.placeholder,
    required this.placeholder2,
    required this.defaultValue,
  });
}
