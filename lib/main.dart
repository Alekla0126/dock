import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: MacOSDock(),
        ),
      ),
    );
  }
}

class MacOSDock extends StatefulWidget {
  const MacOSDock({super.key});

  @override
  _MacOSDockState createState() => _MacOSDockState();
}

class _MacOSDockState extends State<MacOSDock> {
  List<DockItem> items = [
    DockItem(icon: Icons.person),
    DockItem(icon: Icons.message),
    DockItem(icon: Icons.call),
    DockItem(icon: Icons.camera),
    DockItem(icon: Icons.photo),
  ];

  DockItem? draggedItem;
  int? draggedItemIndex;
  int? insertionIndex;

  @override
  Widget build(BuildContext context) {
    double dockWidth = MediaQuery.of(context).size.width * 0.8;

    List<Widget> dockItems = [];
    for (int i = 0; i <= items.length; i++) {
      // Only add the DragTarget if it's a different position
      if (i != draggedItemIndex) {
        dockItems.add(
          DragTarget<DockItem>(
            onWillAccept: (data) {
              if (insertionIndex != i) {
                // Only update if the index has changed
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
            builder: (context, List<DockItem?> candidateData, rejectedData) {
              bool isActive = candidateData.isNotEmpty && insertionIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 80 : 64,
                height: isActive ? 80 : 64,
                alignment: Alignment.center,
                child: isActive && draggedItem != null
                    ? DockIcon(
                        item: draggedItem!,
                        isHovered: false,
                        isDragging: false,
                      )
                    : const SizedBox(
                        width: 64,
                        height: 64,
                      ),
              );
            },
          ),
        );
      }

      if (i < items.length) {
        DockItem item = items[i];
        dockItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                  });
                },
                onDragEnd: (wasAccepted) {
                  setState(() {
                    draggedItem = null;
                    draggedItemIndex = null;
                    insertionIndex = null;
                  });
                },
              ),
            ),
          ),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Delete zone" adjusted to match the dock's width
        DragTarget<DockItem>(
          onWillAccept: (data) => true,
          onAccept: (data) {
            setState(() {
              items.remove(data);
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              height: 80,
              width: dockWidth,
              decoration: BoxDecoration(
                color: Colors.transparent, // Transparent background
                border:
                    Border.all(color: Colors.white, width: 2), // White border
                borderRadius:
                    BorderRadius.circular(8), // Rounded corners if desired
              ),
              child: const Center(
                child: Text(
                  'Drag here to delete',
                  style: TextStyle(color: Colors.white), // White text
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
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
    );
  }
}

class DockItem {
  final IconData icon;

  DockItem({required this.icon});
}

class DockIcon extends StatelessWidget {
  final DockItem item;
  final bool isHovered;
  final bool isDragging;

  const DockIcon({
    Key? key,
    required this.item,
    this.isHovered = false,
    this.isDragging = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: (isDragging || isHovered) ? 80 : 64,
      height: (isDragging || isHovered) ? 80 : 64,
      decoration: BoxDecoration(
        color: Colors.primaries[item.icon.hashCode % Colors.primaries.length],
        shape: BoxShape.circle,
      ),
      child: Icon(item.icon, color: Colors.white, size: 32),
    );
  }
}

class DraggableDockItem extends StatefulWidget {
  final DockItem item;
  final int index;
  final VoidCallback onDragStarted;
  final Function(bool wasAccepted) onDragEnd;

  const DraggableDockItem({
    Key? key,
    required this.item,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.index,
  }) : super(key: key);

  @override
  _DraggableDockItemState createState() => _DraggableDockItemState();
}

class _DraggableDockItemState extends State<DraggableDockItem> {
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Draggable<DockItem>(
      data: widget.item,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: DockIcon(
            item: widget.item,
            isHovered: false,
            isDragging: true,
          ),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        widget.onDragStarted();
        setState(() {
          isDragging = true;
        });
      },
      onDragEnd: (details) {
        widget.onDragEnd(details.wasAccepted);
        setState(() {
          isDragging = false;
        });
      },
      child: DockIcon(
        item: widget.item,
        isHovered: isDragging,
        isDragging: isDragging,
      ),
    );
  }
}
