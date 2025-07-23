import 'package:flutter/material.dart';
import '../../home/widgets/gradient_cta_button.dart';
import '../../../shared/widgets/track_card.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/services/music_generation_service.dart';
import '../../../shared/models/song.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final MusicGenerationService _musicService = MusicGenerationService();
  bool _useStream = true;
  
  @override
  void dispose() {
    // Clean up audio player when leaving library
    AudioPlayerService().stop();
    super.dispose();
  }

  Widget _buildLibraryContent() {
    print('🎵 Building library content, useStream: $_useStream');
    
    // For now, let's always use FutureBuilder to avoid stream issues
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _musicService.getUserTracks(),
      builder: (context, snapshot) {
        print('🎵 Library FutureBuilder state: ${snapshot.connectionState}');
        if (snapshot.hasError) {
          print('❌ Library Future Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          print('🎵 Library Future Data: ${snapshot.data?.length} tracks');
        }
        
        return _buildLibraryUI(snapshot);
      },
    );
  }

  Widget _buildLibraryUI(AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Loading library...',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      );
    }
    
    if (snapshot.hasError) {
      print('❌ Library error details: ${snapshot.error}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading library',
              style: TextStyle(color: Colors.white, fontFamily: 'Manrope'),
            ),
            const SizedBox(height: 8),
            Text(
              snapshot.error.toString(),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Manrope',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Rebuild to retry
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final tracks = snapshot.data ?? [];
    
    if (tracks.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.library_music, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'Create your first song\nand it will be displayed here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), 
                  fontSize: 16,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 24),
              GradientCTAButton(
                text: 'Start Creating',
                onTap: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ],
          ),
        ),
      );
    }
    
    // Convert maps to Song objects and create TrackCards
    return GridView.extent(
      maxCrossAxisExtent: 280,
      padding: const EdgeInsets.all(16),
      children: tracks.map((trackData) {
        try {
          final song = Song.fromMap(trackData);
          return TrackCard(song);
        } catch (e) {
          print('❌ Error creating Song from data: $e');
          print('❌ Track data: $trackData');
          return Container(
            padding: EdgeInsets.all(8),
            child: Text(
              'Error loading track',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove default leading behavior
        flexibleSpace: SafeArea(
          child: Stack(
            children: [
              // Centered title based on full screen width
              const Center(
                child: Text(
                  'Library',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 32, 
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              // Pro button positioned on the right
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/qonversion');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/white_m.png',
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildLibraryContent(),
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
