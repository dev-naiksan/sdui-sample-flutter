import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sdui_flutter_sample/api/api_service.dart';
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

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

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
    final models = await ApiService.getForm();
    for (final model in models) {
      _modelsMap[model.key] = model;
      _values[model.key] = model.defaultValue;
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
    final field = getFieldWithError();
    if (field != null) {
      scrollToField(field);
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

  void scrollToField(FieldModel model) {
    final index = groups
        .indexWhere((list) => list.any((element) => element.key == model.key));
    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
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
      RemoteSelectionModel() => ValidationUtils.validateRemoteSelection(
          model, result as SelectionValue),
      PasswordConfirmationModel() =>
        ValidationUtils.validateConfirmationPassword(
            model, result as PasswordConfirmationValue),
      DateFieldModel() =>
        ValidationUtils.validateDate(model, result as DateFieldValue),
      PickLocationModel() =>
        ValidationUtils.validateLocation(model, result as PickLocationValue),
      TextModel() => null,
    };
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

  FieldModel? getFieldWithError() {
    return _modelsMap.values
        .firstWhereOrNull((element) => element.error != null);
  }
}
