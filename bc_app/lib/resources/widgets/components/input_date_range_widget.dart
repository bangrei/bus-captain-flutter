import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class InputDateRange extends StatelessWidget {
  final String labelFrom;
  final String labelTo;
  final DateTime? fromDate;
  final DateTime? toDate;
  final Function(DateTime?) onFromChanged;
  final Function(DateTime?) onToChanged;

  const InputDateRange({
    Key? key,
    required this.labelFrom,
    required this.labelTo,
    required this.fromDate,
    required this.toDate,
    required this.onFromChanged,
    required this.onToChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelFrom,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectFromDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          fromDate != null
                              ? '${fromDate!.day.toString().padLeft(2, '0')}/${fromDate!.month.toString().padLeft(2, '0')}/${fromDate!.year}'
                              : 'DD/MM/YYYY',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: fromDate != null ? ThemeColor.get(context).primaryContent : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16), // Add spacing between the date inputs
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelTo,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectToDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          toDate != null
                              ? '${toDate!.day.toString().padLeft(2, '0')}/${toDate!.month.toString().padLeft(2, '0')}/${toDate!.year}'
                              : 'DD/MM/YYYY',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: toDate != null ? ThemeColor.get(context).primaryContent : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale(lang),
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: toDate ?? DateTime(2100),
    );
    if (picked != null) {
      onFromChanged(picked);
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale(lang),
      initialDate: (toDate != null && toDate!.isAfter(fromDate ?? DateTime(2000))) ? toDate! : (fromDate ?? DateTime.now()),
      firstDate: fromDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onToChanged(picked);
    }
  }
}
