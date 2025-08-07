import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/features/home/widgets/gradient_cta_button.dart';
import 'package:music_app/shared/services/audio_player_service.dart';
import 'package:music_app/shared/services/music_generation_service.dart';
import 'package:music_app/shared/services/auth_service.dart';
import 'package:music_app/shared/models/song.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final MusicGenerationService _musicService = MusicGenerationService();
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  final AuthService _authService = AuthService();
  
  List<Song> _userSongs = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _verifyUserAndLoadLibrary();
  }
  
  @override
  void dispose() {
    // Clean up audio player when leaving library
    _audioPlayer.stop();
    super.dispose();
  }

  Future<void> _verifyUserAndLoadLibrary() async {
    try {
      setState(() => _isLoading = true);
      
      // Get and verify current user ID
      _currentUserId = _authService.currentUserId;
      
      print('🔍 Auth verification:');
      print('   Current User ID: $_currentUserId');
      print('   Is user authenticated: ${_currentUserId != null && _currentUserId!.isNotEmpty}');
      
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        print('❌ No authenticated user found for library');
        setState(() {
          _userSongs = [];
          _isLoading = false;
          _errorMessage = 'No authenticated user';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to access your library'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('📚 Loading library for authenticated user: $_currentUserId');
      
      // Fetch user-specific songs with debugging
      final songs = await _musicService.getUserLibrarySongs();
      
      print('✅ Library loaded:');
      print('   Songs found: ${songs.length}');
      print('   User songs for $_currentUserId:');
      for (var song in songs) {
        print('     - ${song.title} (ID: ${song.id}, User: ${song.userId})');
      }
      
      setState(() {
        _userSongs = songs;
        _isLoading = false;
        _errorMessage = null;
      });
      
    } catch (e) {
      print('❌ Error loading user library: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }



  Future<void> _playSong(Song song) async {
    try {
      if (song.publicUrl.isEmpty) {
        print('❌ No audio URL available for song: ${song.title}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No audio available for this song')),
          );
        }
        return;
      }
      
      print('🎵 Playing user song: ${song.title} with URL: ${song.publicUrl}');
      await _audioPlayer.playTrack(song.id, song.publicUrl);
    } catch (e) {
      print('❌ Error playing song: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play song: $e')),
        );
      }
    }
  }

  Widget _buildLibraryContent() {
    print('🎵 Building library content');
    
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF4AE2)),
            SizedBox(height: 16),
            Text(
              'Loading your library...',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
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
              _errorMessage!,
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
                _verifyUserAndLoadLibrary(); // Retry loading
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4AE2),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_userSongs.isEmpty) {
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
                'Your library is empty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first song\nand it will appear here!',
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
                  // This is already within HomePage, so navigation is handled by parent
                  // Could potentially communicate with parent to switch to Create tab
                },
              ),
            ],
          ),
        ),
      );
    }
    
    // Display user's songs in a grid
    return RefreshIndicator(
      onRefresh: _verifyUserAndLoadLibrary,
      color: const Color(0xFFFF4AE2),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _userSongs.length,
        itemBuilder: (context, index) {
          final song = _userSongs[index];
          
          return StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (context, stateSnapshot) {
              final currentTrackId = _audioPlayer.currentTrackId;
              final isCurrentTrack = currentTrackId == song.id;
              final isPlaying = isCurrentTrack && _audioPlayer.isPlaying;
              
              return GestureDetector(
                onTap: () => _playSong(song),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                    border: isCurrentTrack 
                        ? Border.all(color: const Color(0xFFFF4AE2), width: 2)
                        : Border.all(color: Colors.grey.shade800, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Cover Art Area
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCurrentTrack 
                                  ? [const Color(0xFFFF4AE2), const Color(0xFF7A4BFF)]
                                  : [Colors.grey.shade800, Colors.grey.shade700],
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                              // Play button overlay
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Song Info
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title.isNotEmpty ? song.title : 'Untitled',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Manrope',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (song.style.isNotEmpty)
                              Text(
                                song.style.join(', '),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Manrope',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              song.instrumental ? 'Instrumental' : 'With vocals',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping anywhere on screen
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.6, 1.0],
              colors: [
                Color(0xFF0E1018), // Nightfall start - very top
                Color(0xFF20233B), // Mid-point around 60% down
                Color(0xFF4A2D7C), // Neon end - bottom edge
              ],
            ),
          ),
          child: SafeArea(
            child: _buildLibraryContent(),
          ),
        ),
      ), // Close Scaffold
    ); // Close GestureDetector
  }
}
