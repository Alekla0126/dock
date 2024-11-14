import 'package:flutter/material.dart';
import 'dock_item.dart';

/// A widget that represents an icon within the dock.
///
/// The `DockIcon` widget displays a single icon with customizable hover and
/// drag effects. It optionally supports a scaling animation to enhance the
/// visual effect when the item is dragged or hovered over.
class DockIcon extends StatelessWidget {
  /// The [DockItem] instance containing the icon data to be displayed.
  final DockItem item;

  /// Indicates whether the icon is currently being hovered over.
  ///
  /// When `true`, the icon size increases to visually indicate a hover effect.
  final bool isHovered;

  /// Indicates whether the icon is currently being dragged.
  ///
  /// When `true`, it helps to alter the appearance or size of the icon
  /// to provide feedback during the drag operation.
  final bool isDragging;

  /// An optional animation that scales the icon.
  ///
  /// If provided, the icon will use this scale animation to smoothly
  /// transition its size, creating a zoom effect.
  final Animation<double>? scaleAnimation;

  /// Creates a [DockIcon] widget.
  ///
  /// The [item] parameter is required and provides the icon data. The
  /// [isHovered] and [isDragging] parameters are optional and default to `false`.
  /// The [scaleAnimation] parameter can be provided for an additional scaling effect.
  const DockIcon({
    Key? key,
    required this.item,
    this.isHovered = false,
    this.isDragging = false,
    this.scaleAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adjust the icon size based on hover state
    final double size = isHovered ? 80 : 64;

    Widget iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.primaries[item.icon.hashCode % Colors.primaries.length],
        shape: BoxShape.rectangle, // Change shape to rectangle
        borderRadius: BorderRadius.circular(12), // Adjust the corner radius
      ),
      child: Icon(item.icon, color: Colors.white, size: 32),
    );

    // Wrap with ScaleTransition if scaleAnimation is provided
    if (scaleAnimation != null) {
      iconWidget = ScaleTransition(
        scale: scaleAnimation!,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
