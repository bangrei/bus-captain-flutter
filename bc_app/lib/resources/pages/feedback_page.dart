import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/datetimepicker_widget.dart';
import 'package:bc_app/resources/widgets/components/image_photo_picker_widget.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_area_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class FeedbackPage extends NyStatefulWidget {
  static const path = '/feedback';

  FeedbackPage({super.key}) : super(path, child: _FeedbackPageState());

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends NyState<FeedbackPage> {
  TextEditingController dateTimeController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  File? attachment;
  String? issueType;
  List<String> feedbackTypes = [];
  
  @override
  void init() {
    super.init();
  }

  @override
  boot() async {
    await getFeedbackType();
  }

  getFeedbackType() async {
    final types = await apiController.getFeedbackTypes(context);
    setState(() {
      feedbackTypes = types;
      feedbackTypes.sort((a, b) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    });
  }

  ApiController apiController = ApiController();

  submitFeedback() async {
    if (isLoading(name: 'submittingFeedback')) return;
    setLoading(true, name: 'submittingFeedback');
    final res = await apiController.submitFeedback(
      context: context,
      description: remarksController.text,
      type: issueType!,
      document: attachment,
      timeReported: dateTimeController.text,
    );
    setLoading(false, name: 'submittingFeedback');
    if (res) Navigator.pop(context);
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    required TextEditingController dateTimeController,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));
    
    String langPref = await NyStorage.read<String>('languagePref') ??'en';

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: Locale(langPref)
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      initialTime: _selectedTime ?? TimeOfDay.fromDateTime(initialDate),
    );

    if (selectedTime == null) {
      return selectedDate;
    } else {
      final DateTime finalDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Update the dateTimeController with the selected date and time
      setState(() {
        _selectedTime = selectedTime;
        _selectedDate = selectedDate;

        // Format date and time using intl package
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        String formattedDateTime =
            '${formatter.format(selectedDate.toLocal())} ${selectedTime.format(context)}';

        dateTimeController.text = formattedDateTime;
      });

      return finalDateTime;
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: 'feedback_page.title'.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 15.5,
              right: 15.5,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // This line is updated
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDropdown(
                  label: 'feedback_page.question 1'.tr(),
                  items: feedbackTypes,
                  value: null,
                  placeholder: 'feedback_page.question 1 hint'.tr(),
                  onChanged: (String? newValue) {
                    setState(() => issueType = newValue);
                  },
                ),
                DateTimePicker(
                  label: 'feedback_page.question 2'.tr(),
                  onTap: () => showDateTimePicker(
                    context: context,
                    dateTimeController: dateTimeController,
                  ),
                  dateTimeController: dateTimeController,
                  placeholder: 'feedback_page.question 2 hint'.tr(),
                  onChanged: (String? newValue) {
                    debugPrint(newValue);
                  },
                ),
                InputTextArea(
                  label: 'feedback_page.question 3'.tr(),
                  placeholder: 'feedback_page.question 3 hint'.tr(),
                  textarea: true,
                  controller: remarksController,
                ),
                PhotoPicker(
                  label: "feedback_page.question 4".tr(),
                  callback: (file) async {
                    setState(() => attachment = file);
                  },
                ),
                const SizedBox(height: 20),
                GeneralButton(
                  text: 'feedback_page.submit'.tr(),
                  disabled: isLoading(name: 'submittingFeedback'),
                  showLoading: isLoading(name: 'submittingFeedback'),
                  onPressed: () async {
                    submitFeedback();
                  },
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
