import 'package:bc_app/resources/pages/attendance_page.dart';
import 'package:bc_app/resources/pages/bc_declaration_page.dart';
import 'package:bc_app/resources/pages/document_page.dart';
import 'package:bc_app/resources/pages/driving_performance_page.dart';
import 'package:bc_app/resources/pages/duty_roster_page.dart';
import 'package:bc_app/resources/pages/leave_request_page.dart';
import 'package:bc_app/resources/pages/overtime_display_page.dart';
import 'package:bc_app/resources/pages/payslip_page.dart';
import 'package:bc_app/resources/pages/uniformrequest_page.dart';

// name are map to  en.json "homepage_screen" keys
List<Map<String, dynamic>> mainMenuItems = [
  {"name": "bus check", "icon": "buscheck.png", "path": BCDeclarationPage.path},
  {
    "name": "duty roster",
    "icon": "dutyroster.png",
    "path": DutyRosterPage.path
  },
  {
    "name": "driving performance",
    "icon": "drivingperformance.png",
    "path": DrivingPerformancePage.path
  },
  {
    "name": "leave request",
    "icon": "leaverequest.png",
    "path": LeaveRequestPage.path
  },
  {
    "name": "uniform request",
    "icon": "uniformrequest.png",
    "path": UniformRequestPage.path
  },
  {"name": "payslip", "icon": "payslip.png", "path": PayslipPage.path},
  {
    "name": "attendance",
    "icon": "attendance-menu.png",
    "path": AttendancePage.path
  },
  // {
  //   "name": "learning system",
  //   "icon": "learningsystem.png",
  //   "path": "/learning-system"
  // },
  {
    "name": "document access",
    "icon": "documentaccess.png",
    "path": DocumentPage.path
  },
  {
    "name": "overtime",
    "icon": "overtimedisplay.png",
    "path": OvertimeDisplayPage.path
  }
];
