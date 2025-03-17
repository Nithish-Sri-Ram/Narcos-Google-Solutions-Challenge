// SearchBarButton Widget
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';

class SearchBarButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const SearchBarButton({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Pallete.greyColor : Pallete.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isDarkMode ? Colors.white30 : Colors.black26),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: isDarkMode ? Colors.white : Colors.black),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
