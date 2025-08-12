// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:music_app/services/explore_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/data/repo/music_repo.dart';
import 'package:music_app/data/models/song.dart' as models;

// Data Models
class Playlist {
  final String title;
  final int trackCount;
  final String artwork; // Asset path or URL

  const Playlist({
    required this.title,
    required this.trackCount,
    required this.artwork,
  });
}

class Song {
  final String title;
  final String artist;
  final String artwork;
  final int playCount;
  final int likeCount;
  final int? rank; // For charts

  const Song({
    required this.title,
    required this.artist,
    required this.artwork,
    required this.playCount,
    required this.likeCount,
    this.rank,
  });
}

// Sample Data (kept for fallback/local demos)
const List<Playlist> kSamplePlaylists = [
  Playlist(title: "Chill Vibes", trackCount: 24, artwork: "https://picsum.photos/160/160?random=1"),
  Playlist(title: "Workout Mix", trackCount: 18, artwork: "https://picsum.photos/160/160?random=2"),
  Playlist(title: "Study Focus", trackCount: 32, artwork: "https://picsum.photos/160/160?random=3"),
  Playlist(title: "Party Hits", trackCount: 45, artwork: "https://picsum.photos/160/160?random=4"),
];

const List<Song> kSampleNewReleases = [
  Song(title: "Midnight Dreams", artist: "@beatmaker", artwork: "https://picsum.photos/60/60?random=11", playCount: 15420, likeCount: 892),
  Song(title: "Electric Nights", artist: "@synthwave", artwork: "https://picsum.photos/60/60?random=12", playCount: 8750, likeCount: 456),
  Song(title: "Ocean Waves", artist: "@chill_artist", artwork: "https://picsum.photos/60/60?random=13", playCount: 23100, likeCount: 1205),
  Song(title: "Urban Flow", artist: "@hiphop_king", artwork: "https://picsum.photos/60/60?random=14", playCount: 19800, likeCount: 987),
];

const List<Song> kSamplePopularWeekly = [
  Song(title: "Summer Anthem", artist: "@popstar", artwork: "https://picsum.photos/60/60?random=21", playCount: 125000, likeCount: 8500, rank: 1),
  Song(title: "Neon Lights", artist: "@electronic_duo", artwork: "https://picsum.photos/60/60?random=22", playCount: 98000, likeCount: 6200, rank: 2),
  Song(title: "Heartbeat", artist: "@indie_band", artwork: "https://picsum.photos/60/60?random=23", playCount: 87500, likeCount: 5800, rank: 3),
  Song(title: "Galaxy", artist: "@space_sounds", artwork: "https://picsum.photos/60/60?random=24", playCount: 76000, likeCount: 4900, rank: 4),
  Song(title: "Thunder", artist: "@rock_legends", artwork: "https://picsum.photos/60/60?random=25", playCount: 65000, likeCount: 4100, rank: 5),
];

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final ExploreService _svc = ExploreService();
  final MusicRepo _repo = MusicRepo(Supabase.instance.client);
  late Future<List<ExploreCover>> _coversFut;
  late Future<List<models.Song>> _songsFut;

  @override
  void initState() {
    super.initState();
    _coversFut = _svc.fetchOnboardingCovers();
    _songsFut = _repo.fetchExploreSongs(limit: 30);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              onPressed: _runBackfill,
              child: const Icon(Icons.auto_awesome),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.6, 1.0],
            colors: [
              Color(0xFF0E1018),
              Color(0xFF20233B),
              Color(0xFF4A2D7C),
            ],
          ),
        ),
        child: FutureBuilder<List<ExploreCover>>(
          future: _coversFut,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to load covers', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _coversFut = _svc.fetchOnboardingCovers()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final covers = snap.data ?? const <ExploreCover>[];
            final playlists = covers.take(12).toList(growable: false);

            return FutureBuilder<List<models.Song>>(
              future: _songsFut,
              builder: (context, songsSnap) {
                final songs = songsSnap.data ?? const <models.Song>[];
                final newReleases = songs.take(10).toList(growable: false);
                final popular = songs.skip(10).take(10).toList(growable: false);

                return CustomScrollView(
                  slivers: [
                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: _SearchBar(controller: _searchController),
                      ),
                    ),

                    // Playlists for you (from onboarding covers)
                    SliverToBoxAdapter(child: _SectionHeader(title: "Playlists for you")),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                            final item = playlists[index];
                            return _PlaylistCard(
                              title: item.title,
                              artworkUrl: item.coverUrl,
                              trackCount: null,
                              onTap: () {},
                            );
                          },
                        ),
                      ),
                    ),

                    // New releases (songs table)
                    SliverToBoxAdapter(child: _SectionHeader(title: "New releases")),
                    if (songsSnap.connectionState != ConnectionState.done)
                      const SliverToBoxAdapter(
                        child: Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        )),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = newReleases[index];
                            return _SongRowNetwork(
                              title: item.title ?? 'Untitled',
                              subtitle: '',
                              artworkUrl: item.coverUrl,
                              onTap: () {},
                            );
                          },
                          childCount: newReleases.length,
                        ),
                      ),

                    // Moods & Genres
                    SliverToBoxAdapter(child: _SectionHeader(title: "Moods & Genres")),
                    _GenresGrid(),

                    // Popular Weekly (more from songs)
                    SliverToBoxAdapter(child: _SectionHeader(title: "Popular Weekly")),
                    if (songsSnap.connectionState != ConnectionState.done)
                      const SliverToBoxAdapter(child: SizedBox(height: 60))
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = popular[index];
                            return _SongRowNetwork(
                              title: item.title ?? 'Untitled',
                              subtitle: '',
                              artworkUrl: item.coverUrl,
                              onTap: () {},
                            );
                          },
                          childCount: popular.length,
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _runBackfill() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backfilling missing covers...')),
    );
    try {
      final count = await _repo.backfillSongCovers(limit: 50);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Requested $count cover generations')),
      );
      setState(() {
        _songsFut = _repo.fetchExploreSongs(limit: 30);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backfill failed: $e')),
      );
    }
  }
}

