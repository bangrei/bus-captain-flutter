import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';

class InputTextForm extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? placeholder;
  final bool readOnly;
  final bool editable;
  final bool? required;
  final String? value;
  final TextInputType type;
  final TextInputType keyboardType;
  final FormFieldValidator? validator;
  final Function(String value)? onChanged;

  const InputTextForm({
      Key? key,
      required this.label,
      this.controller,
      this.placeholder,
      this.readOnly = false,
      this.editable = false,
      this.required = false,
      this.value = '',
      this.type = TextInputType.text,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.onChanged})
      : super(key: key);

  @override
  _InputTextFormState createState() => _InputTextFormState();
}

class _InputTextFormState extends State<InputTextForm> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller?.text = widget.value!;
    } else {
      _controller.text = widget.value!;
    }
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }



  final TextEditingController _controller = TextEditingController();

  final RegExp _allowedPattern = allowedInputTextPattern();


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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Builder(builder: (context) {
              if (widget.required!) {
                return Text(
                  "*${"user_profile.driving_license_screen.required".tr()}",
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                      color: Colors.red, fontStyle: FontStyle.italic),
                );
              }
              return const SizedBox();
            })
          ],
        ),
        const SizedBox(height: 8.0),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: widget.readOnly ? ThemeColor.get(context).inputBoxReadOnly : ThemeColor.get(context).surfaceBackground,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextFormField(
                inputFormatters: [FilteringTextInputFormatter.deny(_allowedPattern)],
                controller: widget.controller ?? _controller,
                enabled: !widget.readOnly,
                readOnly: widget.readOnly,
                onChanged: widget.onChanged,
                keyboardType: widget.keyboardType ?? widget.type,
                obscureText: widget.type == TextInputType.visiblePassword ? _obscureText : false,
                validator: widget.validator,
                style: const TextStyle(fontSize: 14.0),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  hintText: widget.placeholder,
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                ),
                onTapOutside: (PointerDownEvent event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
            if (widget.type == TextInputType.visiblePassword)
              Positioned(
                right: 3,
                top: 3,
                child: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: _toggleVisibility,
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
