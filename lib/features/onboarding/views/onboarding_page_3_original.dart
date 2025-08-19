import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../../onboarding/onboarding_service.dart';
import 'package:music_app/ui/widgets/circular_album_player.dart';
import 'package:music_app/data/repo/music_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final OnboardingService _onboardingService = OnboardingService();
  late AnimationController _discController;
  late AnimationController _messageAnimationController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _colorController;
  late AnimationController _driftController;
  
  String _currentStep = "intro";
  String? _selectedMood, _selectedGenre, _selectedSubject;
  String? _currentSongUrl;
  String? _currentCoverUrl; // album art for the created song
  String? _currentTrackTitle; // optional server title
  bool _isSecondPaymentPrompt = false;
  bool _modalShown = false;
  bool _showPsychedelicBackground = false;
  bool _isProcessingChoice = false; // Flag to prevent multiple rapid clicks
  bool _upgradeFlowShown = false; // Flag to prevent duplicate upgrade flows
  final MusicRepo _musicRepo = MusicRepo(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    
    // Initialize audio session
    _initAudio();
    
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

    // Psychedelic wave controllers
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _driftController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
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

  Future<void> _initAudio() async {
    try {
      debugPrint('🔧 [Page3] Initializing audio session...');
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      
      // Set up audio interruption handling
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          debugPrint('🔇 [Page3] Audio interruption began');
          if (_player.playing) {
            _player.pause();
          }
        } else {
          debugPrint('🔊 [Page3] Audio interruption ended');
        }
      });
      
      // Log playback errors with more detail
      _player.playbackEventStream.listen(
        (event) {
          debugPrint('🎵 [Page3] Playback event: ${event.processingState}');
        }, 
        onError: (Object e, StackTrace st) {
          debugPrint('🔇 [Page3] just_audio error: $e');
        }
      );
      
      debugPrint('✅ [Page3] Audio session configured successfully');
    } catch (e) {
      debugPrint('⚠️ [Page3] Audio session init failed: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _player.dispose();
    _onboardingService.dispose();
    _discController.dispose();
    _messageAnimationController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _colorController.dispose();
    _driftController.dispose();
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
          // Ensure processing flag is reset for initial state
          _isProcessingChoice = false;
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

          // Psychedelic Wave Visualizer (appears after song is created)
          if (_showPsychedelicBackground)
            Positioned.fill(
              child: _PsychedelicWaveVisualizer(
                audioPlayer: _player,
                waveController: _waveController,
                colorController: _colorController,
                driftController: _driftController,
              ),
            ),

          // Animated particles background (render above wave so it's always visible)
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
                  child: const Center(
                    child: Text(
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
                ),
                
                // Main area: either chat list or inline player when created
                Expanded(
                  child: (_currentStep == 'created' && (_currentSongUrl != null && _currentSongUrl!.isNotEmpty) && _currentStep != 'upgrade')
                      ? _buildInlinePlayer()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessage(_messages[index]);
                          },
                        ),
                ),
                
                // Bottom area for choice buttons (hidden while player showing)
                if (!(_currentStep == 'created' && (_currentSongUrl != null && _currentSongUrl!.isNotEmpty) && _currentStep != 'upgrade'))
                  _buildBottomChoiceArea(),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlinePlayer() {
    final composedTitle = _currentTrackTitle ??
        '${_selectedMood ?? ''} – ${_selectedGenre ?? ''} – ${_selectedSubject ?? ''}'.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CircularAlbumPlayer(
        title: composedTitle.isEmpty ? 'Your track' : composedTitle,
        subtitle: 'Melo AI',
        audioUrl: _currentSongUrl!,
        coverUrl: _currentCoverUrl ?? '',
        onFinished: () {},
        onNext: widget.onDone,
        onPrev: () {},
        onContinue: () {
          debugPrint('CircularAlbumPlayer onContinue triggered');
          // Handle like a choice button - manage state properly
          if (_isProcessingChoice) {
            debugPrint('🚫 Choice already processing, ignoring rapid tap');
            return;
          }
          
          // Set processing flag
          _isProcessingChoice = true;
          
          // Clear the player and show upgrade flow
          setState(() {
            _currentStep = 'upgrade'; // Change step to show upgrade
            _messages.clear();
          });
          
          // Show upgrade flow immediately 
          Future.delayed(const Duration(milliseconds: 100), () {
            _showUpgradeFlow();
            _isProcessingChoice = false; // Reset flag
          });
        },
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)], // Pink to purple gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: () => _handlePaymentChoice("Sounds great!"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
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
            // Only show "Explain some more" button if it's NOT the second payment prompt
            if (!_isSecondPaymentPrompt)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: () => _handlePaymentChoice("Explain some more"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2), // Transparent white background
                    foregroundColor: Colors.white, // White text color
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shadowColor: Colors.transparent,
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)], // Always keep pink to purple gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: _isProcessingChoice ? null : () => _handleChoice(choice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white, // Always keep white text
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  choice,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                    color: Colors.white, // Always keep white text
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
    // If URL not ready yet, show loading chip
    if (_currentSongUrl == null || _currentSongUrl!.isEmpty) {
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
            children: const [
              CircularProgressIndicator(color: Color(0xFFFF6FD8)),
              SizedBox(width: 16),
              Text('Loading audio...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    final composedTitle = _currentTrackTitle ??
        '${_selectedMood ?? ''} – ${_selectedGenre ?? ''} – ${_selectedSubject ?? ''}'.trim();

    return CircularAlbumPlayer(
      title: composedTitle,
      subtitle: 'Melo AI',
      audioUrl: _currentSongUrl!,
      coverUrl: _currentCoverUrl ?? '',
      onFinished: () {},
      onNext: widget.onDone,
      onPrev: () {
        // Optional: go back
      },
      onContinue: () {
        debugPrint('CircularAlbumPlayer onContinue triggered (second instance)');
        // Handle like a choice button - manage state properly
        if (_isProcessingChoice) {
          debugPrint('🚫 Choice already processing, ignoring rapid tap');
          return;
        }
        
        // Set processing flag
        _isProcessingChoice = true;
        
        // Clear the player and show upgrade flow
        setState(() {
          _currentStep = 'upgrade'; // Change step to show upgrade
          _messages.clear();
        });
        
        // Show upgrade flow immediately
        Future.delayed(const Duration(milliseconds: 100), () {
          _showUpgradeFlow();
          _isProcessingChoice = false; // Reset flag
        });
      },
    );
  }

  Future<void> ensureCoverForTrack(String trackId, {String? mood, String? genre, String? topic, required String pageTag}) async {
    try {
      final prompt = 'Melo AI: \\${mood ?? ''} \\${genre ?? ''} • \\${(topic ?? '').replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')}';
      await _musicRepo.generateCover(
        prompt: prompt,
        pageTag: pageTag,
        mood: mood,
        genre: genre,
        topic: topic,
        trackId: trackId,
      );
    } catch (e) {
      debugPrint('ensureCoverForTrack failed: $e');
    }
  }

  void _handleChoice(String choice) {
    // Prevent multiple rapid clicks
    if (_isProcessingChoice) {
      print('🚫 Choice already processing, ignoring rapid tap');
      return;
    }
    
    // Set processing flag
    _isProcessingChoice = true;
    
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
            // Reset processing flag after choices are shown
            _isProcessingChoice = false;
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
            // Reset processing flag after choices are shown
            _isProcessingChoice = false;
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
            // Reset processing flag after choices are shown
            _isProcessingChoice = false;
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
            // Reset processing flag as we're moving to song creation
            _isProcessingChoice = false;
            _createSong();
          });
        }
      });
    });
  }

  void _createSong() async {
    // Use Supabase to fetch the song based on user selections
    print('🎵 Creating song for: mood=$_selectedMood, genre=$_selectedGenre, subject=$_selectedSubject');
    
    try {
      // Map UI choices to database format
      String moodUI = _selectedMood!.toLowerCase();
      String genreUI = _selectedGenre!;
      String topicUI = _selectedSubject!;
      
      // Convert topic back to UI format for the service
      if (topicUI == 'my_pet') topicUI = 'My pet';
      else if (topicUI == 'my_future_self') topicUI = 'My future self'; 
      else if (topicUI == 'my_love') topicUI = 'My love';
      
      // Clear messages and show creating UI
      setState(() {
        _messages.clear();
      });
      
      _addMessage(ChatMessage(
        text: "",
        isFromUser: false,
        type: MessageType.creating,
      ));
      
      // Fetch and keep track details from Supabase
      final track = await _onboardingService.findTrackFromChoices(
         moodUI: moodUI,
         genreUI: genreUI,
         topicUI: topicUI,
       );
      
      if (track != null) {
        print('🎵 Found track: ${track.title} - ${track.publicUrl}');
        _currentSongUrl = track.publicUrl;
        _currentCoverUrl = track.coverUrl; // may be null
        _currentTrackTitle = track.title;

        // Fire-and-forget: ensure cover exists
        if ((_currentCoverUrl == null || _currentCoverUrl!.isEmpty)) {
          // Pass DB keys mood/genre/topic directly if available from repo
          unawaited(ensureCoverForTrack(
            track.id,
            mood: track.mood,
            genre: track.genre,
            topic: track.topic,
            pageTag: track.pageTag,
          ));
        }
        
        // Simulate creation time - longer delay to make it feel like AI is creating
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
              
              // Do not auto-play here; the CircularAlbumPlayer will handle playback.
 
              // After a short delay, show upgrade flow (unchanged)
              Timer(const Duration(seconds: 5), () {
                if (mounted) {
                  _showUpgradeFlow();
                }
              });
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

  void _showUpgradeFlow() {
    if (_upgradeFlowShown) {
      debugPrint('_showUpgradeFlow: Already shown, skipping');
      return;
    }
    
    _upgradeFlowShown = true;
    debugPrint('_showUpgradeFlow called');
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _messages.clear();
      });
      
      // Step 1: Upgrade prompt
      Future.delayed(const Duration(milliseconds: 100), () {
        _addMessage(ChatMessage(
          text: "Unlock Full Potential — here's what you get:",
          isFromUser: false,
          type: MessageType.text,
        ));
        
        Future.delayed(const Duration(milliseconds: 200), () {
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
    if (choice == "Sounds great!" && !_modalShown) {
      // Set flag to prevent multiple modal opens
      _modalShown = true;
      // Navigate directly to subscription modal without adding duplicate message
      _showSubscriptionModal();
    } else if (choice == "Explain some more") {
      // Add user's choice message only for "Explain some more"
      _addMessage(ChatMessage(
        text: choice,
        isFromUser: true,
        type: MessageType.text,
      ));
      
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
                setState(() {
                  _isSecondPaymentPrompt = true;
                });
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
    final parentContext = context; // Store parent context
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _buildSubscriptionModal(modalContext, parentContext), // Pass both contexts
    ).whenComplete(() {
      // Reset flag when modal is closed so it can be opened again
      setState(() {
        _modalShown = false;
      });
    });
  }

  Widget _buildSubscriptionModal(BuildContext modalContext, BuildContext parentContext) {
    return Container(
      height: MediaQuery.of(modalContext).size.height * 0.8,
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
            // Header with handle bar and close button
            Stack(
              children: [
                // Handle bar (centered)
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
                // Close button (top right)
                Positioned(
                  top: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(modalContext);
                      // Call the onDone callback properly
                      debugPrint('🎯 OnboardingPage3: Close button - navigating to home');
                      context.go('/');
                      // Also call the callback for any cleanup
                      widget.onDone();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
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
                  Navigator.pop(modalContext);
                  // Call the onDone callback properly
                  debugPrint('🎯 OnboardingPage3: Subscribe button - navigating to home');
                  context.go('/');
                  // Also call the callback for any cleanup
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
                  Navigator.pop(modalContext);
                  // Call the onDone callback properly
                  debugPrint('🎯 OnboardingPage3: Continue Free button - navigating to home');
                  context.go('/');
                  // Also call the callback for any cleanup
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

// Psychedelic MultiWave Visualizer Widget
class _PsychedelicWaveVisualizer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final AnimationController waveController;
  final AnimationController colorController;
  final AnimationController driftController;

  const _PsychedelicWaveVisualizer({
    required this.audioPlayer,
    required this.waveController,
    required this.colorController,
    required this.driftController,
  });

  @override
  _PsychedelicWaveVisualizerState createState() => _PsychedelicWaveVisualizerState();
}

class _PsychedelicWaveVisualizerState extends State<_PsychedelicWaveVisualizer> {
  @override
  Widget build(BuildContext context) {
    final isAccessibilityReduceMotion = MediaQuery.of(context).disableAnimations;
    final shouldShowWaves = !isAccessibilityReduceMotion;

    if (!shouldShowWaves) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6FD8).withOpacity(0.2),
              Color(0xFF3813C2).withOpacity(0.2),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([widget.waveController, widget.colorController, widget.driftController]),
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _PsychedelicWavePainter(
            waveProgress: widget.waveController.value,
            colorProgress: widget.colorController.value,
            driftProgress: widget.driftController.value,
          ),
        );
      },
    );
  }
}

// Custom Painter for Psychedelic Wave Effect
class _PsychedelicWavePainter extends CustomPainter {
  final double waveProgress;
  final double colorProgress;
  final double driftProgress;

  _PsychedelicWavePainter({
    required this.waveProgress,
    required this.colorProgress,
    required this.driftProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    const waveCount = 3;
    const amplitude = 0.8;
    const frequency = 1.6;
    const lowFrequency = 0.2;

    for (int waveIndex = 0; waveIndex < waveCount; waveIndex++) {
      final path = Path();
      final waveOffset = (waveIndex * 2 * pi / waveCount) + (waveProgress * 2 * pi);
      final driftOffset = driftProgress * lowFrequency * 2 * pi;
      
      // Create wave path
      for (double x = 0; x <= size.width; x += 2) {
        final normalizedX = x / size.width;
        
        // Multiple sine waves for complexity
        final wave1 = sin((normalizedX * frequency * 2 * pi) + waveOffset) * amplitude;
        final wave2 = sin((normalizedX * frequency * 4 * pi) + (waveOffset * 1.3)) * (amplitude * 0.5);
        final wave3 = sin((normalizedX * frequency * 0.5 * pi) + driftOffset) * (amplitude * 0.3);
        
        final combinedWave = wave1 + wave2 + wave3;
        final y = (size.height * 0.5) + (combinedWave * size.height * 0.2);
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      // Create trippy gradient color based on position and time
      final colorPhase = (colorProgress + (waveIndex * 0.33)) % 1.0;
      final color1 = Color(0xFFFF6FD8); // Pink
      final color2 = Color(0xFF3813C2); // Purple
      
      // Lerp between colors with trippy cycling
      final lerpValue = (sin(colorPhase * 2 * pi) + 1) / 2;
      final waveColor = Color.lerp(color1, color2, lerpValue)!;
      
      paint.color = waveColor.withOpacity(0.35);
      
      // Draw multiple offset versions for glow effect
      for (int i = 0; i < 3; i++) {
        final offsetPath = path.shift(Offset(0, i * 2 - 2));
        paint.color = waveColor.withOpacity(0.35 - (i * 0.1));
        canvas.drawPath(offsetPath, paint);
      }
    }
    
    // Add radial gradient overlay for extra psychedelic effect
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Color(0xFFFF6FD8).withOpacity(0.1),
          Color(0xFF3813C2).withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
