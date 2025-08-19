import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../onboarding/onboarding_service.dart';
import 'package:music_app/ui/widgets/circular_album_player.dart';
import 'package:music_app/router/router_constants.dart';

enum MessageType {
  text,
  choices,
  creating,
  songCreated,
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  final MessageType type;
  final List<String>? choices;
  final GlobalKey key;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.type,
    this.choices,
  }) : key = GlobalKey();
}

class OnboardingPage3 extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingPage3({super.key, required this.onDone});

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> 
    with TickerProviderStateMixin {
  
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final OnboardingService _onboardingService = OnboardingService();
  
  // Mood, genre, subject state
  String? _selectedMood;
  String? _selectedGenre;
  String? _selectedSubject;
  String _currentStep = "mood";
  
  // Song state
  String? _currentSongUrl;
  String? _currentCoverUrl;
  String? _currentTrackTitle;
  
  // Animation controllers
  late AnimationController _discController;
  late AnimationController _waveController;
  late AnimationController _colorController;
  late AnimationController _driftController;
  
  // Visual effects
  bool _showPsychedelicBackground = false;
  
  @override
  void initState() {
    super.initState();
    
    _discController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    _driftController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    );
    
    // Start with mood selection
    _askForMood();
  }
  
  @override
  void dispose() {
    _discController.dispose();
    _waveController.dispose();
    _colorController.dispose();
    _driftController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _askForMood() {
    _addMessage(ChatMessage(
      text: "What's your mood today?",
      isFromUser: false,
      type: MessageType.choices,
      choices: ["Happy", "Sad", "Energetic", "Chill", "Romantic"],
    ));
  }
  
  void _handleChoice(String choice) {
    _addMessage(ChatMessage(
      text: choice,
      isFromUser: true,
      type: MessageType.text,
    ));
    
    if (_currentStep == "mood") {
      _selectedMood = choice;
      _currentStep = "genre";
      _askForGenre();
    } else if (_currentStep == "genre") {
      _selectedGenre = choice;
      _currentStep = "subject";
      _askForSubject();
    } else if (_currentStep == "subject") {
      _selectedSubject = choice;
      _createSong();
    }
  }
  
  void _askForGenre() {
    _addMessage(ChatMessage(
      text: "What genre speaks to you?",
      isFromUser: false,
      type: MessageType.choices,
      choices: ["Pop", "Rock", "Hip-Hop", "Electronic", "Jazz", "Classical"],
    ));
  }
  
  void _askForSubject() {
    _addMessage(ChatMessage(
      text: "What should your song be about?",
      isFromUser: false,
      type: MessageType.choices,
      choices: ["My pet", "My future self", "My love", "Adventure", "Dreams"],
    ));
  }
  
  void _createSong() async {
    print('🎵 Creating song for: mood=$_selectedMood, genre=$_selectedGenre, subject=$_selectedSubject');
    
    try {
      // Map UI choices to database format
      String moodUI = _selectedMood!.toLowerCase();
      String genreUI = _selectedGenre!;
      String topicUI = _selectedSubject!;
      
      // Convert topic back to UI format for the service
      if (topicUI == 'My pet') topicUI = 'my_pet';
      else if (topicUI == 'My future self') topicUI = 'my_future_self'; 
      else if (topicUI == 'My love') topicUI = 'my_love';
      
      // Clear messages and show creating UI
      setState(() {
        _messages.clear();
      });
      
      _addMessage(ChatMessage(
        text: "",
        isFromUser: false,
        type: MessageType.creating,
      ));
      
      // Fetch track details from Supabase
      final track = await _onboardingService.findTrackFromChoices(
         moodUI: moodUI,
         genreUI: genreUI,
         topicUI: topicUI,
       );
      
      if (track != null) {
        print('🎵 Found track: ${track.title} - ${track.publicUrl}');
        _currentSongUrl = track.publicUrl;
        _currentCoverUrl = track.coverUrl;
        _currentTrackTitle = track.title;
        
        // Simulate creation time
        Timer(const Duration(seconds: 8), () {
          if (mounted) {
            setState(() {
              _messages.clear();
            });
            
            _currentStep = "created";
            _discController.repeat();
            
            // Enable psychedelic background
            setState(() {
              _showPsychedelicBackground = true;
            });
            
            // Start psychedelic wave animations
            _waveController.repeat();
            _colorController.repeat();
            _driftController.repeat();
            
            _addMessage(ChatMessage(
              text: "Your song is ready! 🎵",
              isFromUser: false,
              type: MessageType.text,
            ));
            
            Future.delayed(const Duration(milliseconds: 1000), () {
              _addMessage(ChatMessage(
                text: "",
                isFromUser: false,
                type: MessageType.songCreated,
              ));
            });
          }
        });
      }
    } catch (e) {
      print('🚨 Error creating song: $e');
      // Show error message
      setState(() {
        _messages.clear();
      });
      _addMessage(ChatMessage(
        text: "Sorry, couldn't create your song. Please try again!",
        isFromUser: false,
        type: MessageType.text,
      ));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Psychedelic background
          if (_showPsychedelicBackground)
            AnimatedBuilder(
              animation: Listenable.merge([_waveController, _colorController, _driftController]),
              builder: (context, child) {
                return CustomPaint(
                  painter: PsychedelicBackgroundPainter(
                    waveAnimation: _waveController,
                    colorAnimation: _colorController,
                    driftAnimation: _driftController,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Row(
                    children: [
                      Icon(Icons.music_note, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Create Your Song',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chat messages
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessage(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(message);
      case MessageType.choices:
        return _buildChoicesMessage(message);
      case MessageType.creating:
        return _buildCreatingMessage();
      case MessageType.songCreated:
        return _buildSongCreatedMessage();
    }
  }
  
  Widget _buildTextMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isFromUser ? Colors.blue : Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChoicesMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: message.choices!.map((choice) {
              return GestureDetector(
                onTap: () => _handleChoice(choice),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    choice,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreatingMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x30FFFFFF)),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Creating your personalized song...',
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSongCreatedMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (_currentSongUrl != null)
            CircularAlbumPlayer(
              title: _currentTrackTitle ?? 'Your Song',
              subtitle: 'Created just for you',
              audioUrl: _currentSongUrl!,
              coverUrl: _currentCoverUrl ?? '',
              onContinue: () {
                context.goNamed(RouterConstants.onboarding4);
              },
            ),
        ],
      ),
    );
  }
}

class PsychedelicBackgroundPainter extends CustomPainter {
  final AnimationController waveAnimation;
  final AnimationController colorAnimation;
  final AnimationController driftAnimation;

  PsychedelicBackgroundPainter({
    required this.waveAnimation,
    required this.colorAnimation,
    required this.driftAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Create multiple layers of animated waves
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final waveHeight = 50.0 + (i * 20);
      final frequency = 0.02 + (i * 0.005);
      final phase = waveAnimation.value * 2 * pi + (i * pi / 3);
      final drift = driftAnimation.value * 100 * (i + 1);
      
      path.moveTo(0, size.height / 2);
      
      for (double x = 0; x <= size.width; x += 2) {
        final y = size.height / 2 + 
                  sin((x * frequency) + phase) * waveHeight +
                  cos((x * frequency * 1.5) + phase + drift) * (waveHeight * 0.5);
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      // Animated colors
      final colorPhase = colorAnimation.value * 2 * pi + (i * pi / 4);
      final hue = (colorPhase * 180 / pi) % 360;
      final color = HSVColor.fromAHSV(
        0.1 + (i * 0.05), // Alpha
        hue,
        0.8,
        1.0,
      ).toColor();
      
      paint.color = color;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
