import 'package:flutter/material.dart';
import 'package:kaboodle/theme/light_mode.dart';

class CustomButton extends StatelessWidget {
  final String? buttonText;
  final Function()? onPressed;
  final Color? buttonColor;
  final Color textColor;
  final bool? isLoading;
  final Widget? icon;
  final Color? borderColor;
  final double? width, height;
  final double? borderRadius;
  final double? elevation;
  const CustomButton(
      {super.key,
      required this.buttonText,
      required this.onPressed,
      this.buttonColor,
      required this.textColor,
      required this.isLoading,
      this.icon,
      this.borderColor,
      this.width,
      this.height,
      this.borderRadius,
      this.elevation});

  @override
  Widget build(BuildContext context) {
    return isLoading != true
        ? MaterialButton(
            padding: EdgeInsets.zero,
            elevation: elevation,
            height: height ?? 50,
            minWidth: width ?? MediaQuery.of(context).size.width,
            onPressed: onPressed, // will be null if button is disabled
            color: buttonColor ?? lightMode.colorScheme.primary,
            disabledColor: lightMode.colorScheme.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? 5,
              ),
              side: borderColor != null
                  ? BorderSide(
                      color: borderColor!,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: icon,
                  ),
                if (!(buttonText == null || buttonText!.isEmpty))
                  Text(
                    buttonText!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                  ),
              ],
            ),
          )
        : MaterialButton(
            elevation: 0,
            height: 50,
            minWidth: width ?? MediaQuery.of(context).size.width,
            onPressed: () {},
            color: borderColor != null ? buttonColor : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: borderColor != null
                  ? const BorderSide(
                      color: Color.fromARGB(255, 204, 204, 204),
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            child: Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(color: textColor),
              ),
            ),
          );
  }
}
