import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:sdui_flutter_sample/models/widget_model.dart';

import 'api_result.dart';

class ApiService {
  static bool get randomBool => Random().nextDouble() < 0.5;

  static Future<ApiResult<List<OptionModel>>> getRemoteOptions(
      ApiConfig config) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (randomBool) {
      return ApiFailure('Some error occurred');
    } else {
      final options = [
        OptionModel(key: 'option1', value: "Option 1"),
        OptionModel(key: 'option2', value: "Option 2"),
        OptionModel(key: 'option3', value: "Option 3"),
        OptionModel(key: 'option4', value: "Option 4"),
      ];
      return ApiSuccess(options);
    }
  }

  static Future<List<FieldModel>> getForm() async {
    final jsonStr =
        await rootBundle.loadString('assets/json/sample_response.json');
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => FieldModel.fromJson(e)).toList();
  }
}
