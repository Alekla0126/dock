import 'package:flutter/material.dart';

/// A model class representing an item in the dock.
///
/// Each `DockItem` contains an icon that will be displayed within a
/// dock or dock-like UI component.
class DockItem {
  /// The icon to display for this dock item.
  ///
  /// This icon is of type [IconData], and it determines the visual
  /// representation of the dock item.
  final IconData icon;

  /// Creates a [DockItem] with the given [icon].
  ///
  /// The [icon] parameter is required and cannot be null.
  DockItem({required this.icon});
}
