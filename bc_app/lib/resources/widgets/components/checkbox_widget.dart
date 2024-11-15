import 'package:flutter/material.dart';

class GeneralCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;
  final bool transparentBorder;

  const GeneralCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.color,
    this.transparentBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {
          onChanged(!value);
        },
        child: Container(
          width: 24.0,
          height: 24.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundColor: value ? color : Colors.transparent,
            radius: 10.0,
            child: value
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 16.0,
            )
                : null,
          ),
        ),
      ),
    );
  }
}
