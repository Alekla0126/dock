import 'package:dock/widgets/draggable_dock_item.dart';
import 'package:dock/widgets/delete_zone.dart';
import 'package:dock/widgets/dock_item.dart';
import 'package:flutter/material.dart';

/// A widget that simulates a macOS-style dock with draggable icons.
class MacOSDock extends StatefulWidget {
  /// Creates a macOS-style dock with draggable and deletable items.
  const MacOSDock({super.key, required List<DockItem> initialItems});

  @override
  _MacOSDockState createState() => _MacOSDockState();
}

class _MacOSDockState extends State<MacOSDock> with TickerProviderStateMixin {
  List<DockItem> items = [
    DockItem(icon: Icons.person),
    DockItem(icon: Icons.message),
    DockItem(icon: Icons.call),
    DockItem(icon: Icons.camera),
    DockItem(icon: Icons.photo),
  ];

  DockItem? draggedItem;
  bool hasDraggedOutOfDock = false;
  int? draggedItemIndex;
  int? insertionIndex;
  Offset? initialDragPosition;
  final double movementThreshold = 20.0;

  @override
  Widget build(BuildContext context) {
    // Calculate dock and icon sizes based on screen width
    double dockWidth = MediaQuery.of(context).size.width * 0.8;
    double iconSize = dockWidth * 0.07; // Reduce to 7% of dock width for smaller icons

    List<Widget> dockItems = [];
    for (int i = 0; i <= items.length; i++) {
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
              bool shouldExpand = isActive && i != draggedItemIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: shouldExpand ? iconSize * 3 : iconSize,
                height: shouldExpand ? iconSize * 3 : iconSize,
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
            padding: EdgeInsets.symmetric(horizontal: iconSize * 0.1),
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
                    hasDraggedOutOfDock = false;
                  });
                },
                onDragEnd: (wasAccepted) {
                  setState(() {
                    draggedItem = null;
                    draggedItemIndex = null;
                    insertionIndex = null;
                    initialDragPosition = null;
                    hasDraggedOutOfDock = false;
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
                iconSize: iconSize, // Use the smaller icon size here
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
                    height: iconSize * 1.5,
                    child: Center( // Add Center widget to center the entire dock row
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the icons
                          children: dockItems,
                        ),
                      ),
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

  Offset _calculateOffset(int index) {
    if (draggedItemIndex == null ||
        insertionIndex == null ||
        initialDragPosition == null) {
      return Offset.zero;
    }

    final dragDistance = (initialDragPosition! - Offset.zero).distance;

    if (dragDistance > movementThreshold) {
      const double minimizedOffset = 0.5;

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
