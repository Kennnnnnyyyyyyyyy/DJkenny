import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  final List<Map<String, String>> songs = [
    {
      'title': 'Neon Dreams',
      'artist': 'Synthwave',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Sad',
      'artist': 'Tv Network',
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Make Me Cry',
      'artist': 'Lofi Beats',
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'I Like It',
      'artist': 'Pop Fusion',
      'image': 'https://images.unsplash.com/photo-1465101178521-c1a4c8a0a8b7?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Happier',
      'artist': 'Chillwave',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'One Kiss',
      'artist': 'ElectroPop',
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': "Don't Start Now",
      'artist': 'Future Bass',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    },
  ];

  ExplorePage({super.key});

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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Song image
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            song['image']!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.white.withOpacity(0.2),
                              child: Icon(Icons.music_note, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // Song info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              song['title']!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              song['artist']!,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // Play and Share buttons (white icons)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                            onPressed: () {},
                            splashRadius: 22,
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white, size: 28),
                            onPressed: () {},
                            splashRadius: 22,
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    songs[0]['image']!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey.shade800,
                      child: Icon(Icons.music_note, color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        songs[0]['title']!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        songs[0]['artist']!,
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
