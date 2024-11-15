import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SectionHeader extends StatelessWidget {
  IconData? icon;
  String? image;
  String sectionName;

  SectionHeader({super.key, this.icon, this.image, required this.sectionName});

  @override
  Widget build(BuildContext context) {
    Color color = nyHexColor("#1570EF");

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            width: 50,
            child: icon != null
                ? Icon(
                    icon,
                    color: color,
                    size: 24,
                  )
                : Image(
                    image: AssetImage(image!),
                    height: 24,
                    fit: BoxFit.fitHeight,
                  )),
        SizedBox(
          width: 150,
          child: Text(
            sectionName,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontFamily: "Poppins-Bold",
              color: color,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
