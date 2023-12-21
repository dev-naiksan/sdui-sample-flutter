import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
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

  List<List<FieldModel>> get groups =>
      modelsMap.values.groupListsBy((e) => e.groupId).values.toList();

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
    }
    _values[notification.key] = notification.value;
    _checkButtonState();
    notifyListeners();
    return true;
  }

  Map<String, String> getRequestMap() {
    final Map<String, String> reqMap = {};
    _values.forEach((key, value) {
      final field = _modelsMap[key];
      if (field != null && !field.isDisplayField) {
        reqMap[field.key] = value.raw;
      }
    });
    return reqMap;
  }

  Future<Result<Map<String, String>>> submit() async {
    for (var element in _modelsMap.values) {
      element.setError(null);
    }
    _validate();
    final hasErrors = _modelsMap.values.any((element) => element.error != null);
    if (hasErrors) {
      return Failure(error: 'Fields have errors');
    }
    return Success(data: getRequestMap());
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
    if (!model.mandatory) {
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
      DateFieldModel() =>
        ValidationUtils.validateDate(model, result as DateFieldValue),
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
