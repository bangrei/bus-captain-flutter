import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';

class InputDropdown extends StatefulWidget {
  final String label;
  final List<String>? items;
  final String? value;
  final bool readOnly;
  final bool editable;
  final bool? required;
  final String? placeholder;
  final String? errorMessage;
  final Function(String?)? onChanged;

  const InputDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.readOnly = false,
    this.editable = false,
    this.required = false,
    this.placeholder,
    this.errorMessage,
    this.onChanged,
  });

  @override
  _InputDropdownState createState() => _InputDropdownState();
}

class _InputDropdownState extends State<InputDropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(InputDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        _selectedValue = widget.value;
      });
    }
  }

  getSelectedValue() {
    if (widget.items!.contains(_selectedValue)) return _selectedValue;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                maxLines: 2,
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
        ),
        const SizedBox(height: 8.0),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: widget.readOnly
                    ? ThemeColor.get(context).inputBoxReadOnly
                    : ThemeColor.get(context).otpBoxNotEmpty,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                value: getSelectedValue(),
                isExpanded: true,
                itemHeight: 60,
                hint: Text(
                  widget.placeholder ?? '',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: ThemeColor.get(context).hintText,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF1570EF),
                ),
                iconSize: 24,
                elevation: 16,
                underline: const SizedBox(),
                onChanged: widget.readOnly
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedValue = newValue;
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(newValue);
                        }
                      },
                items: widget.items!.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String value = entry.value;
                  return DropdownMenuItem<String>(
                    value: value,
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              value,
                              textScaler: TextScaler.noScaling,
                              maxLines: 2,
                              style: TextStyle(
                                color: ThemeColor.get(context).primaryContent,
                              ),
                            ),
                          ),
                          // if (value != _selectedValue && idx < widget.items!.length - 1)
                          //   Divider(
                          //     color: Colors.grey,
                          //     thickness: 1,
                          //   )
                          // else 
                          //   const SizedBox(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
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
