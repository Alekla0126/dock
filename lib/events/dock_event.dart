/// Defines events related to drag-and-drop operations in the Dock widget,
/// including initiating, updating, and ending a drag, as well as deleting an item.

import 'package:dock/widgets/dock_item.dart';
import 'package:equatable/equatable.dart';

/// The base class for all events related to the Dock widget.
abstract class DockEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// Event triggered when a drag operation starts on an item.
///
/// Contains the [item] being dragged and its current [index] in the dock.
class DragStarted extends DockEvent {
  /// The item that is being dragged.
  final DockItem item;

  /// The original index of the dragged item in the dock.
  final int index;

  /// Creates a `DragStarted` event with the given [item] and [index].
  DragStarted(this.item, this.index);

  @override
  List<Object> get props => [item, index];
}

/// Event triggered when the target position of the dragged item is updated.
///
/// Contains the [targetIndex] where the dragged item should move.
class DragUpdated extends DockEvent {
  /// The target index where the dragged item is intended to move.
  final int targetIndex;

  /// Creates a `DragUpdated` event with the specified [targetIndex].
  DragUpdated(this.targetIndex);

  @override
  List<Object> get props => [targetIndex];
}

/// Event triggered when a drag operation ends.
///
/// [wasAccepted] indicates if the item was successfully placed in a new position.
class DragEnded extends DockEvent {
  /// A boolean indicating whether the drag operation was accepted or canceled.
  final bool wasAccepted;

  /// Creates a `DragEnded` event with the specified [wasAccepted] flag.
  DragEnded(this.wasAccepted);

  @override
  List<Object> get props => [wasAccepted];
}

/// Event triggered when an item is deleted from the dock.
///
/// Contains the [item] to be removed.
class ItemDeleted extends DockEvent {
  /// The item to be deleted from the dock.
  final DockItem item;

  /// Creates an `ItemDeleted` event with the specified [item].
  ItemDeleted(this.item);

  @override
  List<Object> get props => [item];
}
