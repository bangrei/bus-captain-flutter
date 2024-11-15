import 'package:bc_app/resources/pages/bc_declaration_page.dart';
import 'package:bc_app/resources/pages/document_page.dart';
import 'package:bc_app/resources/pages/driving_performance_page.dart';
import 'package:bc_app/resources/pages/duty_roster_page.dart';
import 'package:bc_app/resources/pages/leave_request_page.dart';
import 'package:bc_app/resources/pages/overtime_display_page.dart';
import 'package:bc_app/resources/pages/payslip_page.dart';
import 'package:bc_app/resources/pages/settings_page.dart';
import 'package:bc_app/resources/pages/uniformrequest_page.dart';

import '../resources/pages/help_page.dart';
import '../resources/pages/login_page.dart';

// name are map to  en.json "sidebar" keys
List<Map<String, dynamic>> sideMenuItems = [
  {"name": "attendance", "icon": "attendance.png", "path": "/attendance"},
  {
    "name": "bus check",
    "icon": "filedocksearch.png",
    "path": BCDeclarationPage.path
  },
  {
    "name": "document access",
    "icon": "filedock.png",
    "path": DocumentPage.path
  },
  {
    "name": "driving performance",
    "icon": "pressure.png",
    "path": DrivingPerformancePage.path
  },
  {"name": "duty roster", "icon": "time.png", "path": DutyRosterPage.path},
  // {
  //   "name": "learning system",
  //   "icon": "desktop.png",
  //   "path": "/learning-system"
  // },
  {
    "name": "leave request",
    "icon": "calendar.png",
    "path": LeaveRequestPage.path
  },
  {
    "name": "overtime",
    "icon": "timeprogress.png",
    "path": OvertimeDisplayPage.path
  },
  {"name": "payslip", "icon": "wallet.png", "path": PayslipPage.path},
  {
    "name": "uniform request",
    "icon": "outline.png",
    "path": UniformRequestPage.path
  },
];

List<Map<String, dynamic>> sideMenuSettings = [
  {"name": "settings", "icon": "settings.png", "path": SettingsPage.path},
  {"name": "help", "icon": "help.png", "path": HelpPage.path},
  {"name": "logout account", "icon": "logout.png", "path": LoginPage.path},
];
