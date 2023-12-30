import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:sdui_flutter_sample/extensions.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';
import 'package:sdui_flutter_sample/models/picked_location.dart';

enum WidgetType {
  text('text'),
  textField('text_field'),
  localSelection('local_selection'),
  remoteSelection('remote_selection'),
  confirmPassword('password_confirmation'),
  dateField('date_field'),
  pickLocation('pick_location'),
  unknown("unknown");

  final String value;

  const WidgetType(this.value);

  factory WidgetType.fromRaw(String raw) {
    return WidgetType.values.firstWhereOrNull((e) => e.value == raw) ??
        WidgetType.unknown;
  }
}

sealed class FieldModel {
  String get key;

  FieldValue get defaultValue;

  FieldError? get error;

  bool get mandatory;

  int get groupId;

  bool get isDisplayField;

  void setError(covariant FieldError? e);

  static FieldModel fromJson(Map<String, dynamic> json) {
    final type = WidgetType.fromRaw(json['type']);
    switch (type) {
      case WidgetType.text:
        return TextModel.fromJson(json);
      case WidgetType.textField:
        return TextFieldModel.fromJson(json);
      case WidgetType.localSelection:
        return SelectionModel.fromJson(json);
      case WidgetType.remoteSelection:
        return RemoteSelectionModel.fromJson(json);
      case WidgetType.confirmPassword:
        return PasswordConfirmationModel.fromJson(json);
      case WidgetType.dateField:
        return DateFieldModel.fromJson(json);
      case WidgetType.pickLocation:
        return PickLocationModel.fromJson(json);
      case WidgetType.unknown:
        return TextModel(
          key: 'unknown',
          defaultValue: TextValue('Unknown widget type: $type'),
          type: TextType.body,
          groupId: json['group_id'],
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

class DateFieldValue extends FieldValue<DateTime?> {
  @override
  final DateTime? value;

  DateFieldValue(this.value);

  @override
  String get raw =>
      value == null ? '' : DateFormat('yyyy-MM-dd').format(value!);
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

  @override
  final String key;
  final String placeholder;
  @override
  final TextFieldValue defaultValue;
  final TextFieldType type;

  final int? min;
  final int? max;

  @override
  final bool mandatory;

  @override
  final int groupId;

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
        mandatory: json['mandatory'] == true,
        groupId: json['group_id']);
  }

  TextFieldModel({
    required this.key,
    required this.placeholder,
    required this.type,
    required this.defaultValue,
    required this.mandatory,
    required this.groupId,
    this.min,
    this.max,
  });

  @override
  TextFieldError? get error => _error;

  @override
  bool get isDisplayField => false;
}

enum SelectionType {
  single('single'),
  multi('multi'),
  dropdownSingle('dropdown_single'),
  dropdownMulti('dropdown_multi');

  final String value;

  const SelectionType(this.value);

  bool get isSingleType =>
      this == SelectionType.single || this == SelectionType.dropdownSingle;

  bool get isMultiSelectType => !isSingleType;
}

enum RemoteDropdownSelectionType {
  single('single'),
  multi('multi');

  final String value;

  const RemoteDropdownSelectionType(this.value);
}

class OptionModel {
  final String key;
  final String value;

  OptionModel({required this.key, required this.value});

  @override
  bool operator ==(other) =>
      other is OptionModel && key == other.key && value == other.value;

  @override
  int get hashCode => Object.hash(key, value);
}

class SelectionValue extends FieldValue<Set<OptionModel>> {
  @override
  final Set<OptionModel> value;

  SelectionValue(this.value);

  @override
  String get raw => value.map((e) => e.key).join(",");
}

class SelectionModel extends FieldModel {

  @override
  final String key;
  @override
  final SelectionValue defaultValue;
  @override
  final bool mandatory;

  final String placeholder;
  final List<OptionModel> options;
  final SelectionType type;

  SelectionError? _error;

  @override
  final int groupId;

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
      mandatory: json['mandatory'] == true,
      groupId: json['group_id'],
    );
  }

  SelectionModel({
    required this.key,
    required this.placeholder,
    required this.options,
    required this.type,
    required this.defaultValue,
    required this.mandatory,
    required this.groupId,
  });

  @override
  bool get isDisplayField => false;
}

class RemoteSelectionModel extends FieldModel {

  @override
  final String key;
  @override
  final SelectionValue defaultValue;
  @override
  final bool mandatory;

  final String placeholder;
  final RemoteDropdownSelectionType type;
  final ApiConfig apiConfig;

  SelectionError? _error;

  @override
  final int groupId;

  @override
  void setError(SelectionError? e) {
    _error = e;
  }

  @override
  FieldError? get error => _error;

  factory RemoteSelectionModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> oRaw = json['initial_value'] ?? [];
    Set<OptionModel> selected = {};

    for (var element in oRaw) {
      final option = OptionModel(key: element['key'], value: element['value']);
      if (element['selected'] == true) {
        selected.add(option);
      }
    }

