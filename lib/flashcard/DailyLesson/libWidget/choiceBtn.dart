import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';

class ChoiceBtn extends StatelessWidget {
  String value;
  bool isSelected;
  VoidCallback? onPressed;
  ChoiceBtn({
    super.key,
    required this.isSelected,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 160,
        height: 70,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: isSelected ? AppColor.greenMuted : AppColor.darkCard,
              width: 4,
            ),
            backgroundColor: isSelected
                ? AppColor.darkSurface
                : AppColor.darkBase,
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? AppColor.greenMuted : Colors.white,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}