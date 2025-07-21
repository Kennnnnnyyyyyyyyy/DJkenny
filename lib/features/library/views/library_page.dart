import 'package:flutter/material.dart';
import '../../home/widgets/gradient_cta_button.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Library',
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/qonversion');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.music_note, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(Icons.library_music, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Create your first song\nand it will be displayed here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GradientCTAButton(
                    text: 'Start Creating',
                    onTap: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/explore');
          } else if (index == 2) {
            // Already on Library
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Create"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
        ],
      ),
    );
  }
}
