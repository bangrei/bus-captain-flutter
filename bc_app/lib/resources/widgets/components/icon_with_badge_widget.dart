import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';

class IconWithBadge extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final double size;

  IconWithBadge(
      {required this.icon, required this.badgeCount, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          color: ThemeColor.get(context).appBarPrimaryContent,
          icon,
          size: size,
        ),
        if (badgeCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 15,
                minHeight: 15,
              ),
              child: Center(
                child: Text(
                  '$badgeCount',
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
