import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdui_flutter_sample/form/form_notifier.dart';
import 'package:sdui_flutter_sample/models/result.dart';
import 'package:sdui_flutter_sample/widgets/mapper_widget.dart';

import '../models/notifications.dart';

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FormNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              if (notifier.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return NotificationListener<FieldNotification>(
                onNotification: (notification) {
                  return notifier.onNotification(notification);
                },
                child: ListView(
                  controller: notifier.scrollController,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    MediaQuery.of(context).viewPadding.top + 24,
                    24,
                    100,
                  ),
                  children: notifier.modelsMap.values.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: MapperWidget(
                        model: e,
                        values: notifier.values,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          floatingActionButton: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                notifier.allFieldsValid ? Colors.amber : Colors.grey,
              ),
            ),
            onPressed: () async {
              _submitForm(context);
            },
            child: const Text('Submit'),
          ),
        );
      },
    );
  }

  void _submitForm(BuildContext context) async {
    final result = await context.read<FormNotifier>().submit();
    if (!context.mounted) return;

    switch (result) {
      case Success():
        showSuccess(context, result.data);
      case Failure():
        showFailure(context, result.error);
    }
  }

  void showSuccess(BuildContext context, String data) {
    Flushbar(
      message: data,
      duration: const Duration(seconds: 1),
    ).show(context);
  }

  void showFailure(BuildContext context, String error) {
    Flushbar(
      message: error,
      backgroundColor: Colors.deepOrange,
      duration: const Duration(seconds: 1),
    ).show(context);
  }
}
