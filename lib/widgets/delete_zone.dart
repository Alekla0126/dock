import 'package:flutter/material.dart';
import 'dock_item.dart';

/// A widget that represents a drop zone for deleting dragged items.
///
/// The `DeleteZone` widget uses a [DragTarget] to detect when a [DockItem]
/// is dragged over it and provides visual feedback to guide the user. When
/// an item is dropped into this zone, the `onAccept` callback is triggered,
/// allowing the parent widget to handle the deletion of the item.
class DeleteZone extends StatelessWidget {
  /// The width of the delete zone, typically matching the width of the dock.
  final double dockWidth;

  /// A callback function that is invoked when a [DockItem] is accepted (dropped).
  ///
  /// This function should handle the deletion logic of the accepted [DockItem].
  final Function(DockItem data) onAccept;

  /// Creates a [DeleteZone] widget.
  ///
  /// The [dockWidth] and [onAccept] parameters are required.
  const DeleteZone({Key? key, required this.dockWidth, required this.onAccept})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<DockItem>(
      // Determines if the drag item can be accepted.
      onWillAccept: (data) => true,
      
      // Invokes the onAccept callback when an item is dropped.
      onAccept: (data) => onAccept(data),
      
      // Builds the visual representation of the delete zone.
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 80,
          width: dockWidth,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Drag here to delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
