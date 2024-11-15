  import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/loading_page.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class OvertimeDisplayPage extends NyStatefulWidget {
  static const path = '/overtime-display';

  OvertimeDisplayPage({super.key})
      : super(path, child: _OvertimeDisplayPageState());
}

class _OvertimeDisplayPageState extends NyState<OvertimeDisplayPage> {
  DateTime _selectedDate = DateTime.now();
  double totalOTHour = 0;
  bool onLoading = false;
  ApiController apiController = ApiController();
  final ScrollController scrollController = ScrollController();
  bool scrollVisibility = true;

  String _langPref = '';

  List<Map> otData = [];
  @override
  init() async {
    scrollController.addListener(scrollListener);
  }

  @override
  boot() async {
    _langPref = await NyStorage.read<String>('languagePref') ?? 'en';
    await getOvertimeList();
  }

  @override
  dispose() {
    super.dispose();
    scrollController.removeListener(scrollListener);
  }

  scrollListener() {
    bool isVisible = true;
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      isVisible = false;
    } else {
      isVisible = true;
    }
    setState(() => scrollVisibility = isVisible);
  }

  getOvertimeList() async {
    setState(() => onLoading = true);
    final month = stringifyDate(_selectedDate, format: 'yyyy-MM');
    final items = await apiController.overtimeList(context, month);
    double total = 0;
    if (items.isNotEmpty) {
      final totalString = items
          .map((it) {
            return double.parse(it['otHours'] ?? 0);
          })
          .reduce((a, b) => a + b)
          .toStringAsFixed(2);
      total = double.parse(totalString);
    }
    setState(() {
      onLoading = false;
      otData = items;
      totalOTHour = total;
    });
  }

  @override
  Widget view(BuildContext context) {
    // final bool isCurrentMonth = _selectedDate.year == DateTime.now().year &&
    //     _selectedDate.month == DateTime.now().month;

    return CustomScaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColor.get(context).background,
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "overtime_page.title".tr(),
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'Poppins-Bold',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      size: 35,
                      color: _selectedDate.month > 1
                          ? Colors.grey
                          : Colors.grey.withOpacity(
                              0.5), // Disable if current month is January
                    ),
                    onPressed: () async {
                      if (_selectedDate.month > 1) {
                        setState(() {
                          _selectedDate = DateTime(
                              _selectedDate.year, _selectedDate.month - 1);
                        });
                        await getOvertimeList();
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showDateRangePicker(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          getFormattedDate(_selectedDate, 'MMMM, yyyy', 'M月 yyyy年', _langPref),
                          // DateFormat("MMMM, yyyy").format(_selectedDate),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      size: 35,
                      color: _selectedDate.month < DateTime.now().month
                          ? Colors.grey
                          : Colors.grey.withOpacity(
                              0.5), // Disable if current month is reached
                    ),
                    onPressed: () async {
                      if (_selectedDate.month < DateTime.now().month) {
                        setState(() {
                          _selectedDate = DateTime(
                              _selectedDate.year, _selectedDate.month + 1);
                        });
                        await getOvertimeList();
                      }
                    },
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              margin: EdgeInsets.only(top: scrollVisibility ? 16 : 0),
              padding: const EdgeInsets.all(16),
              height: scrollVisibility ? 100 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Transform.scale(
                scaleX: scrollVisibility ? 1 : 0,
                child: Wrap(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "overtime_page.total ot".tr(),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              totalOTHour.toString(),
                              textScaler: TextScaler.noScaling,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'Poppins-Bold',
                              ),
                            ),
                            Text(
                              " ${"overtime_page.hours".tr()}",
                              textScaler: TextScaler.noScaling,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'Poppins-Bold',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            Expanded(
              child: onLoading
                  ? const LoadingPager()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: otData.isEmpty
                          ? [
                              Center(
                                child: Text(
                                  "no data".tr(),
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ]
                          : [
                              Text(
                                "overtime_page.details".tr(),
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins-Bold',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'overtime_page.date'.tr(),
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins-Bold"),
                                    ),
                                    Text(
                                      'overtime_page.ot hours'.tr(),
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins-Bold"),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: otData
                                      .length, // Replace with your actual item count
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    Map item = otData[index];
                                    String date = item['startDate'];
                                    double hours =
                                        double.parse(item['otHours']);
                                    bool lastIndex = index == otData.length - 1;
                                    return Container(
                                      padding: EdgeInsets.only(
                                        top: 1.0,
                                        bottom: lastIndex ? 21.0 : 1.0,
                                      ), // Add this line for spacing
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 0,
                                        ), // Add this line to remove ListTile's default padding
                                        tileColor: nyHexColor("#F4F4F4"),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Text(
                                                //   '$startTime - $endTime',
                                                //   style: TextStyle(
                                                //     fontFamily: 'Poppins-Bold',
                                                //     fontSize: 16,
                                                //   ),
                                                // ),
                                                Text(
                                                  getFormattedDate(parsedDate('yyyy-MM-dd', date), 'dd/MM/yyyy (EEEE)', 'dd/MM/yyyy (EEEE)', _langPref),
                                                  textScaler: TextScaler.noScaling,
                                                  style: TextStyle(
                                                    color:
                                                        ThemeColor.get(context)
                                                            .primaryAccent,
                                                    fontFamily: "Poppins-Bold",
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '$hours ${hours > 1 ? "overtime_page.hours".tr() : "overtime_page.hour".tr()}',
                                                  textScaler: TextScaler.noScaling,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins-Bold',
                                                    color: Colors.blue,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                // Text(
                                                //   '903AM04',
                                                //   style: TextStyle(
                                                //     fontSize: 14,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                    ),
            ),
          ],
        ),
      ),
      bottomnavhide: !scrollVisibility,
    );
  }

  void _showDateRangePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Text(
                    "overtime_page.select date".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            child: _buildMonthPicker(setState),
                          ),
                          const SizedBox(width: 8.0),
                          SizedBox(
                            width: 150,
                            child: _buildYearPicker(setState),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, _selectedDate);
                              // Update _selectedDate directly here
                              setState(() {
                                _selectedDate = DateTime(
                                    _selectedDate.year, _selectedDate.month);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                            child: Text("overtime_page.datepicker button".tr(), textScaler: TextScaler.noScaling,),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMonthPicker(StateSetter setState) {
    final currentMonth = DateTime.now().month;
    final months = List.generate(currentMonth, (index) => index + 1);
    final FixedExtentScrollController controller =
        FixedExtentScrollController(initialItem: _selectedDate.month - 1);

    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 50,
      diameterRatio: 1.2,
      useMagnifier: true,
      magnification: 1.2,
      onSelectedItemChanged: (index) async {
        setState(() {
          _selectedDate = DateTime(_selectedDate.year, months[index]);
        });
        await getOvertimeList();
      },
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final isSelected = index == controller.selectedItem;

          return Center(
            child: Text(
              DateFormat('MMM', _langPref).format(DateTime(2000, months[index])),
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: isSelected ? ThemeColor.get(context).primaryContent : Colors.grey,
                fontSize: isSelected ? 20 : 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
        childCount: months.length,
      ),
    );
  }

  Widget _buildYearPicker(StateSetter setState) {
    final currentYear = DateTime.now().year;
    final years =
        List.generate(currentYear - 2000 + 1, (index) => currentYear - index);
    final FixedExtentScrollController controller = FixedExtentScrollController(
        initialItem: years.indexOf(_selectedDate.year));

    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 50,
      diameterRatio: 1.2,
      useMagnifier: true,
      magnification: 1.2,
      onSelectedItemChanged: (index) async {
        setState(() {
          _selectedDate = DateTime(years[index], _selectedDate.month);
        });
        await getOvertimeList();
      },
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final isSelected = index == controller.selectedItem;

          return Center(
            child: Text(
              years[index].toString(),
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: isSelected ? ThemeColor.get(context).primaryContent : Colors.grey,
                fontSize: isSelected ? 20 : 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
        childCount: years.length,
      ),
    );
  }
}
