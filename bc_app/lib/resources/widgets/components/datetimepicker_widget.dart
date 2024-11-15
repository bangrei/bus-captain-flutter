import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DateTimePicker extends StatefulWidget {
  final String label;
  final bool readOnly;
  final bool editable;
  final bool? required;
  final String? placeholder;
  final String? errorMessage;
  final TextEditingController? dateTimeController;
  final Function onTap;
  final Function(String?)? onChanged;

  const DateTimePicker({
    super.key,
    required this.label,
    this.readOnly = false,
    this.editable = false,
    this.required = false,
    this.placeholder,
    this.errorMessage,
    this.onChanged,
    this.dateTimeController,
    required this.onTap,
  });

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontFamily: 'Poppins-bold'),
            ),
            if (widget.required == true)
              const Text(
                "*required",
                textScaler: TextScaler.noScaling,
                style:
                    TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        const SizedBox(height: 8.0),
        Stack(
          alignment: Alignment.centerRight, // Aligns children to the right
          children: [
            Container(
              decoration: BoxDecoration(
                color: widget.readOnly ? nyHexColor("F4F5F6") : ThemeColor.get(context).background,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                readOnly: true,
                controller: widget.dateTimeController,
                style: TextStyle(
                  fontSize: 14.0,
                  color: ThemeColor.get(context).primaryContent,
                  // You can add other text styling properties here
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.placeholder,
                  hintStyle: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF666666),
                  ),
                ),
                onTap: () => {widget.onTap()},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // Adjust as needed
              child: const Icon(Icons.calendar_month),
            ),
          ],
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.errorMessage!,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
