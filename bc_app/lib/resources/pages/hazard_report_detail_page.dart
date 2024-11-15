import 'package:bc_app/app/models/hazard_report.dart';
import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HazardReportDetailPage extends NyStatefulWidget {
  static const path = '/hazard-report-detail';

  HazardReportDetailPage({super.key})
      : super(path, child: _HazardReportDetailPageState());
}

class _HazardReportDetailPageState extends NyState<HazardReportDetailPage> {
  HazardReport? report;
  String baseUrl = ApiService().baseUrl;
  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    Map args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() => report = args['data']);
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: 'hazard_report_detail_page.title'.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'hazard_report_detail_page.case id'.tr(),
                  Text(report!.caseId, textScaler: TextScaler.noScaling,),
                ),
                _buildDivider(),
                _buildDetailRow(
                  'hazard_report_detail_page.location'.tr(),
                  Text(report!.location, textScaler: TextScaler.noScaling, textAlign: TextAlign.right),
                ),
                _buildDivider(),
                _buildDetailRow(
                  'hazard_report_detail_page.status'.tr(),
                  Container(
                    // width: 150,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getHazardReportStatusColor(report!.status.toLowerCase()), // Red background
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "hazard_report_page.filter label ${report!.status.toLowerCase()}".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildDetailRow(
                  'hazard_report_detail_page.submit date'.tr(),
                  Text(
                    dateFormatString(
                      report!.timeReported,
                      fromFormat: 'yyyy-MM-dd HH:mm',
                      toFormat: 'dd/MM/yyyy, HH:mm',
                    ),
                    textScaler: TextScaler.noScaling,
                  ),
                ),
                _buildDivider(),
                _buildDescriptionAndImage(report!, baseUrl),
                _buildDivider(),
                _buildCommentsandResolutionAttachments(report!, baseUrl)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          // flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14, // Reduced size for the label
              ),
            ),
          ),
        ),
        Expanded(
          // flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: value,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(),
    );
  }

  Widget _buildDescriptionAndImage(HazardReport report, String url) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hazard_report_detail_page.description'.tr(),
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report.description,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: [
            ...report.attachments.map((att) {
              return GestureDetector(
                 onTap: () {
                  displayDialog(
                    context: context,
                    headerWidget: const SizedBox.shrink(),
                    bodyWidget: Image.network(
                      "$url${att['url']}",
                      fit: BoxFit.cover,
                    ),
                  );
                },
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: SizedBox(
                    child: Image.network(
                      "$url${att['thumbUrl']}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            })
          ],
        )
      ],
    );
  }

  Widget _buildCommentsandResolutionAttachments(HazardReport report, String url) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hazard_report_detail_page.comments'.tr(),
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report.comments,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: [
            ...report.resolutionAttachments.map((att) {
              return GestureDetector(
                onTap: () {
                  displayDialog(
                    context: context,
                    headerWidget: const SizedBox.shrink(),
                    bodyWidget: Image.network(
                      "$url${att['url']}",
                      fit: BoxFit.cover,
                    ),
                  );
                },
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: SizedBox(
                    child: Image.network(
                      "$url${att['thumbUrl']}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            })
          ],
        )
      ],
    );
  }
}
