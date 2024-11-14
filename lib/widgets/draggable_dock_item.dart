import 'package:dock/widgets/dock_icon.dart';
import 'package:flutter/material.dart';
import 'dock_item.dart';

/// A widget that represents a draggable item within a dock-like UI component.
///
/// `DraggableDockItem` can be dragged to a new position within the dock or to a target.
/// It maintains a consistent icon size during drag operations.
class DraggableDockItem extends StatefulWidget {
  final DockItem item;
  final int index;
  final VoidCallback onDragStarted;
  final Function(bool wasAccepted) onDragEnd;
  final Function(DragUpdateDetails) onDragUpdate;

  /// Size of the icon, dynamically set based on the dock width.
  final double iconSize;

  const DraggableDockItem({
    Key? key,
    required this.item,
    required this.index,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onDragUpdate,
    required this.iconSize,
  }) : super(key: key);

  @override
  _DraggableDockItemState createState() => _DraggableDockItemState();
}

class _DraggableDockItemState extends State<DraggableDockItem> {
  bool isDragging = false;
  bool hasCrossedThreshold = false;
  Offset? initialDragPosition;

  final double collapseOffsetThreshold = 100.0; // Adjust as needed

  @override
  Widget build(BuildContext context) {
    return Draggable<DockItem>(
      data: widget.item,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: DockIcon(
        item: widget.item,
        size: widget.iconSize,
      ),
      // Initially keeps the space, collapses only after threshold is crossed
      childWhenDragging: hasCrossedThreshold
          ? const SizedBox.shrink() // Collapse after threshold
          : SizedBox(width: widget.iconSize * 2, height: widget.iconSize), // Keep space
      onDragStarted: () {
        widget.onDragStarted();
        setState(() {
          isDragging = true;
          hasCrossedThreshold = false; // Reset for new drag
          initialDragPosition = null; // Reset initial drag position
        });
      },
      onDragUpdate: (details) {
        initialDragPosition ??= details.globalPosition;

        // Calculate drag distance
        final dragDistance =
            (details.globalPosition - initialDragPosition!).distance;

        // Only set `hasCrossedThreshold` to true if drag exceeds the threshold
        if (!hasCrossedThreshold && dragDistance > collapseOffsetThreshold) {
          setState(() {
            hasCrossedThreshold = true;
          });
        }

        // Notify parent widget about the drag update
        widget.onDragUpdate(details);
      },
      onDragEnd: (details) {
        widget.onDragEnd(details.wasAccepted);
        setState(() {
          isDragging = false;
          hasCrossedThreshold = false; // Reset for next drag
          initialDragPosition = null;
        });
      },
      child: DockIcon(
        item: widget.item,
        size: widget.iconSize,
      ),
    );
  }
}
