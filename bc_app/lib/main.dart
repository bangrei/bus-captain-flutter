import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import '/bootstrap/app.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'bootstrap/boot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Nylo nylo = await Nylo.init(setup: Boot.nylo, setupFinished: Boot.finished);

  // debugPrint("App version: ${await getAppVersion()}");

  await FlutterDownloader.initialize(
    debug: getEnv('APP_DEBUG'), // optional: set false to disable printing logs to console
  );

  await Upgrader.clearSavedSettings(); // REMOVE this for release builds



  runApp(
    AppBuild(
      navigatorKey: NyNavigator.instance.router.navigatorKey,
      onGenerateRoute: nylo.router!.generator(),
      debugShowCheckedModeBanner: false,
      initialRoute: nylo.getInitialRoute(),
    ),
  );
}
