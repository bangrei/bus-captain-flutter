import 'package:bc_app/bootstrap/helpers.dart';
import 'package:flutter/material.dart';

class GeneralButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final Color color;
  final double height;
  final bool disabled;
  final Key? key;
  final bool showLoading;
  final Color? textColor;

  const GeneralButton({
    this.key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 8.0, // Default border radius
    this.color = Colors.blue, // Default button color
    this.disabled = false, // Default button color
    this.height = 40.0, // Default height
    this.showLoading = false,
    this.textColor ,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? ()=>() : onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size.fromHeight(height)),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (disabled) {
              return Colors.grey; // Disabled button background color
            }
            return color; // Regular button background color
          },
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: textColor ?? ThemeColor.get(context).appBarPrimaryContent
            ),
          ),
          showLoading
              ? Transform.scale(
                  scale: 0.5,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
