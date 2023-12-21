import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(width: 1, color: Colors.black12),
      ),
      elevation: 0,
      child: child,
    );
  }
}
