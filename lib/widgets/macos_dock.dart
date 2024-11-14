import 'package:dock/widgets/draggable_dock_item.dart';
import 'package:dock/widgets/delete_zone.dart';
import 'package:dock/widgets/dock_item.dart';
import 'package:flutter/material.dart';

/// A widget that simulates a macOS-style dock with draggable icons.
///
/// `MacOSDock` allows users to rearrange icons by dragging and dropping them
/// within the dock, and provides a designated `DeleteZone` for removing items.
class MacOSDock extends StatefulWidget {
  /// Creates a macOS-style dock with draggable and deletable items.
  const MacOSDock({super.key, required List<DockItem> initialItems});

  @override
  _MacOSDockState createState() => _MacOSDockState();
}

class _MacOSDockState extends State<MacOSDock> with TickerProviderStateMixin {
  /// List of items in the dock.
  List<DockItem> items = [
    DockItem(icon: Icons.person),
    DockItem(icon: Icons.message),
    DockItem(icon: Icons.call),
    DockItem(icon: Icons.camera),
    DockItem(icon: Icons.photo),
  ];

  /// The item currently being dragged, if any.
  DockItem? draggedItem;

  /// Flag to indicate if an item has been dragged out of the dock.
  bool hasDraggedOutOfDock = false;

  /// The index of the item currently being dragged, if any.
  int? draggedItemIndex;

  /// The target index where the dragged item will be inserted.
  int? insertionIndex;

  /// Initial drag position, used to calculate the distance moved by the dragged item.
  Offset? initialDragPosition;

  /// Threshold distance for activating icon collapse behavior.
  final double movementThreshold = 20.0;

  @override
  Widget build(BuildContext context) {
    double dockWidth = MediaQuery.of(context).size.width * 0.8;

    List<Widget> dockItems = [];
    for (int i = 0; i <= items.length; i++) {
      // Render placeholder or active target for drag operations
      if (i != draggedItemIndex) {
        dockItems.add(
          DragTarget<DockItem>(
            onWillAccept: (data) {
              if (insertionIndex != i) {
                setState(() {
                  insertionIndex = i;
                });
              }
              return true;
            },
            onLeave: (data) {
              setState(() {
                insertionIndex = null;
              });
            },
            onAccept: (data) {
              setState(() {
                if (draggedItem != null && draggedItemIndex != null) {
                  items.removeAt(draggedItemIndex!);
                  int newIndex = i;
                  if (i > draggedItemIndex!) {
                    newIndex = i - 1;
                  }
                  items.insert(newIndex, draggedItem!);
                }
                draggedItem = null;
                draggedItemIndex = null;
                insertionIndex = null;
              });
            },
            builder: (context, candidateData, rejectedData) {
              bool isActive = candidateData.isNotEmpty && insertionIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 70 : 64,
                height: isActive ? 70 : 64,
                alignment: Alignment.center,
                child: isActive && draggedItem != null
                    ? const SizedBox.shrink()
                    : const SizedBox(width: 50, height: 50),
              );
            },
          ),
        );
      }

      // Render draggable dock items
      if (i < items.length) {
        DockItem item = items[i];
        dockItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: MouseRegion(
              key: ValueKey(item),
              onEnter: (_) {
                if (draggedItem == null) return;
                setState(() {
                  insertionIndex = i;
                });
              },
              onExit: (_) {
                if (draggedItem == null) return;
                setState(() {
                  insertionIndex = null;
                });
              },
              child: DraggableDockItem(
                item: item,
                index: i,
                onDragStarted: () {
                  setState(() {
                    draggedItem = item;
                    draggedItemIndex = i;
                    initialDragPosition = null;
                    hasDraggedOutOfDock = false; // Reset flag
                  });
                },
                onDragEnd: (wasAccepted) {
                  setState(() {
                    draggedItem = null;
                    draggedItemIndex = null;
                    insertionIndex = null;
                    initialDragPosition = null;
                    hasDraggedOutOfDock = false; // Reset flag
                  });
                },
                onDragUpdate: (details) {
                  setState(() {
                    initialDragPosition ??= details.globalPosition;
                    final dragDistance =
                        (details.globalPosition - initialDragPosition!)
                            .distance;
                    if (dragDistance > movementThreshold) {
                      hasDraggedOutOfDock = true;
                    }
                  });
                },
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DeleteZone(
                  dockWidth: dockWidth,
                  onAccept: (data) => setState(() => items.remove(data)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    width: dockWidth,
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dockItems,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Calculates the offset for each item to create a collapsing effect based on drag distance.
  ///
  /// Only applies an offset if the `movementThreshold` is exceeded. The offset minimizes
  /// icons around the dragged icon, creating a visual effect of movement.
  Offset _calculateOffset(int index) {
    if (draggedItemIndex == null ||
        insertionIndex == null ||
        initialDragPosition == null) {
      return Offset.zero;
    }

    // Calculate drag distance and apply offset only if threshold exceeded
    final dragDistance = (initialDragPosition! - Offset.zero).distance;

    if (dragDistance > movementThreshold) {
      const double minimizedOffset = 0.3;

      if (draggedItemIndex! < insertionIndex!) {
        if (index > draggedItemIndex! && index < insertionIndex!) {
          return const Offset(-minimizedOffset, 0.0);
        }
      } else if (draggedItemIndex! > insertionIndex!) {
        if (index >= insertionIndex! && index < draggedItemIndex!) {
          return const Offset(minimizedOffset, 0.0);
        }
      }
    }
    return Offset.zero;
  }
}
