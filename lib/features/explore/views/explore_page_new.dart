import 'package:flutter/material.dart';

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

// Sample Data
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF101933), // Dark blue
              Color(0xFF063F3F), // Dark teal
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: _SearchBar(controller: _searchController),
              ),
            ),

            // Playlists for you
            SliverToBoxAdapter(
              child: _SectionHeader(title: "Playlists for you"),
            ),
            SliverToBoxAdapter(
              child: _HorizontalPlaylists(playlists: kSamplePlaylists),
            ),

            // New releases
            SliverToBoxAdapter(
              child: _SectionHeader(title: "New releases"),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _SongRow(song: kSampleNewReleases[index]),
                childCount: kSampleNewReleases.length,
              ),
            ),

            // Summer Love Song Contest Winners
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _ContestCard(),
              ),
            ),

            // Best of Melo Song Contests
            SliverToBoxAdapter(
              child: _SectionHeader(title: "Best of Melo Song Contests"),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 6,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage("https://picsum.photos/160/160?random=${30 + index}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Moods & Genres
            SliverToBoxAdapter(
              child: _SectionHeader(title: "Moods & Genres"),
            ),
            _GenresGrid(),

            // Popular Weekly
            SliverToBoxAdapter(
              child: _SectionHeader(title: "Popular Weekly"),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ChartRow(song: kSamplePopularWeekly[index]),
                childCount: kSamplePopularWeekly.length,
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
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
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
          print("Search query: $query");
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

// Horizontal Playlists Widget
class _HorizontalPlaylists extends StatelessWidget {
  final List<Playlist> playlists;

  const _HorizontalPlaylists({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: playlists.length,
        itemBuilder: (context, index) => _PlaylistCard(playlist: playlists[index]),
      ),
    );
  }
}

// Playlist Card Widget
class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Open playlist
        print("Open playlist: ${playlist.title}");
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(playlist.artwork),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                        Text(
                          "${playlist.trackCount}",
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              playlist.title,
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

// Song Row Widget
class _SongRow extends StatelessWidget {
  final Song song;

  const _SongRow({required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Play song
        print("Play song: ${song.title}");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(song.artwork),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
            IconButton(
              onPressed: () {
                // TODO: Show context menu
                print("Show context menu for: ${song.title}");
              },
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white70,
              ),
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
        print("Play song: ${song.title}");
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(song.artwork),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
        border: Border.all(color: Colors.pink.withOpacity(0.3)),
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: NetworkImage("https://picsum.photos/32/32?random=${101 + index}"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Winner Song ${index + 1}",
                    style: const TextStyle(
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
                    print("Play contest playlist");
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
                    print("Add contest playlist");
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
          border: Border.all(color: Colors.white.withOpacity(0.2)),
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
              print("Selected genre: ${genres[index]}");
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
