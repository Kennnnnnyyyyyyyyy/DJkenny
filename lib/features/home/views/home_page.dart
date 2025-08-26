import 'package:flutter/material.dart';
import 'package:music_app/widgets/ai_lyrics_button.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import '../widgets/gradient_cta_button.dart';
import '../../../shared/widgets/animated_loading_overlay.dart';
import '../../../shared/services/music_generation_service.dart';
import '../../explore/views/explore_page.dart';
import '../../library/views/library_page.dart';
// import removed: GradientToggleSwitch no longer exists
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = "Simple song";
  String selectedModel = "Melo 3.5";
  String selectedCustomModel = "Melo V3.5"; // Separate variable for custom mode
  final TextEditingController lyricsController = TextEditingController();
  final TextEditingController styleController = TextEditingController();
  List<String> selectedStyles = [];
  bool _isGenerating = false;
  String? _successMessage;
  String? _errorMessage;
  final MusicGenerationService _musicService = MusicGenerationService();
  
  // PageView Controller and current page index
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<Map<String, dynamic>> musicStyles = [
    {"name": "Custom", "icon": Icons.edit, "color": Colors.greenAccent},
    {"name": "Random", "icon": Icons.casino, "color": Colors.greenAccent},
    {"name": "Pop", "icon": Icons.mic, "color": Colors.pinkAccent},
    {"name": "HipHop", "icon": Icons.headphones, "color": Colors.blueAccent},
    {"name": "Jazz", "icon": Icons.music_note, "color": Colors.orangeAccent},
  ];

  void startGenerating() {
    setState(() {
      _isGenerating = true;
    });
  }

  void stopGenerating() {
    setState(() {
      _isGenerating = false;
    });
  }

  Future<void> _generateMusic() async {
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });
    
    startGenerating();
    
    try {
      // Collect form data
      final prompt = lyricsController.text.trim();
      if (prompt.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter some lyrics or a description';
        });
        stopGenerating();
        return;
      }

      final bool isCustomMode = selectedTab == "Custom song";
      final bool instrumentalToggle = selectedStyles.contains("Instrumental");
      final String styleInput = isCustomMode ? styleController.text.trim() : "";
      final String currentModel = isCustomMode ? selectedCustomModel : selectedModel;

      print('🎵 Starting music generation...');
      print('📝 Prompt: $prompt');
      print('🎛️ Model: $currentModel');
      print('🎨 Custom Mode: $isCustomMode');
      print('🎼 Instrumental: $instrumentalToggle');

      // Call the music generation service
      final result = await _musicService.generateTrack(
        prompt: prompt,
        modelLabel: currentModel,
        isCustomMode: isCustomMode,
        instrumentalToggle: instrumentalToggle,
        styleInput: styleInput,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _successMessage = result['message'] ?? '🎵 Song generation started!';
          });
          
          // Hide success message after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _successMessage = null;
              });
            }
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to generate music';
          });
          
          // Hide error message after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _errorMessage = null;
              });
            }
          });
        }
      }
    } catch (e) {
      print('❌ Generation Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
        });
        
        // Hide error message after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _errorMessage = null;
            });
          }
        });
      }
    } finally {
      stopGenerating();
    }
  }

  Future<void> _openPaywall() async {
    try {
      await Superwall.shared.registerPlacement('PremiumBeat');
    } catch (e, st) {
      debugPrint('Superwall paywall error: $e\n$st');
    }
  }

  @override
  void dispose() {
    lyricsController.dispose();
    styleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping anywhere on screen
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque, // Ensure the gesture detector catches all taps
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make transparent for gradient background
        extendBodyBehindAppBar: true, // Extend content behind system UI
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
          child: Column(
            children: [
              // Status bar area with same gradient color
              Container(
                height: MediaQuery.of(context).padding.top,
                color: const Color(0xFF0E1018), // Match gradient top color
              ),
              // AppBar content
              Container(
                height: 56, // Standard AppBar height
                child: Stack(
                  children: [
              // Centered title based on full screen width
              Center(
                child: Text(
                  _getPageTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontFamily: 'Playfair Display',
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
                    onTap: _openPaywall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)],
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
                            "Pro",
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
              // Main content (PageView)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCreatePage(),
                    const ExplorePage(),
                    const LibraryPage(),
                  ],
                ),
              ),
              // Bottom Navigation
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.6, 1.0],
                    colors: [
                      Color(0xFF0E1018), // Nightfall start - very top
                      Color(0xFF20233B), // Mid-point around 60% down
                      Color(0xFF4A2D7C), // Neon end - bottom edge
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(Icons.music_note, "Create", 0),
                        _buildNavItem(Icons.explore, "Explore", 1),
                        _buildNavItem(Icons.library_music, "Library", 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ), // Close GestureDetector
    );
  } // End of _buildAuthenticatedHomePage method

  /// Get page title based on current page index
  String _getPageTitle() {
    switch (_currentPageIndex) {
      case 0:
        return "Melo AI";
      case 1:
        return "Explore";
      case 2:
        return "Library";
      default:
        return "Melo AI";
    }
  }

  /// Build navigation item
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentPageIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPageIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Create Page with all the music generation UI
  Widget _buildCreatePage() {
    return Stack(
      children: [
        // Main content
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8), // Reduced from 32 to move content up

                  // Gradient Pill Tabs (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: TabPillButton(
                          text: "Simple song",
                          selected: selectedTab == "Simple song",
                          onTap: () => setState(() => selectedTab = "Simple song"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TabPillButton(
                          text: "Custom song",
                          selected: selectedTab == "Custom song",
                          onTap: () => setState(() => selectedTab = "Custom song"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // Reduced from 20 to 12 for tighter spacing

                  // Different content based on tab
                  if (selectedTab == "Custom song")
                    _buildCustomSongUI()
                  else
                    _buildSimpleSongUI(),

                  const SizedBox(height: 20),

                  // Modern Gradient Create Button
                  Center(
                    child: GradientCTAButton(
                      text: _isGenerating ? "Generating..." : "Create",
                      onTap: _isGenerating ? null : _generateMusic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Loading overlay
        AnimatedLoadingOverlay(
          isVisible: _isGenerating || _successMessage != null || _errorMessage != null,
          successMessage: _successMessage ?? _errorMessage,
        ),
      ],
    );
  }

  /// ✅ Simple Song UI
  Widget _buildSimpleSongUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Song Prompts Label + Simple Dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Song Prompts",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Manrope',
              ),
            ),
            // Simple Dropdown
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedModel,
                  items: [
                    "Melo 3.5",        // Suno
                    "Melo V4",         // Suno  
                    "Melo V4.5",       // Suno
                    "Melo V2.0",       // GoAPI (< 3.5)
                    "Melo V5.0",       // GoAPI (> 4.5)
                    "GoAPI DiffRhythm", // GoAPI (contains 'goapi')
                    "Qubico Model",    // GoAPI (contains 'qubico')
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedModel = value!);
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 12,
                  ),
                  iconSize: 12,
                  dropdownColor: const Color(0xFF2C2C2E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Prompt Text Field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: lyricsController,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                style: const TextStyle(color: Colors.white, fontFamily: 'Manrope'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "A lyrical rock song about us walking through the woods, chasing freedom and dreams",
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Manrope'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Instrumental Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.music_note, color: Colors.orange, size: 22),
                  SizedBox(width: 6),
                  Text(
                    "Instrumental",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              Switch(
                value: selectedStyles.contains("Instrumental"),
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      selectedStyles.add("Instrumental");
                    } else {
                      selectedStyles.remove("Instrumental");
                    }
                  });
                },
                activeColor: Colors.deepPurple,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ Custom Song UI
  Widget _buildCustomSongUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Feed the AI Label + Dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Feed the AI",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Manrope'
              ),
            ),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCustomModel,
                  items: [
                    "Melo V3.5",       // Suno
                    "Melo V4.0",       // Suno
                    "Melo V4.5",       // Suno
                    "Melo V2.0",       // GoAPI
                    "Melo V5.0",       // GoAPI
                    "GoAPI DiffRhythm", // GoAPI
                    "Qubico Model",    // GoAPI
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCustomModel = value!);
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 12,
                  ),
                  iconSize: 12,
                  dropdownColor: const Color(0xFF2C2C2E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Text Area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: lyricsController,
            maxLines: 4,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              FocusScope.of(context).nextFocus();
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            style: const TextStyle(color: Colors.white, fontFamily: 'Manrope'),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter your own lyrics",
              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Manrope'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: AiLyricsButton(controller: lyricsController),
        ),
        const SizedBox(height: 20),

        // Style Input
        const Text(
          "Shape the Sound",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: styleController,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            style: const TextStyle(color: Colors.white, fontFamily: 'Manrope'),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Describe the style you want (e.g. energetic pop, chill jazz, etc)",
              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Manrope'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient pill tab button for tabs
class TabPillButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const TabPillButton({
    required this.text, 
    required this.selected, 
    required this.onTap, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)])
              : null,
          color: selected ? null : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(40),
          border: selected
              ? Border.all(color: Color(0xFFFF6FD8), width: 2)
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
