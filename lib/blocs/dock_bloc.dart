/// The `DockBloc` class is a BLoC that manages the state of the Dock widget, 
/// specifically handling drag and drop events for items in the dock.
/// It extends the `Bloc` class from flutter_bloc to handle events and emit states.

import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/dock_event.dart';
import '../states/dock_state.dart';
import '../widgets/dock_item.dart';

/// `DockBloc` manages events for drag-and-drop functionality within the dock.
/// It uses `DockEvent` as input events and `DockState` as output states.
class DockBloc extends Bloc<DockEvent, DockState> {
  /// Initializes the `DockBloc` with an initial list of dock items.
  ///
  /// [initialItems] is a list of `DockItem` objects to set as the initial dock state.
  DockBloc(List<DockItem> initialItems)
      : super(DockState(items: initialItems));

  /// Processes incoming `DockEvent`s and yields `DockState`s.
  ///
  /// This method handles four types of events:
  /// - `DragStarted`: Sets the item being dragged and its index.
  /// - `DragUpdated`: Updates the target index where the dragged item will be inserted.
  /// - `DragEnded`: Updates the dock list by moving the dragged item to the target index.
  /// - `ItemDeleted`: Removes a specified item from the dock.
  ///
  /// Yields the updated state after processing each event.
  @override
  Stream<DockState> mapEventToState(DockEvent event) async* {
    if (event is DragStarted) {
      yield state.copyWith(
        draggedItem: event.item,
        draggedItemIndex: event.index,
      );
    } else if (event is DragUpdated) {
      yield state.copyWith(targetIndex: event.targetIndex);
    } else if (event is DragEnded) {
      List<DockItem> updatedItems = List.from(state.items);
      
      // If all required properties are present, update item position
      if (state.draggedItem != null && 
          state.draggedItemIndex != null && 
          state.targetIndex != null) {
        updatedItems.removeAt(state.draggedItemIndex!);
        updatedItems.insert(state.targetIndex!, state.draggedItem!);
      }

      yield state.copyWith(
        items: updatedItems,
        draggedItem: null,
        draggedItemIndex: null,
        targetIndex: null,
      );
    } else if (event is ItemDeleted) {
      List<DockItem> updatedItems = List.from(state.items)..remove(event.item);
      yield state.copyWith(items: updatedItems);
    }
  }
}
