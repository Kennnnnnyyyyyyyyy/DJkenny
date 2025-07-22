import 'package:flutter/material.dart';
import '../shared/widgets/animated_loading_overlay.dart';

/// Example usage of the AnimatedLoadingOverlay
/// 
/// This demonstrates how to integrate the loading overlay into any screen
class LoadingOverlayExample extends StatefulWidget {
  const LoadingOverlayExample({super.key});

  @override
  State<LoadingOverlayExample> createState() => _LoadingOverlayExampleState();
}

class _LoadingOverlayExampleState extends State<LoadingOverlayExample> {
  bool _isGenerating = false;

  void _startGeneration() {
    setState(() {
      _isGenerating = true;
    });
    
    // Simulate generation process
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎵 Generation complete!')),
        );
      }
    });
  }

  void _stopGeneration() {
    setState(() {
      _isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Loading Overlay Demo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Professional Loading Overlay Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _isGenerating ? null : _startGeneration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3813C2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _isGenerating ? 'Generating...' : 'Start Generation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                if (_isGenerating)
                  ElevatedButton(
                    onPressed: _stopGeneration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                const Text(
                  'Features:\n'
                  '• Rotating logo animation\n'
                  '• Gentle pulsing effect\n'
                  '• Random loading messages\n'
                  '• Semi-transparent overlay\n'
                  '• Professional design\n'
                  '• Responsive layout',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Loading overlay
          AnimatedLoadingOverlay(isVisible: _isGenerating),
        ],
      ),
    );
  }
}
