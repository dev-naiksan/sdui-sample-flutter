import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sdui_flutter_sample/form/form_notifier.dart';
import 'package:sdui_flutter_sample/models/result.dart';
import 'package:sdui_flutter_sample/widgets/mapper_widget.dart';

import '../models/notifications.dart';
import '../models/widget_model.dart';
import '../widgets/app_card.dart';

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FormNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: AppBar(
            title: const Text('SDUI Sample'),
          ),
          body: Builder(
            builder: (context) {
              if (notifier.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return NotificationListener<FieldNotification>(
                onNotification: (notification) {
                  return notifier.onNotification(notification);
                },
                child: ScrollablePositionedList.builder(
                  itemCount: notifier.groups.length,
                  itemScrollController: notifier.itemScrollController,
                  scrollOffsetController: notifier.scrollOffsetController,
                  itemPositionsListener: notifier.itemPositionsListener,
                  scrollOffsetListener: notifier.scrollOffsetListener,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemBuilder: (context, index) {
                    return FieldGroupCard(
                      list: notifier.groups[index],
                      values: notifier.values,
                    );
                  },
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
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.black87,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: HighlightView(
                jsonEncode(result.data),
                language: 'json',
                tabSize: 20,
                theme: draculaTheme,
                padding: const EdgeInsets.all(12),
                textStyle: const TextStyle(fontSize: 16.0),
              ),
            );
          },
        );
      case Failure():
        showFailure(context, result.error);
    }
  }

  void showSuccess(BuildContext context, String data) {
    _showFlushBar(context: context, message: data);
  }

  void showFailure(BuildContext context, String error) {
    _showFlushBar(context: context, message: error, color: Colors.deepOrange);
  }

  void _showFlushBar({
    required BuildContext context,
    required String message,
    Color color = Colors.green,
  }) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 1),
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      margin: const EdgeInsets.all(12),
    ).show(context);
  }
}

class FieldGroupCard extends StatelessWidget {
  final List<FieldModel> list;
  final Map<String, FieldValue<dynamic>> values;

  const FieldGroupCard({super.key, required this.list, required this.values});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: list.map((model) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: MapperWidget(
                  model: model,
                  value: values[model.key]!,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
