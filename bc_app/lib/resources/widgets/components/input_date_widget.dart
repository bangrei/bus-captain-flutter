import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';

class InputDate extends StatelessWidget {
  final String label;
  final String? placeholder;
  final bool readOnly;
  final bool editable;
  final bool? required;
  final String? notes;
  final TextInputType type;
  final Function(DateTime?) onDateChanged;
  final DateTime? value;
  final String? dateFormat;

  const InputDate(
      {super.key,
      required this.label,
      required this.onDateChanged,
      this.value,
      this.placeholder,
      this.readOnly = false,
      this.editable = false,
      this.required = false,
      this.notes,
      this.type = TextInputType.text,
      this.dateFormat = 'dd MMM yyyy'});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Builder(builder: (context) {
              if (required!) {
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
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Row(children: [
            Expanded(
              // This will make the container take up 100% of available width
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: readOnly
                      ? ThemeColor.get(context).inputBoxReadOnly
                      : ThemeColor.get(context).inputBoxNormal,
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      top: 12,
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: ThemeColor.get(context).primaryAccent,
                      ),
                    ),
                    Align(
                      alignment:
                          Alignment.centerLeft, // Vertically centers the text
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                        child: Text(
                          value != null
                              ? DateFormat(dateFormat).format(value!)
                              : placeholder ?? 'Select a date',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            // backgroundColor: Colors.white,
                            fontSize: 14,
                            color: ThemeColor.get(context).primaryContent,
                          ),
                        ),
                      ),
                    ),
                    if (editable)
                      const Positioned(
                        right: 10,
                        top: 12,
                        child: Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
              ),
            ),
          ]),
        ),
        Builder(builder: (context) {
          if (notes != null) {
            return Column(
              children: [
                const SizedBox(height: 3.0),
                Text(
                  notes!,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                ),
                const SizedBox(height: 6.0)
              ],
            );
          }
          return const SizedBox(height: 20.0);
        })
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTime? picked = await showDatePicker(
        context: context,
        locale: Locale(lang),
        initialDate: value ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      onDateChanged(picked);
    }
  }
}
