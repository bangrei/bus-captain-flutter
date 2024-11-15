import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 10,
      decoration: BoxDecoration(color: ThemeColor.get(context).sectionDivider)
    );
  }
}
