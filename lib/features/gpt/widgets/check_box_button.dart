// Custom Toggle Button Widget
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';

class CheckboxButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final ValueChanged<bool> onTap;
  final IconData icon;

  const CheckboxButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
                  .withOpacity(0.2) // Highlight when selected
              : (isDarkMode ? Pallete.greyColor : Pallete.whiteColor),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isDarkMode
                    ? Colors.white30
                    : Colors.black26,
            width: isSelected ? 2 : 1, // Slightly thicker border when selected
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: isDarkMode ? Colors.white : Colors.black),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDarkMode ? Colors.white : Colors.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
