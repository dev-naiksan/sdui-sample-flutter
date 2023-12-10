import 'package:flutter/material.dart';
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
    return InkWell(
      onTap: () async {
        final selected = await _showBottomSheet(context);
        if (selected != null) {
          if (context.mounted) {
            SelectionWidgetNotification(key: model.key, value: selected)
                .dispatch(context);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.placeholder,
                  style: const TextStyle(fontSize: 16),
                ),
                if (fieldValue.value.isNotEmpty)
                  Text(fieldValue.value.map((e) => e.value).join(',')),
                if (errorMessage != null)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  )
              ],
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<SelectionValue?> _showBottomSheet(BuildContext context) {
    return showModalBottomSheet<SelectionValue?>(
      context: context,
      builder: (context) {
        return DropdownSheetContent(model: model, fieldValue: fieldValue);
      },
    );
  }
}

class DropdownSheetContent extends StatefulWidget {
  final SelectionModel model;
  final SelectionValue fieldValue;

  const DropdownSheetContent(
      {super.key, required this.model, required this.fieldValue});

  @override
  State<DropdownSheetContent> createState() => _DropdownSheetContentState();
}

class _DropdownSheetContentState extends State<DropdownSheetContent> {
  final Set<OptionModel> _selected = {};

  @override
  void initState() {
    _selected.addAll(widget.fieldValue.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.model.options
              .map((e) => InkWell(
                    onTap: () {
                      if (widget.model.type == SelectionType.dropdownSingle) {
                        Navigator.pop(context, SelectionValue({e}));
                      } else {
                        if (_selected.contains(e)) {
                          _selected.remove(e);
                        } else {
                          _selected.add(e);
                        }
                        setState(() {});
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (_selected.contains(e)) const Icon(Icons.check),
                          Text(e.value),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          if (widget.model.type == SelectionType.dropdownMulti)
            TextButton(
                onPressed: () {
                  Navigator.pop(context, SelectionValue(_selected));
                },
                child: const Text('Done')),
        ],
      ),
    );
  }
}
