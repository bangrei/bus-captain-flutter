import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';


class PayslipEmpty extends StatelessWidget {
  const PayslipEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20), //
      child: Center(
        child: Text(
          "no data".tr(),
          textScaler: TextScaler.noScaling,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
