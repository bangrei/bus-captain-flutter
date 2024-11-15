
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';

class InputText extends StatefulWidget {
  final String label;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
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
  final ValueChanged<String>? onCountryCodeChange;
  final bool? capitalized;

  const InputText(
      {Key? key,
      required this.label,
      this.inputFormatters,
      this.maxLines,
      this.maxLength,
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
      this.onChanged,
      this.onCountryCodeChange,
      this.capitalized})
      : super(key: key);

  @override
  _InputTextState createState() => _InputTextState();
}

class Phone {
  String label;
  String value;

  Phone({
    required this.label,
    required this.value,
  });
}

List<Phone> phoneList = [
  Phone(label: 'SG (+65)', value: '+65'),
  Phone(label: 'MY (+60)', value: '+60'),
];

class _InputTextState extends State<InputText> {
  Phone? dropdownValue = phoneList[0];

  @override
  void initState() {
    super.initState();
    widget.onCountryCodeChange?.call(dropdownValue!.value);
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
    return Container(
      child: Column(
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
          ),
          const SizedBox(height: 8.0),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.readOnly ? ThemeColor.get(context).inputBoxReadOnly: ThemeColor.get(context).inputBoxNormal,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: NyTextField(
                  inputFormatters: widget.inputFormatters ?? [FilteringTextInputFormatter.deny(_allowedPattern)],
                  textCapitalization: widget.capitalized != null && widget.capitalized! ? TextCapitalization.characters : TextCapitalization.none,
                  maxLines: widget.textarea ?? false ? null : 1,
                  maxLength: widget.maxLength ?? TextField.noMaxLength,
                  controller: widget.controller ?? _controller,
                  enabled: !widget.readOnly,
                  readOnly: widget.readOnly,
                  validationRules: widget.rules,
                  validationErrorMessage: widget.errorMessage,
                  onChanged: widget.onChanged,
                  keyboardType: widget.type == TextInputType.phone
                      ? TextInputType.number
                      : widget.keyboardType ?? widget.type,
                  passwordVisible: widget.type == TextInputType.visiblePassword,
                  style: TextStyle(fontSize: 14.0, color: ThemeColor.get(context).primaryContent),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.fromLTRB(
                        widget.type == TextInputType.phone ? 90 : 16, 16, 16, 16),
                    hintText: widget.placeholder,
                    hintStyle:
                        TextStyle(fontSize: 14.0, color: ThemeColor.get(context).hintText),
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
              if (widget.type == TextInputType.phone)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2.5, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(color: Colors.grey, width: 1))),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            value: dropdownValue,
                            style: TextStyle(
                                fontFamily: 'Poppins-Regular',
                                fontSize: 14.0,
                                color: ThemeColor.get(context).primaryContent),
                            items: phoneList
                                .map<DropdownMenuItem<Phone>>((Phone phone) {
                              return DropdownMenuItem<Phone>(
                                value: phone,
                                child: Text(phone.label, textScaler: TextScaler.noScaling,),
                              );
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return phoneList.map<Widget>((Phone phone) {
                                return Container(
                                  width: 32,
                                  alignment: Alignment.centerLeft,
                                  child: Text(phone.value, textScaler: TextScaler.noScaling,),
                                );
                              }).toList();
                            },
                            onChanged: (Phone? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                                widget.onCountryCodeChange!(newValue.value);
                              });
                            })),
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
        ],
      ),
    );
  }
}
