import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sdui_flutter_sample/models/error_model.dart';
import 'package:sdui_flutter_sample/models/result.dart';
import '../models/notifications.dart';
import '../models/widget_model.dart';
import '../validation_utils.dart';

class FormNotifier extends ChangeNotifier {
  final Map<String, FieldModel> _modelsMap = {};

  Map<String, FieldModel> get modelsMap => _modelsMap;

  final Map<String, FieldValue> _values = <String, FieldValue>{};

  Map<String, FieldValue> get values => _values;

  bool _loading = false;

  bool get loading => _loading;

  bool _allFieldsValid = false;

  bool get allFieldsValid => _allFieldsValid;

  final ScrollController scrollController = ScrollController();

  FormNotifier() {
    getForm();
  }

  void getForm() async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _loading = false;
    final jsonStr =
        await rootBundle.loadString('assets/json/sample_response.json');
    final json = jsonDecode(jsonStr) as List;
    for (var element in json) {
      final widgetModel = FieldModel.fromJson(element);
      _modelsMap[widgetModel.key] = widgetModel;
      _values[widgetModel.key] = widgetModel.defaultValue;
    }
    notifyListeners();
  }

  bool onNotification(FieldNotification notification) {
    final model = _modelsMap[notification.key];
    if (model != null && model.error != null) {
      final error = _validateField(model, notification.value);
      model.setError(error);
      notifyListeners();
    }
    if (notification case TextFieldWidgetNotification()) {
      _values[notification.key] = notification.value;
    } else if (notification case SelectionWidgetNotification()) {
      _values[notification.key] = notification.value;
    } else if (notification case PasswordConfirmationNotification()) {
      _values[notification.key] = notification.value;
    } else {
      return false;
    }
    _checkButtonState();
    notifyListeners();
    return true;
  }

  Future<Result<String>> submit() async {
    for (var element in _modelsMap.values) {
      element.setError(null);
    }
    _validate();
    final hasErrors = _modelsMap.values.any((element) => element.error != null);
    if (hasErrors) {
      return Failure(error: 'Fields have errors');
    }
    return Success(data: 'Submitted the form');
  }

  void _validate() {
    for (final entry in _modelsMap.entries) {
      final fieldValue = _values[entry.key];
      if (fieldValue == null) {
        continue;
      }
      final error = _validateField(entry.value, fieldValue);
      entry.value.setError(error);
    }
    notifyListeners();
  }

  FieldError? _validateField(FieldModel model, FieldValue result) {
    if(!model.mandatory){
      return null;
    }
    return switch (model) {
      TextFieldModel() =>
        ValidationUtils.validateTextField(model, result as TextFieldValue),
      SelectionModel() =>
        ValidationUtils.validateSelection(model, result as SelectionValue),
      PasswordConfirmationModel() =>
        ValidationUtils.validateConfirmationPassword(
            model, result as PasswordConfirmationValue),
      TextModel() => null,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkButtonState() {
    final hasErrors = _modelsMap.values.any((model) {
      final value = _values[model.key];
      if (value == null) {
        return true;
      }
      final error = _validateField(model, value);
      return error != null;
    });
    _allFieldsValid = !hasErrors;
  }
}
