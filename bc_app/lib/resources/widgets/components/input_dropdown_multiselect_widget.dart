import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class InputDropdownMultiselect extends StatefulWidget {
  final String label;
  final List<String>? items;
  final List<String>? values;
  final bool readOnly;
  final bool editable;
  final bool? required;
  final String? placeholder;
  final String? errorMessage;
  final Function(List<String>?)? onChanged;

  const InputDropdownMultiselect({
    super.key,
    required this.label,
    required this.items,
    this.values,
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

class _InputDropdownState extends State<InputDropdownMultiselect> {
  List<String>? _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.values ?? [];
  }

  @override
  void didUpdateWidget(InputDropdownMultiselect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      setState(() {
        _selectedValues = widget.values ?? [];
      });
    }
  }

  getSelectedValues() {
    return widget.items!
        .where((item) => _selectedValues!.contains(item))
        .toList();
  }

  void _clearSelection() {
    widget.onChanged!([]);
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
        const SizedBox(height: 0.0),
        Container(
          decoration: BoxDecoration(
            color: widget.readOnly ? ThemeColor.get(context).inputBoxReadOnly : ThemeColor.get(context).inputBoxNormal,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.5),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              // value: _selectedValues!.isNotEmpty ? _selectedValues!.join('-') : null, // Display selected values 
              isExpanded: true,
              hint: Text(
                widget.placeholder ?? '',
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF666666)
                ),
              ),
              icon: widget.values!.isNotEmpty
                  ? TextButton(
                    onPressed: _clearSelection, 
                    child: const Icon (
                      Icons.close_rounded,
                      size: 16.0,
                    )
                  )
                  : const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF1570EF),
                    ),
              // iconSize: 24,
              // elevation: 16,
              // style: const TextStyle(color: Colors.black),
              onChanged: widget.readOnly
                ? null
                : (String? newValue) {
                    setState(() {
                      if (_selectedValues!.contains(newValue)) {
                        _selectedValues!.remove(newValue);
                      } else {
                        _selectedValues!.add(newValue!);
                      }
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(_selectedValues);
                    }
                  },
              items: widget.items!
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedValues!.contains(value),
                        onChanged: widget.readOnly
                            ? null
                            : (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedValues!.add(value);
                                  } else {
                                    _selectedValues!.remove(value);
                                  }
                                });
                                if (widget.onChanged != null) {
                                  widget.onChanged!(_selectedValues);
                                }
                  
                                // Close the dropdown
                                Navigator.of(context).pop();
                              },
                      ),
                      Expanded(
                        child: Text(
                          value,
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: ThemeColor.get(context).primaryContent
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._selectedValues!.map((String value) {
                return Container(
                  margin: const EdgeInsets.only(right: 2.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.25),
                    borderRadius: const BorderRadius.all(Radius.circular(20.0))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            value,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                        const SizedBox(width:1.0),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedValues!.contains(value)) {
                                _selectedValues!.remove(value);
                              }
                    
                              if (widget.onChanged != null) {
                                widget.onChanged!(_selectedValues);
                              }
                            });
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 13.0,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
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
      ],
    );
  }
}
