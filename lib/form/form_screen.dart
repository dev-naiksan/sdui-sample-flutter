import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdui_flutter_sample/form/form_notifier.dart';
import 'package:sdui_flutter_sample/widgets/mapper_widget.dart';

import '../models/notifications.dart';

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FormNotifier>(builder: (context, notifier, child) {
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
              MediaQuery.of(context).viewPadding.top,
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
      }),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          context.read<FormNotifier>().submit();
        },
        child: const Text('Submit'),
      ),
    );
  }
}
