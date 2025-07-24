import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../shared/services/music_generation_service.dart';
import '../../../shared/services/audio_player_service.dart';
import '../../../shared/models/song.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Explore',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 26, 
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
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
      
      // Bottom section with mini player and navigation
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Player
          StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final currentTrackId = _audioPlayer.currentTrackId;
              
              if (currentTrackId == null || !_audioPlayer.isPlaying) {
                return const SizedBox.shrink();
              }

              // Find the current song from our list
              final currentSong = _filteredSongs.isNotEmpty 
                ? _filteredSongs.firstWhere(
                    (song) => song.id == currentTrackId,
                    orElse: () => _allSongs.firstWhere(
                      (song) => song.id == currentTrackId,
                      orElse: () => Song.fromMap({
                        'id': currentTrackId,
                        'title': 'Unknown Song',
                        'public_url': '',
                        'style': '',
                        'instrumental': false,
                        'model': '',
                        'user_id': '',
                      }),
                    ),
                  )
                : Song.fromMap({
                    'id': currentTrackId,
                    'title': 'Unknown Song', 
                    'public_url': '',
                    'style': '',
                    'instrumental': false,
                    'model': '',
                    'user_id': '',
                  });

              return Container(
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
                        child: const Icon(Icons.music_note, color: Colors.white54),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentSong.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (currentSong.style.isNotEmpty)
                            Text(
                              currentSong.style.join(', '),
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _audioPlayer.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        if (_audioPlayer.isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.resume();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop, color: Colors.white54),
                      onPressed: () {
                        _audioPlayer.stop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Bottom Navigation
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
