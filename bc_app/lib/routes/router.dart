import 'dart:io';

import 'package:bc_app/resources/pages/about_page.dart';
import 'package:bc_app/resources/pages/bc_declaration_page.dart';
import 'package:bc_app/resources/pages/bus_check_page.dart';
import 'package:bc_app/resources/pages/change_password_page.dart';
import 'package:bc_app/resources/pages/choose_language_page.dart';
import 'package:bc_app/resources/pages/document_view_page.dart';
import 'package:bc_app/resources/pages/driving_license_page.dart';
import 'package:bc_app/resources/pages/end_of_trip_tasks_page.dart';
import 'package:bc_app/resources/pages/feedback_page.dart';
import 'package:bc_app/resources/pages/forgot_password_page.dart';
import 'package:bc_app/resources/pages/hazard_report_detail_page.dart';
import 'package:bc_app/resources/pages/hazard_report_page.dart';
import 'package:bc_app/resources/pages/help_page.dart';
import 'package:bc_app/resources/pages/home_page.dart';
import 'package:bc_app/resources/pages/leave_request_form_page.dart';
import 'package:bc_app/resources/pages/leave_request_page.dart';
import 'package:bc_app/resources/pages/login_page.dart';
import 'package:bc_app/resources/pages/message_detail_page.dart';
import 'package:bc_app/resources/pages/message_page.dart';
import 'package:bc_app/resources/pages/new_uniformrequest_page.dart';
import 'package:bc_app/resources/pages/notifications_detail_page.dart';
import 'package:bc_app/resources/pages/otp_page.dart';
import 'package:bc_app/resources/pages/overtime_display_page.dart';
import 'package:bc_app/resources/pages/parade_tasks_page.dart';
import 'package:bc_app/resources/pages/payslip_page.dart';
import 'package:bc_app/resources/pages/pdf_view_page.dart';
import 'package:bc_app/resources/pages/profile_page.dart';
import 'package:bc_app/resources/pages/qr_scanner_page.dart';
import 'package:bc_app/resources/pages/reset_password_page.dart';
import 'package:bc_app/resources/pages/settings_choose_language_page.dart';
import 'package:bc_app/resources/pages/settings_page.dart';
import 'package:bc_app/resources/pages/shopping_cart_page.dart';
import 'package:bc_app/resources/pages/starting_page.dart';
import 'package:bc_app/resources/pages/uniformrequest_page.dart';
import 'package:bc_app/resources/pages/webview_page.dart';
import 'package:bc_app/resources/pages/welcome_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/resources/pages/attendance_page.dart';
import '/resources/pages/bus_checklist_detail_page.dart';
import '/resources/pages/bus_checklist_history_page.dart';
import '/resources/pages/bus_last_parked_page.dart';
import '/resources/pages/choose_bus_page.dart';
import '/resources/pages/document_files_page.dart';
import '/resources/pages/document_page.dart';
import '/resources/pages/driving_license_update_page.dart';
import '/resources/pages/driving_performance_detail_page.dart';
import '/resources/pages/driving_performance_occurrence_detail_page.dart';
import '/resources/pages/driving_performance_page.dart';
import '/resources/pages/duty_roster_page.dart';
import '/resources/pages/lms_detail_page.dart';
import '/resources/pages/lms_page.dart';
import '/resources/pages/message_category_page.dart';
import '/resources/pages/notifications_page.dart';
import '/resources/pages/splash_screen_page.dart';
import '../resources/pages/hazard_report_form_page.dart';

initialPage(router) {
  if (Platform.isAndroid) {
    router.route(SplashScreenPage.path, (context) => SplashScreenPage(),
        transition: PageTransitionType.rightToLeftWithFade, initialRoute: true);
    router.route(StartingPage.path, (context) => StartingPage(),
        transition: PageTransitionType.rightToLeftWithFade);
  } else {
    router.route(StartingPage.path, (context) => StartingPage(),
        transition: PageTransitionType.rightToLeftWithFade, initialRoute: true);
  }
}

