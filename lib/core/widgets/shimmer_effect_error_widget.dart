import 'package:flutter/material.dart';

class ShimmerEffectErrorWidget extends StatelessWidget {
  final IconData? iconData;
  final double? iconSize;
  final Color? iconColor;
  final Color? backgroundColor;

  const ShimmerEffectErrorWidget({
    Key? key,
    this.iconData,
    this.iconSize = 80,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.grey[100],
      child: Center(
        child: Icon(
          iconData ?? Icons.image_outlined,
          size: iconSize,
          color: iconColor ?? Colors.grey[300],
        ),
      ),
    );
  }
}
