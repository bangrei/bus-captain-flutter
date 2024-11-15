import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final String? backButtonLabel;
  final Function? callback;
  @override
  final Key? key;

  const TitleBar({
    this.key,
    this.title,
    this.subtitle,
    this.backButtonLabel,
    this.callback,
  }) : super(key: key);

  @override
  Size get preferredSize {
    if (title == null && subtitle == null) {
      return const Size.fromHeight(56);
    } else {
      return Size.fromHeight(subtitle != null ? 110 : 81);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(3, 3, 0, 0),
                    child: IconButton(
                      onPressed: () {
                        if (callback != null) {
                          callback!();
                        } else {
                          // Must always return to homepage
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: ThemeColor.get(context).backButtonIcon,
                    ),
                  ),
                  backButtonLabel == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            backButtonLabel!,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                // decoration: TextDecoration.underline
                                ),
                          ),
                        )
                ],
              ),
              if (title != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        title!,
                        textScaler: TextScaler.noScaling,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ThemeColor.get(context).primaryContent,
                            fontSize: 18.8,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins-bold"),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          textScaler: TextScaler.noScaling,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ThemeColor.get(context).primaryContent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-bold"),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
