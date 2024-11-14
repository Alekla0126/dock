import 'package:flutter/material.dart';
import 'dock_icon.dart';
import 'dock_item.dart';

/// A widget that represents a draggable item within a dock-like UI component.
///
/// `DraggableDockItem` can be dragged to a new position within the dock or to a target.
/// It maintains a consistent icon size during drag operations.
class DraggableDockItem extends StatefulWidget {
  /// The [DockItem] to display within this draggable widget.
  final DockItem item;

  /// The index of this item within the dock.
  final int index;

  /// Callback that triggers when dragging starts.
  final VoidCallback onDragStarted;

  /// Callback that triggers when dragging ends. The [wasAccepted] parameter
  /// indicates whether the item was accepted by a drop target.
  final Function(bool wasAccepted) onDragEnd;

  /// Callback that triggers when the drag is updated.
  final Function(DragUpdateDetails) onDragUpdate;

  /// Creates a [DraggableDockItem] with the given [item], [onDragStarted], [onDragEnd],
  /// [onDragUpdate], and [index].
  const DraggableDockItem({
    Key? key,
    required this.item,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onDragUpdate,
    required this.index,
  }) : super(key: key);

  @override
  _DraggableDockItemState createState() => _DraggableDockItemState();
}

class _DraggableDockItemState extends State<DraggableDockItem> {
  /// Tracks whether the item is currently being dragged.
  bool isDragging = false;

  /// Indicates if the item has exited its original position in the dock.
  bool hasExitedDock = false;

  /// The initial drag position, used to calculate drag distance.
  Offset? initialDragPosition;

  /// The offset threshold in pixels after which the item visually collapses in its position.
  final double collapseOffsetThreshold = 20.0;

  @override
  Widget build(BuildContext context) {
    return Draggable<DockItem>(
      data: widget.item,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: DockIcon(
        item: widget.item,
      ),
      // Keeps the space occupied until the item has exited the dock
      childWhenDragging: hasExitedDock ? const SizedBox.shrink() : null,
      onDragStarted: () {
        widget.onDragStarted();
        setState(() {
          isDragging = true;
          hasExitedDock = false;
          initialDragPosition = null; // Reset the initial drag position
        });
      },
      onDragUpdate: (details) {
        // Sets the initial drag position if it has not been set yet
        initialDragPosition ??= details.globalPosition;

        // Calculates the distance moved from the initial drag position
        final dragDistance =
            (details.globalPosition - initialDragPosition!).distance;

        // Collapses the icon's space only if the drag exceeds the threshold
        if (!hasExitedDock && dragDistance > collapseOffsetThreshold) {
          setState(() {
            hasExitedDock = true;
          });
        }

        // Inform the parent widget about the drag update
        widget.onDragUpdate(details);
      },
      onDragEnd: (details) {
        widget.onDragEnd(details.wasAccepted);
        setState(() {
          isDragging = false;
          hasExitedDock = false;
          initialDragPosition = null; // Reset for the next drag
        });
      },
      child: DockIcon(
        item: widget.item,
      ),
    );
  }
}
