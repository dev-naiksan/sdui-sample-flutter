import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdui_flutter_sample/models/notifications.dart';

import '../models/error_model.dart';
import '../models/widget_model.dart';

class DropdownField extends StatelessWidget {
  final SelectionModel model;
  final SelectionValue fieldValue;
  final SelectionError? error;

  const DropdownField({
    super.key,
    required this.model,
    required this.fieldValue,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = error?.value;
    final textValue = fieldValue.value.map((e) => e.value).join(',');
    return TextFormField(
      controller: TextEditingController(text: textValue),
      keyboardType: TextInputType.none,
      readOnly: true,
      showCursor: false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderSide: BorderSide()),
        labelText: model.placeholder,
        hintText: model.placeholder,
        errorText: errorMessage,
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      onTap: () async {
        final selected = await _showBottomSheet(context);
        if (selected != null) {
          if (context.mounted) {
            SelectionWidgetNotification(key: model.key, value: selected)
                .dispatch(context);
          }
        }
      },
    );
  }

  Future<SelectionValue?> _showBottomSheet(BuildContext context) {
    return showModalBottomSheet<SelectionValue?>(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider<DropdownNotifier>(
          create: (_) => DropdownNotifier(fieldValue.value),
          child: DropdownSheetContent(
            model: model,
            fieldValue: fieldValue,
          ),
        );
      },
    );
  }
}

class DropdownSheetContent extends StatelessWidget {
  final SelectionModel model;
  final SelectionValue fieldValue;

  const DropdownSheetContent({
    super.key,
    required this.model,
    required this.fieldValue,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DropdownNotifier>(builder: (_, notifier, __) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(model.placeholder, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
              const SizedBox(height: 12),
              const Divider(),
              Expanded(
                child: ListView(
                  children: model.options
                      .map(
                        (e) => CheckboxListTile(
                          value: notifier.selected.any((e2) => e2.key == e.key),
                          title: Text(e.value),
                          onChanged: (value) {
                            if (model.type.isSingleType) {
                              Navigator.pop(context, SelectionValue({e}));
                            } else {
                              notifier.toggle(e);
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              if (model.type.isMultiSelectType)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, SelectionValue(notifier.selected));
                  },
                  child: const Text('Done'),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class DropdownNotifier extends ChangeNotifier {
  final Set<OptionModel> selected;

  DropdownNotifier(this.selected);

  void toggle(OptionModel e) {
    if (selected.contains(e)) {
      selected.remove(e);
    } else {
      selected.add(e);
    }
    notifyListeners();
  }
}
