import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdui_flutter_sample/api/api_service.dart';
import 'package:sdui_flutter_sample/models/notifications.dart';

import '../api/api_result.dart';
import '../models/error_model.dart';
import '../models/widget_model.dart';

class RemoteDropdownField extends StatelessWidget {
  final RemoteSelectionModel model;
  final SelectionValue fieldValue;
  final SelectionError? error;

  const RemoteDropdownField({
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
        return ChangeNotifierProvider<RemoteDropdownNotifier>(
          create: (_) => RemoteDropdownNotifier(model, fieldValue.value),
          child: const RemoteDropdownSheetContent(),
        );
      },
    );
  }
}

class RemoteDropdownSheetContent extends StatelessWidget {
  const RemoteDropdownSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RemoteDropdownNotifier>(
      builder: (_, notifier, __) {
        final error = notifier.error;
        final loading = notifier.loading;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  notifier.model.placeholder,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Divider(),
                Expanded(
                  child: Builder(builder: (context) {
                    if (loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (error != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(error),
                            TextButton(
                              onPressed: notifier.fetch,
                              child: const Text('Retry'),
                            )
                          ],
                        ),
                      );
                    }
                    return ListView(
                      children: notifier.options
                          .map(
                            (e) => CheckboxListTile(
                              value: notifier.selected
                                  .any((e2) => e2.key == e.key),
                              title: Text(e.value),
                              onChanged: (value) {
                                if (notifier.model.type ==
                                    RemoteDropdownSelectionType.single) {
                                  Navigator.pop(context, SelectionValue({e}));
                                } else {
                                  notifier.toggle(e);
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  }),
                ),
                if (notifier.options.isNotEmpty)
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
      },
    );
  }
}

class RemoteDropdownNotifier extends ChangeNotifier {
  final RemoteSelectionModel model;
  final Set<OptionModel> selected;

  List<OptionModel> options = [];

  bool loading = false;
  String? error;

  RemoteDropdownNotifier(this.model, this.selected) {
    fetch();
  }

  void fetch() async {
    loading = true;
    error = null;
    notifyListeners();
    final result = await ApiService.getRemoteOptions(model.apiConfig);
    switch (result) {
      case ApiSuccess<List<OptionModel>>():
        options.addAll(result.data);
      case ApiFailure():
        error = result.error;
    }
    loading = false;
    notifyListeners();
  }

  void toggle(OptionModel e) {
    if (selected.contains(e)) {
      selected.remove(e);
    } else {
      selected.add(e);
    }
    notifyListeners();
  }
}
