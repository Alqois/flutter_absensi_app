import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/colors.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final String iconPath; // svg path
  final VoidCallback onPressed;
  final bool disabled;

  const MenuButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = disabled ? AppColors.card : AppColors.white;
    final border = disabled ? AppColors.stroke : AppColors.blueLight;
    final textColor = disabled ? AppColors.subtitle : AppColors.title;
    final iconColor = disabled ? AppColors.disabled : AppColors.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: disabled ? AppColors.disabled : AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
