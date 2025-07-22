import 'package:flutter/material.dart';
import '../../../shared/services/realtime.dart';
import '../../../shared/widgets/track_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Explore',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search songs or artists',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey.shade900,
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: explore.isEmpty 
              ? const Center(
                  child: Text(
                    'No songs yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: explore.length,
                  itemBuilder: (context, index) {
                    final song = explore[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      child: TrackCard(song),
                    );
                  },
                ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (explore.isNotEmpty)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey.shade800,
                      child: Icon(Icons.music_note, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          explore[0].title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Playing Now',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushNamed(context, '/home');
              } else if (index == 1) {
                // Already on Explore
              } else if (index == 2) {
                Navigator.pushNamed(context, '/library');
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Create"),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
              BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
            ],
          ),
        ],
      ),
    );
  }
}
