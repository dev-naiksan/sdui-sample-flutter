import 'package:flutter/material.dart';
import 'package:sdui_flutter_sample/models/widget_model.dart';

class TextWidget extends StatelessWidget {
  final TextModel model;

  const TextWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    double textSize;
    FontWeight fontWeight;
    switch (model.type) {
      case TextType.title:
        textSize = 32.0;
        fontWeight = FontWeight.w700;
      case TextType.subtitle:
        textSize = 18.0;
        fontWeight = FontWeight.w500;
      case TextType.body:
        textSize = 12.0;
        fontWeight = FontWeight.w400;
    }
    return Text(
      model.defaultValue.value,
      style: TextStyle(fontSize: textSize, fontWeight: fontWeight),
    );
  }
}
