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

  int? hoveredIndex; // Track the index of the hovered item for zoom effect

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          DockItem item = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DragTarget<int>(
              onAcceptWithDetails: (details) {
                _reorderItems(details.data, index);
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: MouseRegion(
                    key: ValueKey(item),
                    onEnter: (_) => setState(() => hoveredIndex = index),
                    onExit: (_) => setState(() => hoveredIndex = null),
                    child: DraggableDockItem(
                      item: item,
                      onDelete: () {
                        setState(() {
                          items.remove(item);
                        });
                      },
                      index: index,
                      isHovered: hoveredIndex == index,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DockItem {
  final IconData icon;

  DockItem({required this.icon});
}

class DraggableDockItem extends StatefulWidget {
  final DockItem item;
  final VoidCallback onDelete;
  final int index;
  final bool isHovered;

  const DraggableDockItem(
      {super.key, required this.item,
      required this.onDelete,
      required this.index,
      required this.isHovered});

  @override
  _DraggableDockItemState createState() => _DraggableDockItemState();
}

class _DraggableDockItemState extends State<DraggableDockItem> {
  Offset offset = Offset.zero;
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: widget.index,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.translate(
          offset: offset,
          child: buildDockIcon(),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: SizedBox(
          width: 64,
          height: 64,
          child: buildDockIcon(),
        ),
      ),
      onDragEnd: (details) {
        if (offset.dy < -100) {
          widget.onDelete();
        }
        setState(() {
          offset = Offset.zero;
          isDragging = false;
        });
      },
      onDragStarted: () {
        setState(() {
          isDragging = true;
        });
      },
      onDragUpdate: (details) {
        setState(() {
          offset += details.delta;
        });
      },
      child: Transform.translate(
        offset: offset,
        child: buildDockIcon(),
      ),
    );
  }

  Widget buildDockIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: (isDragging || widget.isHovered)
          ? 80
          : 64, // Enlarge when dragging or hovered
      height: (isDragging || widget.isHovered) ? 80 : 64,
      decoration: BoxDecoration(
        color: Colors
            .primaries[widget.item.icon.hashCode % Colors.primaries.length],
        shape: BoxShape.circle,
      ),
      child: Icon(widget.item.icon, color: Colors.white, size: 32),
    );
  }
}
