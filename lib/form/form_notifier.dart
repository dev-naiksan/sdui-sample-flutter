import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
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
      _validateField(model, notification.value);
      notifyListeners();
    }
    switch (notification) {
      case TextFieldWidgetNotification():
        _values[notification.key] = notification.value;
        notifyListeners();
        return true;
      case SelectionWidgetNotification():
        _values[notification.key] = notification.value;
        notifyListeners();
        return true;
      case PasswordConfirmationNotification():
        _values[notification.key] = notification.value;
        notifyListeners();
        return true;
    }
  }

  void _scrollToField(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if(renderBox == null){
      return;
    }
    final position = renderBox.localToGlobal(Offset.zero);
    scrollController.animateTo(
      position.dy,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void submit() {
    for (var element in _modelsMap.values) {
      element.setError(null);
    }
    _validate();
    final hasErrors = _modelsMap.values.any((element) => element.error != null);
    if (hasErrors) {
      print('Fields have errors');
      return;
    }

    print(
        'Submitting form with values as: ${_values.map((k, v) => MapEntry(k, v.raw))}');
  }

  void _validate() {
    for (var entry in _modelsMap.entries) {
      final fieldValue = _values[entry.key];
      if (fieldValue == null) {
        continue;
      }
      _validateField(entry.value, fieldValue);
    }
    final firstModelWithError = _modelsMap.values.firstWhereOrNull((element) => element.error != null);
    if(firstModelWithError != null){
      // _scrollToField(firstModelWithError);
    }
    notifyListeners();
  }

  void _validateField(FieldModel model, FieldValue result) {
    final error = switch (model) {
      TextFieldModel() =>
        ValidationUtils.validateTextField(model, result as TextFieldValue),
      SelectionModel() =>
        ValidationUtils.validateSelection(model, result as SelectionValue),
      PasswordConfirmationModel() =>
        ValidationUtils.validateConfirmationPassword(
            model, result as PasswordConfirmationValue),
      TextModel() => null,
    };
    if (error == null) {
      model.setError(null);
    } else {
      model.setError(error);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
