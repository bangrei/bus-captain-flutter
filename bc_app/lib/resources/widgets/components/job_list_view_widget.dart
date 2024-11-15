import 'package:bc_app/app/models/duty_roster.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class JobListView extends StatefulWidget {
  final List<Duty> jobs;
  final Function? refreshJob;

  JobListView({super.key, required this.jobs, this.refreshJob});

  @override
  State<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends NyState<JobListView> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String _langPref = 'en';

  @override
  boot() async{
    // TODO: implement boot
    String langPref = await NyStorage.read<String>('languagePref') ??'en';

    setState(() {
      _langPref = langPref;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => widget.refreshJob!(),
      child: (widget.jobs.isEmpty)
      ? Center(
        child:Text(
          "no data".tr(),
          textScaler: TextScaler.noScaling,
          style: TextStyle(color: ThemeColor.get(context).primaryContent),
        )
      )
      : 
        ListView.builder(
          // shrinkWrap: true,
          itemCount: widget.jobs.length,
          itemBuilder: (context, index) {
            final job = widget.jobs[index];
            String jobDate = DateFormat('dd/MM/yyyy EEEE', _langPref).format(DateFormat('dd/MM/yyyy EEEE').parse(job.date));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 0, 5),
                  child: Text(jobDate, textScaler: TextScaler.noScaling, style: const TextStyle(fontSize: 14)),
                ),
                Card(
                  color: ThemeColor.get(context).cardBg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.workdayId,
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            (job.startTime != '' || job.endTime != '') 
                              ? 
                                Text(
                                  '${job.startTime} - ${job.endTime}',
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(fontSize: 13)
                                )
                              : const SizedBox(),
                            (job.fromDep != '' || job.toDep != '') 
                              ? 
                                Text(
                                  '${job.fromDep} - ${job.toDep}',
                                  textScaler: TextScaler.noScaling,
                                  style: TextStyle(
                                    fontSize: 13,
                                  )
                                )
                              : const SizedBox(),      
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (job.busPlateNum != '') 
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                  // height: 24,
                                  // width: 114,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: nyHexColor('A08D47')),
                                  child: Center(
                                    child: Text(
                                      job.busPlateNum,
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ))
                            : const SizedBox(),
                            const SizedBox(height: 15),
                            (job.ovtCode != '') 
                            ? Center(
                              child: Text(
                                job.ovtCode,
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent),
                              ),
                            )
                            : const SizedBox(),   

                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }
}