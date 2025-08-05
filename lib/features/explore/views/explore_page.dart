import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/shared/services/music_generation_service.dart';
import 'package:music_app/shared/services/audio_player_service.dart';
import 'package:music_app/shared/models/song.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final MusicGenerationService _musicService = MusicGenerationService();
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExploreSongs();
    
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          // Update UI based on player state
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExploreSongs() async {
    try {
      setState(() => _isLoading = true);
      final songs = await _musicService.getExploreSongs();
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading explore songs: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load explore songs: $e')),
        );
      }
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        _filteredSongs = _allSongs.where((song) =>
            song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.style.any((style) => style.toLowerCase().contains(query.toLowerCase()))
        ).toList();
      }
    });
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
      
      print('🎵 Playing song: ${song.title} with URL: ${song.publicUrl}');
      await _audioPlayer.playTrack(song.id, song.publicUrl);
      print('Music player tap - Explore');
    } catch (e) {
      print('❌ Error playing song: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play song: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping anywhere on screen
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Search songs, styles...',
                hintStyle: const TextStyle(color: Colors.white54, fontFamily: 'Manrope'),
                filled: true,
                fillColor: Colors.grey.shade900,
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _filterSongs('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontFamily: 'Manrope'),
              onChanged: _filterSongs,
            ),
          ),

          // Songs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4AE2)))
                : _filteredSongs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_note_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No explore songs available'
                                  : 'No songs found for "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _filterSongs('');
                                },
                                child: const Text(
                                  'Clear search', 
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadExploreSongs,
                        color: const Color(0xFFFF4AE2),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = _filteredSongs[index];
                            
                            return StreamBuilder<PlayerState>(
                              stream: _audioPlayer.playerStateStream,
                              builder: (context, stateSnapshot) {
                                final currentTrackId = _audioPlayer.currentTrackId;
                                final isCurrentTrack = currentTrackId == song.id;
                                final isPlaying = isCurrentTrack && _audioPlayer.isPlaying;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    color: Colors.grey.shade900,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isPlaying
                                            ? const Color(0xFFFF4AE2)
                                            : Colors.grey[700],
                                        child: Icon(
                                          isPlaying ? Icons.pause : Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        song.title.isNotEmpty ? song.title : 'Untitled',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (song.style.isNotEmpty)
                                            Text(
                                              song.style.join(', '),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontFamily: 'Manrope',
                                              ),
                                            ),
                                          Text(
                                            song.instrumental ? 'Instrumental' : 'With vocals',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                              fontFamily: 'Manrope',
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          isPlaying ? Icons.pause : Icons.play_arrow,
                                          color: const Color(0xFFFF4AE2),
                                        ),
                                        onPressed: () {
                                          if (isPlaying) {
                                            _audioPlayer.pause();
                                          } else {
                                            _playSong(song);
                                          }
                                        },
                                      ),
                                      onTap: () => _playSong(song),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      ), // Close Scaffold
      ), // Close GestureDetector
    );
  }
}
