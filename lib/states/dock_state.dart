/// The `DockState` class represents the state of the Dock widget,
/// including the list of dock items, details of the item being dragged,
/// its original index, and the target index for dropping.

import 'package:equatable/equatable.dart';
import '../widgets/dock_item.dart';

/// The `DockState` class is used to manage the state properties of the Dock widget,
/// which include a list of items and details related to drag-and-drop operations.
class DockState extends Equatable {
  /// A list of items currently displayed in the dock.
  final List<DockItem> items;

  /// The item currently being dragged, if any. Null if no item is being dragged.
  final DockItem? draggedItem;

  /// The index of the item being dragged within the `items` list.
  /// Null if no item is being dragged.
  final int? draggedItemIndex;

  /// The target index where the dragged item will be dropped.
  /// Null if no target is currently set.
  final int? targetIndex;

  /// Creates a new `DockState` instance with the specified properties.
  ///
  /// [items] is required and should contain the current list of dock items.
  /// [draggedItem], [draggedItemIndex], and [targetIndex] are optional and are
  /// used to manage drag-and-drop operations.
  const DockState({
    required this.items,
    this.draggedItem,
    this.draggedItemIndex,
    this.targetIndex,
  });

  /// Returns a copy of the current state with updated properties.
  ///
  /// If any of the parameters are not provided, the corresponding property
  /// from the current state is used instead.
  ///
  /// This method is useful for producing new instances with modified values
  /// without altering the original state.
  DockState copyWith({
    List<DockItem>? items,
    DockItem? draggedItem,
    int? draggedItemIndex,
    int? targetIndex,
  }) {
    return DockState(
      items: items ?? this.items,
      draggedItem: draggedItem ?? this.draggedItem,
      draggedItemIndex: draggedItemIndex ?? this.draggedItemIndex,
      targetIndex: targetIndex ?? this.targetIndex,
    );
  }

  /// Overrides the equality operator using Equatable, enabling easy comparison
  /// of DockState instances, particularly useful in BLoC pattern.
  ///
  /// The `props` list contains all properties that Equatable uses to
  /// compare instances.
  @override
  List<Object?> get props => [items, draggedItem, draggedItemIndex, targetIndex];
}
