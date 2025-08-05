import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum MessageType {
  text,
  choices,
  creating,
  songCreated,
  upgrade,
  payment,
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
  final AudioPlayer _player = AudioPlayer();
  late AnimationController _discController;
  late AnimationController _messageAnimationController;
  late AnimationController _particleController;
  
  String _currentStep = "intro";
  String? _selectedMood, _selectedGenre, _selectedSubject;
  String? _currentSongUrl;
  
  // 36-track matrix for all mood-genre-subject combinations
  final Map<String, String> _songMatrix = {
    // Motivational tracks
    'motivational-k-pop-my_pet': 'https://cdn.melo.ai/tracks/motivational_kpop_my_pet.mp3',
    'motivational-k-pop-my_future_self': 'https://cdn.melo.ai/tracks/motivational_kpop_my_future_self.mp3',
    'motivational-k-pop-my_love': 'https://cdn.melo.ai/tracks/motivational_kpop_my_love.mp3',
    'motivational-rap-my_pet': 'https://cdn.melo.ai/tracks/motivational_rap_my_pet.mp3',
    'motivational-rap-my_future_self': 'https://cdn.melo.ai/tracks/motivational_rap_my_future_self.mp3',
    'motivational-rap-my_love': 'https://cdn.melo.ai/tracks/motivational_rap_my_love.mp3',
    'motivational-rock-my_pet': 'https://cdn.melo.ai/tracks/motivational_rock_my_pet.mp3',
    'motivational-rock-my_future_self': 'https://cdn.melo.ai/tracks/motivational_rock_my_future_self.mp3',
    'motivational-rock-my_love': 'https://cdn.melo.ai/tracks/motivational_rock_my_love.mp3',
    'motivational-pop-my_pet': 'https://cdn.melo.ai/tracks/motivational_pop_my_pet.mp3',
    'motivational-pop-my_future_self': 'https://cdn.melo.ai/tracks/motivational_pop_my_future_self.mp3',
    'motivational-pop-my_love': 'https://cdn.melo.ai/tracks/motivational_pop_my_love.mp3',
    
    // Chill tracks
    'chill-k-pop-my_pet': 'https://cdn.melo.ai/tracks/chill_kpop_my_pet.mp3',
    'chill-k-pop-my_future_self': 'https://cdn.melo.ai/tracks/chill_kpop_my_future_self.mp3',
    'chill-k-pop-my_love': 'https://cdn.melo.ai/tracks/chill_kpop_my_love.mp3',
    'chill-rap-my_pet': 'https://cdn.melo.ai/tracks/chill_rap_my_pet.mp3',
    'chill-rap-my_future_self': 'https://cdn.melo.ai/tracks/chill_rap_my_future_self.mp3',
    'chill-rap-my_love': 'https://cdn.melo.ai/tracks/chill_rap_my_love.mp3',
    'chill-rock-my_pet': 'https://cdn.melo.ai/tracks/chill_rock_my_pet.mp3',
    'chill-rock-my_future_self': 'https://cdn.melo.ai/tracks/chill_rock_my_future_self.mp3',
    'chill-rock-my_love': 'https://cdn.melo.ai/tracks/chill_rock_my_love.mp3',
    'chill-pop-my_pet': 'https://cdn.melo.ai/tracks/chill_pop_my_pet.mp3',
    'chill-pop-my_future_self': 'https://cdn.melo.ai/tracks/chill_pop_my_future_self.mp3',
    'chill-pop-my_love': 'https://cdn.melo.ai/tracks/chill_pop_my_love.mp3',
    
    // Happy tracks
    'happy-k-pop-my_pet': 'https://cdn.melo.ai/tracks/happy_kpop_my_pet.mp3',
    'happy-k-pop-my_future_self': 'https://cdn.melo.ai/tracks/happy_kpop_my_future_self.mp3',
    'happy-k-pop-my_love': 'https://cdn.melo.ai/tracks/happy_kpop_my_love.mp3',
    'happy-rap-my_pet': 'https://cdn.melo.ai/tracks/happy_rap_my_pet.mp3',
    'happy-rap-my_future_self': 'https://cdn.melo.ai/tracks/happy_rap_my_future_self.mp3',
    'happy-rap-my_love': 'https://cdn.melo.ai/tracks/happy_rap_my_love.mp3',
    'happy-rock-my_pet': 'https://cdn.melo.ai/tracks/happy_rock_my_pet.mp3',
    'happy-rock-my_future_self': 'https://cdn.melo.ai/tracks/happy_rock_my_future_self.mp3',
    'happy-rock-my_love': 'https://cdn.melo.ai/tracks/happy_rock_my_love.mp3',
    'happy-pop-my_pet': 'https://cdn.melo.ai/tracks/happy_pop_my_pet.mp3',
    'happy-pop-my_future_self': 'https://cdn.melo.ai/tracks/happy_pop_my_future_self.mp3',
    'happy-pop-my_love': 'https://cdn.melo.ai/tracks/happy_pop_my_love.mp3',
  };

  @override
  void initState() {
    super.initState();
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _player.playingStream.listen((isPlaying) {
      if (mounted && !MediaQuery.of(context).disableAnimations) {
        if (isPlaying) {
          _discController.repeat();
        } else {
          _discController.stop();
        }
      }
    });

    // Start particle animation
    _particleController.repeat();

    _startChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _player.dispose();
    _discController.dispose();
    _messageAnimationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    print('🔥 Adding message: "${message.text}" (type: ${message.type})');
    setState(() {
      _messages.add(message);
    });
    print('🔥 Total messages now: ${_messages.length}');
    
    _messageAnimationController.forward().then((_) {
      _messageAnimationController.reset();
    });
    
    // Smooth scroll to bottom with auto-scroll up effect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _startChat() {
    print('🔥 _startChat() called!');
    
    // Step 1: Welcome message
    Future.delayed(const Duration(milliseconds: 800), () {
      print('🔥 Adding welcome message');
      _addMessage(ChatMessage(
        text: "Welcome to MELO AI ! 👋",
        isFromUser: false,
        type: MessageType.text,
      ));
      
      // Step 2: Help message (delay ≈ 0.8s)
      Future.delayed(const Duration(milliseconds: 800), () {
        print('🔥 Adding help message');
        _addMessage(ChatMessage(
          text: "I'll help you create your first song.",
          isFromUser: false,
          type: MessageType.text,
        ));
        
        // Step 3: Present user choice options
        Future.delayed(const Duration(milliseconds: 1500), () {
          print('🔥 Adding choice buttons');
          _currentStep = "start";
          _addMessage(ChatMessage(
            text: "",
            isFromUser: false,
            type: MessageType.choices,
            choices: ["Sure, sounds fun!"], // Only one option
          ));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient - matching your app theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF4AE2), // Top gradient colour - matching your theme
                  Color(0xFF7A4BFF), // Bottom gradient colour - matching your theme
                ],
              ),
            ),
          ),

          // Animated particles background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ChatParticlePainter(
                    animationProgress: _particleController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Dark scrim for better text readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with MELO AI branding
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: const Text(
                    'MELO AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 3,
                    ),
                  ),
                ),
                
                // Chat messages area - takes most of the space
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(_messages[index]);
                    },
                  ),
                ),
                
                // Bottom area for choice buttons
                _buildBottomChoiceArea(),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomChoiceArea() {
    // Find the last payment message if any
    final lastPaymentMessage = _messages.lastWhere(
      (msg) => msg.type == MessageType.payment,
      orElse: () => ChatMessage(text: "", isFromUser: false, type: MessageType.text),
    );
    
    // Find the last choices message if any
    final lastChoicesMessage = _messages.lastWhere(
      (msg) => msg.type == MessageType.choices,
      orElse: () => ChatMessage(text: "", isFromUser: false, type: MessageType.text),
    );
    
    if (lastPaymentMessage.type == MessageType.payment) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => _handlePaymentChoice("Sounds great!"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6FD8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFFF6FD8).withOpacity(0.3),
                ),
                child: const Text(
                  "Sounds great!",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePaymentChoice("Explain some more"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x33FFFFFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Explain some more",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (lastChoicesMessage.type == MessageType.choices) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: lastChoicesMessage.choices!.map((choice) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => _handleChoice(choice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6FD8), // Updated to match your theme
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFFF6FD8).withOpacity(0.3),
                ),
                child: Text(
                  choice,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
    
    return const SizedBox(height: 20);
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      key: message.key,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: _buildMessageContent(message),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(message);
      case MessageType.choices:
        return const SizedBox.shrink(); // Don't render choices inline, use bottom area
      case MessageType.creating:
        return _buildCreatingMessage();
      case MessageType.songCreated:
        return _buildSongCreatedMessage(message);
      case MessageType.upgrade:
        return _buildUpgradeMessage();
      case MessageType.payment:
        return const SizedBox.shrink(); // Use bottom area for payment buttons
    }
  }

  Widget _buildTextMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: message.isFromUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/music_logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if logo doesn't load
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded, 
                        color: Colors.white, 
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: message.isFromUser 
                    ? const Color(0xFFFF6FD8) // Updated to match your theme
                    : const Color(0x20FFFFFF), // More transparent for better readability
                borderRadius: BorderRadius.circular(message.isFromUser ? 25 : 20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: message.isFromUser ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'SF Pro Display',
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatingMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0x20FFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFFFF6FD8), // Updated to match your theme
            ),
            const SizedBox(width: 16),
            const Text(
              "Creating your song...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCreatedMessage(ChatMessage message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0x20FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x30FFFFFF)),
        ),
        child: Column(
          children: [
            const Text(
              "Song created.",
              style: TextStyle(
                color: Color(0xFF32D74B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 20),
            RotationTransition(
              turns: _discController,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6FD8), Color(0xFF7A4BFF)], // Updated to match your theme
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.album,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Time Capsule",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "A $_selectedMood ${_selectedGenre?.toLowerCase() ?? 'pop'} song for $_selectedSubject",
              style: const TextStyle(
                color: Color(0xFFBBBBBB),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Play/Pause button
            StreamBuilder<bool>(
              stream: _player.playingStream,
              builder: (context, snapshot) {
                bool isPlaying = snapshot.data ?? false;
                return Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _togglePlayPause(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6FD8), // Updated to match your theme
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFFF6FD8).withOpacity(0.3),
                    ),
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(
                      isPlaying ? "Pause" : "Play",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleChoice(String choice) {
    _addMessage(ChatMessage(
      text: choice,
      isFromUser: true,
      type: MessageType.text,
    ));
    
    // Smooth transition with fade out and fade in
    Future.delayed(const Duration(milliseconds: 1200), () {
      // Fade out effect by clearing messages
      setState(() {
        _messages.clear();
      });
      
      // Wait a bit for smooth transition
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_currentStep == "start") {
          // After user responds to initial prompt, move to mood question
          _addMessage(ChatMessage(
            text: "What's the mood of your song?",
            isFromUser: false,
            type: MessageType.text,
          ));
          
          Future.delayed(const Duration(milliseconds: 800), () {
            _currentStep = "mood";
            _addMessage(ChatMessage(
              text: "",
              isFromUser: false,
              type: MessageType.choices,
              choices: ["Motivational", "Chill", "Happy"], // Exact 3 options
            ));
          });
          
        } else if (_currentStep == "mood") {
          _selectedMood = choice.toLowerCase();
          
          // Genre question
          _addMessage(ChatMessage(
            text: "What genre do you prefer?",
            isFromUser: false,
            type: MessageType.text,
          ));
          
          Future.delayed(const Duration(milliseconds: 800), () {
            _currentStep = "genre";
            _addMessage(ChatMessage(
              text: "",
              isFromUser: false,
              type: MessageType.choices,
              choices: ["K-Pop", "Rap", "Rock", "Pop"], // Exact 4 options
            ));
          });
          
        } else if (_currentStep == "genre") {
          _selectedGenre = choice.toLowerCase().replaceAll('-', '').replaceAll('kpop', 'k-pop');
          
          // Subject question
          _addMessage(ChatMessage(
            text: "What should the song be about?",
            isFromUser: false,
            type: MessageType.text,
          ));
          
          Future.delayed(const Duration(milliseconds: 800), () {
            _currentStep = "subject";
            _addMessage(ChatMessage(
              text: "",
              isFromUser: false,
              type: MessageType.choices,
              choices: ["My pet", "My future self", "My love"], // Exact 3 options
            ));
          });
          
        } else if (_currentStep == "subject") {
          // Map choice to correct key format
          String subjectKey = choice.toLowerCase();
          if (subjectKey == "my pet") subjectKey = "my_pet";
          else if (subjectKey == "my future self") subjectKey = "my_future_self";
          else if (subjectKey == "my love") subjectKey = "my_love";
          
          _selectedSubject = subjectKey;
          
          // Creating message
          _addMessage(ChatMessage(
            text: "Perfect! Creating your song...",
            isFromUser: false,
            type: MessageType.text,
          ));
          
          Future.delayed(const Duration(milliseconds: 2000), () {
            _currentStep = "creating";
            _createSong();
          });
        }
      });
    });
  }

  void _createSong() {
    // Get the song URL based on selections
    String key = '${_selectedMood}-${_selectedGenre}-${_selectedSubject}';
    print('🎵 Creating song with key: $key');
    print('🎵 Available keys: ${_songMatrix.keys.toList()}');
    String? songUrl = _songMatrix[key];
    
    if (songUrl != null) {
      print('🎵 Found song URL: $songUrl');
      _currentSongUrl = songUrl;
      
      // Clear messages and show creating UI
      setState(() {
        _messages.clear();
      });
      
      _addMessage(ChatMessage(
        text: "",
        isFromUser: false,
        type: MessageType.creating,
      ));
      
      // Simulate creation time
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _messages.clear();
          });
          
          _currentStep = "created";
          _discController.repeat();
          
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
            
            // After song is created and playing for a few seconds, show upgrade flow
            Timer(const Duration(seconds: 5), () {
              if (mounted) {
                _showUpgradeFlow();
              }
            });
          });
        }
      });
    } else {
      print('🚨 Song not found for key: $key');
      // Fallback: show error or default song
      _addMessage(ChatMessage(
        text: "Sorry, couldn't create your song. Please try again!",
        isFromUser: false,
        type: MessageType.text,
      ));
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_currentSongUrl != null) {
          await _player.setUrl(_currentSongUrl!);
          await _player.play();
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _showUpgradeFlow() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _messages.clear();
      });
      
      // Step 1: Upgrade prompt
      Future.delayed(const Duration(milliseconds: 500), () {
        _addMessage(ChatMessage(
          text: "Unlock Full Potential — here's what you get:",
          isFromUser: false,
          type: MessageType.text,
        ));
        
        Future.delayed(const Duration(milliseconds: 800), () {
          _addMessage(ChatMessage(
            text: "",
            isFromUser: false,
            type: MessageType.upgrade,
          ));
          
          // Step 2: Ask how it sounds
          Future.delayed(const Duration(milliseconds: 2000), () {
            _addMessage(ChatMessage(
              text: "How does it sound?",
              isFromUser: false,
              type: MessageType.text,
            ));
            
            Future.delayed(const Duration(milliseconds: 800), () {
              _addMessage(ChatMessage(
                text: "",
                isFromUser: false,
                type: MessageType.payment,
              ));
            });
          });
        });
      });
    });
  }

  Widget _buildUpgradeMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x30FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureItem(
            icon: Icons.music_note,
            title: "Create More AI Songs",
            subtitle: "Unlimited song generation",
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.record_voice_over,
            title: "AI Covers with Your Voice",
            subtitle: "Sound like your favorite artists",
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.diamond,
            title: "Royalty-free Usage",
            subtitle: "Use your songs commercially",
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.high_quality,
            title: "Studio Quality in Seconds",
            subtitle: "Professional audio output",
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6FD8), Color(0xFF7A4BFF)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handlePaymentChoice(String choice) {
    // Add user's choice message
    _addMessage(ChatMessage(
      text: choice,
      isFromUser: true,
      type: MessageType.text,
    ));
    
    if (choice == "Sounds great!") {
      // Navigate to payment/subscription screen
      Future.delayed(const Duration(milliseconds: 800), () {
        _showSubscriptionModal();
      });
    } else {
      // Show more details about the premium features
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _messages.clear();
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          _addMessage(ChatMessage(
            text: "MELO AI Premium gives you unlimited access to:",
            isFromUser: false,
            type: MessageType.text,
          ));
          
          Future.delayed(const Duration(milliseconds: 800), () {
            _addMessage(ChatMessage(
              text: "• Generate unlimited songs in any style\n• Clone your voice for AI covers\n• Commercial usage rights\n• High-quality audio downloads\n• Priority generation queue",
              isFromUser: false,
              type: MessageType.text,
            ));
            
            Future.delayed(const Duration(milliseconds: 1500), () {
              _addMessage(ChatMessage(
                text: "Ready to upgrade?",
                isFromUser: false,
                type: MessageType.text,
              ));
              
              Future.delayed(const Duration(milliseconds: 800), () {
                _addMessage(ChatMessage(
                  text: "",
                  isFromUser: false,
                  type: MessageType.payment,
                ));
              });
            });
          });
        });
      });
    }
  }

  void _showSubscriptionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSubscriptionModal(),
    );
  }

  Widget _buildSubscriptionModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF4AE2),
            Color(0xFF7A4BFF),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              "Choose Your Plan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro Display',
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              "Start creating unlimited AI music today",
              style: TextStyle(
                color: Color(0xFFBBBBBB),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Subscription options
            Expanded(
              child: Column(
                children: [
                  _buildSubscriptionOption(
                    title: "MELO AI Pro",
                    subtitle: "Monthly",
                    price: "\$9.99",
                    period: "/month",
                    isRecommended: false,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSubscriptionOption(
                    title: "MELO AI Pro",
                    subtitle: "Annual • Save 58%",
                    price: "\$49.99",
                    period: "/year",
                    isRecommended: true,
                  ),
                ],
              ),
            ),
            
            // Continue button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to OnboardingPage4 after subscription
                  widget.onDone();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF7A4BFF),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Start Free Trial",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
            
            // Skip option
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDone();
                },
                child: const Text(
                  "Continue with Free Version",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required bool isRecommended,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRecommended 
          ? Colors.white.withOpacity(0.2)
          : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: isRecommended 
          ? Border.all(color: Colors.white, width: 2)
          : Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "RECOMMENDED",
                      style: TextStyle(
                        color: Color(0xFF7A4BFF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                if (isRecommended) const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFBBBBBB),
                    fontSize: 14,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              Text(
                period,
                style: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Chat Background Particles
class _ChatParticlePainter extends CustomPainter {
  final double animationProgress;

  _ChatParticlePainter({required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Create floating particles throughout the chat background
    for (int i = 0; i < 25; i++) {
      // Create consistent particle positions using index as seed
      final Random rng = Random(i);
      
      // Base positions across the screen
      double baseX = rng.nextDouble() * size.width;
      double baseY = rng.nextDouble() * size.height;
      
      // Animate particles in a gentle floating motion
      double offsetX = sin((animationProgress * 2 * pi) + (i * 0.3)) * 30;
      double offsetY = cos((animationProgress * 2 * pi) + (i * 0.5)) * 20;
      
      double finalX = baseX + offsetX;
      double finalY = baseY + offsetY;
      
      // Vary particle colors to match your theme
      Color particleColor;
      if (i % 3 == 0) {
        particleColor = const Color(0xFFFF6FD8); // Pink from your theme
      } else if (i % 3 == 1) {
        particleColor = const Color(0xFF7A4BFF); // Purple from your theme
      } else {
        particleColor = Colors.white;
      }
      
      paint.color = particleColor.withOpacity(0.4);
      
      // Vary particle sizes
      double particleSize = (i % 3) == 0 ? 3.0 : 2.0;
      
      canvas.drawCircle(Offset(finalX, finalY), particleSize, paint);
    }

    // Add some larger glowing particles
    for (int i = 0; i < 8; i++) {
      final Random rng = Random(i + 100);
      
      double baseX = rng.nextDouble() * size.width;
      double baseY = rng.nextDouble() * size.height;
      
      // Slower movement for larger particles
      double offsetX = sin((animationProgress * pi) + (i * 0.8)) * 50;
      double offsetY = cos((animationProgress * pi) + (i * 0.6)) * 40;
      
      double finalX = baseX + offsetX;
      double finalY = baseY + offsetY;
      
      // Glow effect
      paint.color = const Color(0xFFFF6FD8).withOpacity(0.15);
      canvas.drawCircle(Offset(finalX, finalY), 8, paint);
      
      paint.color = const Color(0xFFFF6FD8).withOpacity(0.3);
      canvas.drawCircle(Offset(finalX, finalY), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
