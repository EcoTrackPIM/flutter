import 'package:flutter/material.dart';
import '../constants/colors.dart';
class CarTypeItem extends StatelessWidget {
  final String carType;
  final String carTitle;
  final bool isSelected;
  final Function(String) onTap;

  const CarTypeItem({
    required this.carType,
    required this.carTitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(carType),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkMainColor : AppColors.cardColor,  // Using AppColors for background
          // border: Border.all(
          //   color: isSelected ? AppColors.accentColor : AppColors.borderColor, // Accent and border colors from AppColors
          //   width: 2,
          // ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          carTitle,
          style: TextStyle(
            color: isSelected ? AppColors.buttonTextColor : AppColors.textPrimary, // Text color using AppColors
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}