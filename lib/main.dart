/// The entry point of the Dock application, featuring a gradient background and a centered dock widget.

import 'package:flutter/material.dart';
import 'widgets/dock_item.dart';
import 'widgets/macos_dock.dart';

/// Main function to run the Dock application.
void main() {
  runApp(const MyApp());
}

/// Root widget for the Dock application.
class MyApp extends StatelessWidget {
  /// Creates an instance of `MyApp`.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner.
      home: Scaffold(
        // Provides the main structure for the app.
        body: Container(
          // Background gradient for a smooth color transition from top to bottom.
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 44, 19, 207), // Start color (dark blue).
                Color.fromARGB(255, 103, 125, 181), // End color (lighter blue).
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            // Centers the Dock widget on the screen.
            child: MacOSDock(
              initialItems: [
                DockItem(icon: Icons.person),
                DockItem(icon: Icons.message),
                DockItem(icon: Icons.call),
                DockItem(icon: Icons.camera),
                DockItem(icon: Icons.photo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
