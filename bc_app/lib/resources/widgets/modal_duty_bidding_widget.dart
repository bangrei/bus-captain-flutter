import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ModalDutyBidding extends StatelessWidget {
  const ModalDutyBidding({super.key});

  void confirmBid(context) {
    Navigator.pop(context);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('184AM07',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('4600 - WRDEP',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                            fontSize: 11, color: nyHexColor('393939'))),
                    const Text('05:55 AM - 03:09 PM',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: Container(
                      height: 24,
                      width: 114,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: nyHexColor('A08D47')),
                      child: const Center(
                        child: Text(
                          'Service 11',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      )),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}