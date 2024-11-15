import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';

class InputTextArea extends StatefulWidget {
  final String label;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final String? placeholder;
  final String? rules;
  final String? errorMessage;
  final bool readOnly;
  final bool editable;
  final bool? required;
  final bool? textarea;
  final String? value;
  final TextInputType type;
  final TextInputType keyboardType;
  final Function(String value)? onChanged;

  const InputTextArea(
      {Key? key,
      required this.label,
      this.inputFormatters,
      this.controller,
      this.placeholder,
      this.rules,
      this.errorMessage,
      this.textarea,
      this.readOnly = false,
      this.editable = false,
      this.required = false,
      this.value = '',
      this.type = TextInputType.text,
      this.keyboardType = TextInputType.text,
      this.onChanged})
      : super(key: key);

  @override
  _InputTextAreaState createState() => _InputTextAreaState();
}

class _InputTextAreaState extends State<InputTextArea> {
  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller?.text = widget.value!;
    } else {
      _controller.text = widget.value!;
    }
  }

  final TextEditingController _controller = TextEditingController();
  final RegExp _allowedPattern = allowedInputTextPattern();


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
              if (widget.label.isNotEmpty)
                Text(
                  widget.label,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (widget.required!)
                Text(
                  "* ${"driving_license_screen.required".tr()}",
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                      color: Colors.red, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        Stack(
          children: [
            Container(
              width: widget.textarea ?? false ? double.infinity : null,
              height: 120,
              decoration: BoxDecoration(
                color: widget.readOnly ? ThemeColor.get(context).inputBoxReadOnly: ThemeColor.get(context).inputBoxNormal,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: NyTextField(
                  inputFormatters: [FilteringTextInputFormatter.deny(_allowedPattern)],
                  maxLength: 100,
                  maxLines: widget.textarea ?? false ? null : 1,
                  controller: widget.controller ?? _controller,
                  enabled: !widget.readOnly,
                  readOnly: widget.readOnly,
                  validationRules: widget.rules,
                  validationErrorMessage: widget.errorMessage,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType ?? widget.type,
                  passwordVisible: widget.type == TextInputType.visiblePassword,
                  style: TextStyle(fontSize: 14.0, color: ThemeColor.get(context).primaryContent),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    hintText: widget.placeholder,
                    hintStyle:
                        const TextStyle(fontSize: 14.0, color: Color(0xFF666666)),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onTapOutside: (PointerDownEvent event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),
            ),
            if (widget.editable)
              Positioned(
                right: 14,
                top: 14,
                child: Icon(Icons.edit_outlined,
                    color: widget.editable ? Colors.black : Colors.grey),
              ),
          ],
        ),
        const SizedBox(height: 20.0)
      ],
    );
  }
}
