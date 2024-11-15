import 'package:flutter/material.dart';

class MasterLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const MasterLayout({Key? key, required this.child, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0), // Use custom padding if provided, else use default padding
      child: child,
    );
  }
}
