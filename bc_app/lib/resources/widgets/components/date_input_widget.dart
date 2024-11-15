import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';

class DateInput extends StatefulWidget {
  final String label;
  final double width;
  final Function onTap;
  final TextEditingController dateController;

  const DateInput({
    Key? key,
    required this.label,
    required this.width,
    required this.onTap,
    required this.dateController,
  }) : super(key: key);

  @override
  _DateInputState createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  //TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        child: TextField(
          controller: widget.dateController,
          style: const TextStyle(fontSize: 14.0),
          readOnly: true,
          decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: const TextStyle(fontSize: 16.0),
              filled: true,
              fillColor: ThemeColor.get(context).surfaceBackground,
              prefixIcon: const Icon(Icons.calendar_month)),
          onTap: () => {widget.onTap()},
        ));
  }
}