    return RemoteSelectionModel(
      key: json['key'],
      placeholder: json['placeholder'],
      type: RemoteDropdownSelectionType.values.firstWhere(
          (element) => element.value == json['subtype'],
          orElse: () => RemoteDropdownSelectionType.multi),
      defaultValue: SelectionValue(selected),
      mandatory: json['mandatory'] == true,
      groupId: json['group_id'],
      apiConfig: ApiConfig.fromJson(json['api_config']),
    );
  }

  RemoteSelectionModel({
    required this.key,
    required this.placeholder,
    required this.type,
    required this.defaultValue,
    required this.mandatory,
    required this.groupId,
    required this.apiConfig,
  });

  @override
  bool get isDisplayField => false;
}

enum ApiMethod { get, post }

class ApiConfig {
  final String endpoint;
  final ApiMethod type;
  final Map<String, dynamic> queryParams;
  final Map<String, dynamic> headers;

  ApiConfig({
    required this.endpoint,
    required this.type,
    required this.queryParams,
    required this.headers,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      endpoint: json['endpoint'],
      type: json['type'] == 'GET' ? ApiMethod.get : ApiMethod.post,
      queryParams: json['query_params'],
      headers: json['headers'],
    );
  }
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

  @override
  final String key;

  @override
  final TextValue defaultValue;

  final TextType type;

  @override
  FieldError? get error => null;

  @override
  bool get mandatory => false;

  @override
  final int groupId;

  @override
  void setError(FieldError? e) {}

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      key: json['key'],
      defaultValue: TextValue(json.getOrEmpty('initial_value')),
      type: TextType.values.firstWhere(
          (element) => element.name == json['subtype'],
          orElse: () => TextType.body),
      groupId: json['group_id'],
    );
  }

  TextModel({
    required this.key,
    required this.defaultValue,
    required this.type,
    required this.groupId,
  });

  @override
  bool get isDisplayField => true;
}

class PasswordConfirmationModel extends FieldModel {
  static const widgetType = 'password_confirmation';

  @override
  final String key;
  final String placeholder;
  final String placeholder2;
  @override
  final PasswordConfirmationValue defaultValue;

  @override
  final bool mandatory;

  @override
  final int groupId;

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
      mandatory: json['mandatory'] == true,
      groupId: json['group_id'],
    );
  }

  PasswordConfirmationModel({
    required this.key,
    required this.placeholder,
    required this.placeholder2,
    required this.defaultValue,
    required this.mandatory,
    required this.groupId,
  });

  @override
  bool get isDisplayField => false;
}

class DateFieldModel extends FieldModel {
  static const widgetType = 'date_field';

  @override
  final String key;
  final String placeholder;
  @override
  final DateFieldValue defaultValue;

  final DateTime? min;
  final DateTime? max;

  @override
  final bool mandatory;

  @override
  final int groupId;

  DateFieldError? _error;

  @override
  void setError(DateFieldError? e) {
    _error = e;
  }

  static DateFieldValue _getValueFromRaw(String? raw) {
    if (raw == null) {
      return DateFieldValue(null);
    }
    try {
      return DateFieldValue(DateFormat('yyyy-MM-dd').parse(raw));
    } catch (_) {
      return DateFieldValue(null);
    }
  }

  factory DateFieldModel.fromJson(Map<String, dynamic> json) {
    return DateFieldModel(
        key: json['key'],
        placeholder: json['placeholder'],
        defaultValue: _getValueFromRaw(json['initial_value']),
        min: json['min'],
        max: json['max'],
        mandatory: json['mandatory'] == true,
        groupId: json['group_id']);
  }

  DateFieldModel({
    required this.key,
    required this.placeholder,
    required this.defaultValue,
    required this.mandatory,
    required this.groupId,
    this.min,
    this.max,
  });

  @override
  DateFieldError? get error => _error;

  @override
  bool get isDisplayField => false;
}

class PickLocationValue extends FieldValue<PickedLocation?> {
  @override
  PickedLocation? value;

  PickLocationValue(this.value);

  @override
  String get raw =>
      value == null ? "" : "(${value!.latitude},${value!.longitude})";
}

class PickLocationModel extends FieldModel {
  static const widgetType = 'pick_location';

  @override
  final String key;
  final String placeholder;
  @override
  final PickLocationValue defaultValue;

  @override
  final bool mandatory;

  @override
  final int groupId;

  PickLocationError? _error;

  @override
  void setError(PickLocationError? e) {
    _error = e;
  }

  static PickLocationValue _getValueFromRaw(String? raw) {
    if (raw == null) {
      return PickLocationValue(null);
    }
    try {
      //raw has this form -> 12.34,56.78
      final list = raw.split(",");
      final latitude = double.parse(list.first);
      final longitude = double.parse(list.last);
      return PickLocationValue(
        PickedLocation(latitude, longitude),
      );
    } catch (_) {
      return PickLocationValue(null);
    }
  }

  factory PickLocationModel.fromJson(Map<String, dynamic> json) {
    return PickLocationModel(
      key: json['key'],
      placeholder: json['placeholder'],
      defaultValue: _getValueFromRaw(json['initial_value']),
      mandatory: json['mandatory'] == true,
      groupId: json['group_id'],
    );
  }

  PickLocationModel({
    required this.key,
    required this.placeholder,
    required this.defaultValue,
    required this.mandatory,
    required this.groupId,
  });

  @override
  PickLocationError? get error => _error;

  @override
  bool get isDisplayField => false;
}