// Helper: album art with gradient fallback and caching
Widget songArt(String? coverUrl, {double size = 60, double radius = 12}) {
  if (coverUrl == null || coverUrl.isEmpty) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF23283B), Color(0xFF0F2233)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: CachedNetworkImage(
      imageUrl: coverUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (c, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF23283B), Color(0xFF0F2233)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      errorWidget: (c, _, __) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0F2233),
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.music_note, color: Colors.white54),
      ),
    ),
  );
}

// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Search song, username, playlist, style",
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white70),
        ),
        onSubmitted: (query) {
          // TODO: Handle search query
          debugPrint("Search query: $query");
        },
      ),
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}

// Playlist Card Widget
class _PlaylistCard extends StatelessWidget {
  final String title;
  final String? artworkUrl;
  final int? trackCount;
  final VoidCallback? onTap;
  const _PlaylistCard({required this.title, required this.artworkUrl, this.trackCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(width: 160, height: 160, child: songArt(artworkUrl, size: 160, radius: 20)),
                if (trackCount != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.music_note, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text("$trackCount", style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Song Row Widget (Network Images)
class _SongRowNetwork extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? artworkUrl;
  final VoidCallback? onTap;
  const _SongRowNetwork({required this.title, required this.subtitle, required this.artworkUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            songArt(artworkUrl, size: 60, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// Chart Row Widget (with rank number)
class _ChartRow extends StatelessWidget {
  final Song song;

  const _ChartRow({required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Play song
        debugPrint("Play song: ${song.title}");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: Text(
                "${song.rank}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            songArt(song.artwork, size: 60, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MiniIconText(
                        icon: Icons.play_arrow,
                        text: "${song.playCount}",
                      ),
                      const SizedBox(width: 16),
                      _MiniIconText(
                        icon: Icons.favorite,
                        text: "${song.likeCount}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mini Icon Text Widget
class _MiniIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// Contest Card Widget
class _ContestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage("https://picsum.photos/40/40?random=100"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Summer Love Song Contest Winners",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Three child song rows
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                songArt("https://picsum.photos/32/32?random=${101 + index}", size: 32, radius: 4),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Winner Song",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CircleButton(
                  icon: Icons.play_arrow,
                  label: "Play",
                  onTap: () {
                    // TODO: Play playlist
                    debugPrint("Play contest playlist");
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CircleButton(
                  icon: Icons.add,
                  label: "Add",
                  onTap: () {
                    // TODO: Add playlist
                    debugPrint("Add contest playlist");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Circle Button Widget
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Genres Grid Widget
class _GenresGrid extends StatelessWidget {
  final List<String> genres = [
    "Rap", "Pop", "Rock", "Metal", "Country",
    "Hip-hop", "Funk", "R&B", "Blues", "Jazz"
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => GestureDetector(
            onTap: () {
              // TODO: Navigate to genre
              debugPrint("Selected genre: ${genres[index]}");
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.cyan, Colors.purple],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  color: const Color(0xFF101933),
                ),
                alignment: Alignment.center,
                child: Text(
                  genres[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          childCount: genres.length,
        ),
      ),
    );
  }
}
