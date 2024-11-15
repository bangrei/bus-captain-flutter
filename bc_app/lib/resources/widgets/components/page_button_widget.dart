import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';

class PageButton extends StatelessWidget {
  final String label;
  final String page;
  final String pageSelected;
  final Function(String) onPressed;

  const PageButton({
    super.key,
    required this.label,
    required this.page,
    required this.pageSelected,
    required this.onPressed,
  });

   @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(page),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            pageSelected == page ? const Color(0xFF007AFF) : Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      child: Text(
        label,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: pageSelected == page
              ? Colors.white
              : ThemeColor.get(context).primaryContent,
        ),
      ),
    );
  }
}
