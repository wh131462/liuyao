import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Icon? leftIcon;
  final VoidCallback? onLeftIconPressed;
  final Icon? rightIcon;
  final VoidCallback? onRightIconPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leftIcon,
    this.onLeftIconPressed,
    this.rightIcon,
    this.onRightIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leftIcon != null
          ? IconButton(
              icon: leftIcon!,
              onPressed: onLeftIconPressed,
            )
          : null,
      title: Text(title),
      centerTitle: true,
      actions: rightIcon != null
          ? [
              IconButton(
                icon: rightIcon!,
                onPressed: onRightIconPressed,
              ),
            ]
          : [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