appRouter() => nyRoutes((router) {
      initialPage(router);
      router.route(ChooseLanguagePage.path, (context) => ChooseLanguagePage());
      router.route(HomePage.path, (context) => HomePage(),
          transition: PageTransitionType.bottomToTop);
      router.route(LoginPage.path, (context) => LoginPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(OtpPage.path, (context) => OtpPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(SettingsPage.path, (context) => SettingsPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(SettingsChooseLanguagePage.path,
          (context) => SettingsChooseLanguagePage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(AboutPage.path, (context) => AboutPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(ProfilePage.path, (context) => ProfilePage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(ChangePasswordPage.path, (context) => ChangePasswordPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(DrivingLicensePage.path, (context) => DrivingLicensePage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(WelcomePage.path, (context) => WelcomePage(),
          transition: PageTransitionType.rightToLeftWithFade,
          authPage: !Platform.isAndroid);
      router.route(FeedbackPage.path, (context) => FeedbackPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(PayslipPage.path, (context) => PayslipPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(PdfViewPage.path, (context) => PdfViewPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(ForgotPasswordPage.path, (context) => ForgotPasswordPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(HelpPage.path, (context) => HelpPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(ResetPasswordPage.path, (context) => ResetPasswordPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(MessagePage.path, (context) => MessagePage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(MessageDetailPage.path, (context) => MessageDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(WebviewPage.path, (context) => WebviewPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(LeaveRequestPage.path, (context) => LeaveRequestPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(
          LeaveRequestFormPage.path, (context) => LeaveRequestFormPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(
        UniformRequestPage.path,
        (context) => UniformRequestPage(),
      );
      router.route(
        NewUniformRequestPage.path,
        (context) => NewUniformRequestPage(),
      );
      router.route(
        ShoppingCartPage.path,
        (context) => ShoppingCartPage(),
      );
      router.route(DutyRosterPage.path, (context) => DutyRosterPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(OvertimeDisplayPage.path, (context) => OvertimeDisplayPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(DrivingLicenseUpdatePage.path,
          (context) => DrivingLicenseUpdatePage());
      router.route(
        AttendancePage.path,
        (context) => AttendancePage(),
      );
      router.route(
          DrivingPerformancePage.path, (context) => DrivingPerformancePage());
      router.route(DrivingPerformanceDetailPage.path,
          (context) => DrivingPerformanceDetailPage());
      router.route(DrivingPerformanceOccurrenceDetailPage.path,
          (context) => DrivingPerformanceOccurrenceDetailPage());
      router.route(BusCheckPage.path, (context) => BusCheckPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(QRScanner.path, (context) => QRScanner(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(ParadeTasksPage.path, (context) => ParadeTasksPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(EndOfTripTasksPage.path, (context) => EndOfTripTasksPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(BCDeclarationPage.path, (context) => BCDeclarationPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(
          BusChecklistHistoryPage.path, (context) => BusChecklistHistoryPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(
          BusChecklistDetailPage.path, (context) => BusChecklistDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(BuslastParkedLocationPage.path,
          (context) => BuslastParkedLocationPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(ChooseBusPage.path, (context) => ChooseBusPage());
      router.route(NotificationsPage.path, (context) => NotificationsPage());
      router.route(
          NotificationsDetailPage.path, (context) => NotificationsDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(
          HazardReportFormPage.path, (context) => HazardReportFormPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(HazardReportPage.path, (context) => HazardReportPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(
          HazardReportDetailPage.path, (context) => HazardReportDetailPage(),
          transition: PageTransitionType.rightToLeftWithFade);
      router.route(DocumentPage.path, (context) => DocumentPage());
      router.route(DocumentFilesPage.path, (context) => DocumentFilesPage());
      router.route(
          MessageCategoryPage.path, (context) => MessageCategoryPage());
      router.route(LmsPage.path, (context) => LmsPage());
      router.route(LmsDetailPage.path, (context) => LmsDetailPage());
      router.route(DocumentViewPage.path, (context) => DocumentViewPage(),
          transition: PageTransitionType.rightToLeftWithFade);
    });
