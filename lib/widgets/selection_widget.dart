import 'package:flutter/material.dart';
import 'package:sdui_flutter_sample/models/error_model.dart';
import '../models/notifications.dart';
import '../models/widget_model.dart';
import 'package:collection/collection.dart';

class SelectionWidget extends StatelessWidget {
  final SelectionModel model;
  final SelectionValue fieldValue;
  final SelectionError? error;

  const SelectionWidget({
    super.key,
    required this.model,
    required this.fieldValue,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final errorValue = error?.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(model.placeholder),
        if(errorValue != null)
          Text(errorValue, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.red)),
        ...model.options.map(
          (e) {
            final selected =
                fieldValue.value.firstWhereOrNull((o) => o.key == e.key) !=
                    null;
            return Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (_) {
                    SelectionValue result = fieldValue;
                    if (model.type == SelectionType.single) {
                      result.value.clear();
                    }
                    if (selected) {
                      result.value.remove(e);
                    } else {
                      result.value.add(e);
                    }
                    SelectionWidgetNotification(key: model.key, value: result)
                        .dispatch(context);
                  },
                ),
                Text(e.value),
              ],
            );
          },
        ),
      ],
    );
  }
}
