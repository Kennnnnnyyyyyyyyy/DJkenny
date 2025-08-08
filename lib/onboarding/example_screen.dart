import 'package:flutter/material.dart';
import '../data/onboarding_track.dart';
import 'onboarding_service.dart';

/// Example screen to demo the onboarding track functionality
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final OnboardingService _service = OnboardingService();
  
  String _selectedMood = 'Happy';
  String _selectedGenre = 'Pop';
  String _selectedTopic = 'My pet';
  
  List<OnboardingTrack> _customTracks = [];
  bool _loadingCustoms = false;

  final List<String> _moods = ['Happy', 'Chill', 'Motivational'];
  final List<String> _genres = ['K-Pop', 'Rap', 'Rock', 'Pop'];
  final List<String> _topics = ['My pet', 'My future self', 'My love'];

  @override
  void initState() {
    super.initState();
    _loadCustomTracks();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadCustomTracks() async {
    setState(() {
      _loadingCustoms = true;
    });

    try {
      final tracks = await _service.loadPage2Customs();
      setState(() {
        _customTracks = tracks;
        _loadingCustoms = false;
      });
    } catch (e) {
      setState(() {
        _loadingCustoms = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading custom tracks: $e')),
        );
      }
    }
  }

  Future<void> _generateAndPlay() async {
    try {
      final track = await _service.playFromChoices(
        moodUI: _selectedMood,
        genreUI: _selectedGenre,
        topicUI: _selectedTopic,
      );

      if (mounted && track != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Now playing: ${track.title}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _playCustomTrack(OnboardingTrack track) async {
    try {
      await _service.playCustom(track);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Now playing: ${track.title}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing track: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding Track Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood selection
            const Text('Mood:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedMood,
              isExpanded: true,
              items: _moods.map((mood) {
                return DropdownMenuItem(value: mood, child: Text(mood));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMood = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Genre selection
            const Text('Genre:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedGenre,
              isExpanded: true,
              items: _genres.map((genre) {
                return DropdownMenuItem(value: genre, child: Text(genre));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGenre = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Topic selection
            const Text('Topic:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedTopic,
              isExpanded: true,
              items: _topics.map((topic) {
                return DropdownMenuItem(value: topic, child: Text(topic));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTopic = value!;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Generate & Play button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateAndPlay,
                child: const Text('Generate & Play'),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Page 2 customs section
            const Text(
              'Page 2 Customs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (_loadingCustoms)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _customTracks.length,
                  itemBuilder: (context, index) {
                    final track = _customTracks[index];
                    return ListTile(
                      title: Text(track.title),
                      subtitle: Text('${track.mood} • ${track.genre} • ${track.topic}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _playCustomTrack(track),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
