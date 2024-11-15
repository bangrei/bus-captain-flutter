import 'package:flutter/material.dart';

class ModalJobAssignment extends StatelessWidget {
  const ModalJobAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Date:', textScaler: TextScaler.noScaling, style: TextStyle(fontWeight: FontWeight.bold)),
        Text('22 April 2024', textScaler: TextScaler.noScaling,),
        SizedBox(height: 20),
        Text('Time:', textScaler: TextScaler.noScaling, style: TextStyle(fontWeight: FontWeight.bold)),
        Text('03.42 PM - 01:26 AM', textScaler: TextScaler.noScaling,),
        SizedBox(height: 20),
        Text('Bus number:', textScaler: TextScaler.noScaling, style: TextStyle(fontWeight: FontWeight.bold)),
        Text('SG6143U', textScaler: TextScaler.noScaling,),
        SizedBox(height: 20),
        Text('Destination:', textScaler: TextScaler.noScaling, style: TextStyle(fontWeight: FontWeight.bold)),
        Text('4600 - WRDEP', textScaler: TextScaler.noScaling,),
      ],
    );
  }
}
