import 'package:flutter/material.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/gradient_dropdown_menu.dart';
import '../../../shared/widgets/animated_loading_overlay.dart';
import '../../../shared/services/music_generation_service.dart';
// import removed: GradientToggleSwitch no longer exists
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = "Simple song";
  String selectedModel = "Melo 3.5";
  final TextEditingController lyricsController = TextEditingController();
  final TextEditingController styleController = TextEditingController();
  List<String> selectedStyles = [];
  bool _isGenerating = false;
  String? _successMessage;
  String? _errorMessage;
  final MusicGenerationService _musicService = MusicGenerationService();

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

      print('🎵 Starting music generation...');
      print('📝 Prompt: $prompt');
      print('🎛️ Model: $selectedModel');
      print('🎨 Custom Mode: $isCustomMode');
      print('🎼 Instrumental: $instrumentalToggle');

      // Call the music generation service
      final result = await _musicService.generateTrack(
        prompt: prompt,
        modelLabel: selectedModel,
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

  @override
  void dispose() {
    lyricsController.dispose();
    styleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo positioned slightly to the left
                  Transform.translate(
                    offset: const Offset(-4, 0), // Move logo 4px to the left
                    child: Image.asset(
                      'assets/music_logo.png',
                      height: 42, // Larger size to grab attention
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12), // Clean spacing between logo and text
                  // Text stays centered
                  const Text(
                    "MELO AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/qonversion');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Pro",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
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
                    const SizedBox(height: 32),

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
                    const SizedBox(height: 20),

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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/explore');
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
    );
  }

  /// ✅ Simple Song Placeholder
  /// ✅ Simple Song UI (like before)
  Widget _buildSimpleSongUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Song Prompts Dropdown + Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Song Prompts",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            Expanded(
              child: PillDropdownMenu(
                value: selectedModel,
                items: ["Melo 3.5", "Melo V4", "Melo V4.5"],
                onChanged: (value) {
                  setState(() => selectedModel = value);
                },
                gradientActive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Prompt Text Field + Inspiration Button
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
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      "A lyrical rock song about us walking through the woods, chasing freedom and dreams",
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: 0.75,
                      child: Image.asset(
                        'assets/white_m.png',
                        height: 18,
                        width: 18,
                        fit: BoxFit.contain,
                        color: Colors.white.withOpacity(0.8),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Inspiration",
                      style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    ),
                  ],
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
                      fontFamily: 'Inter',
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
        // Dropdown + Your Lyrics label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Your Lyrics",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter'),
            ),
            PillDropdownMenu(
              value: selectedModel,
              items: ["Melo V3.5", "Melo V4.0", "Melo V4.5"],
              onChanged: (value) {
                setState(() => selectedModel = value);
              },
              gradientActive: true,
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Text Area with integrated buttons
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text input field
              TextField(
                controller: lyricsController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter your own lyrics",
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
                ),
              ),
              const SizedBox(height: 8),
              // Integrated buttons row - positioned at bottom-right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildIntegratedButton("AI Lyrics"),
                  const SizedBox(width: 8),
                  _buildIntegratedButton("Random"),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Describe of Style Text Box
        const Text(
          "Describe of style",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
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
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Describe the style you want (e.g. energetic pop, chill jazz, etc)",
              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
            ),
          ),
        ),
      ],
    );
  }

  /// Integrated button that blends with the input bar
  Widget _buildIntegratedButton(String label) {
    return Container(
      decoration: BoxDecoration(
        // Same background as input with subtle contrast
        color: Colors.grey.shade800.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12), // Match input field radius
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5), // Subtle border
          width: 1,
        ),
        // Subtle shadow to make it feel part of the input box
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Handle button tap
            if (label == "AI Lyrics") {
              // Add AI Lyrics functionality
              print("AI Lyrics tapped");
            } else if (label == "Random") {
              // Add Random functionality
              print("Random tapped");
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Small logo icon
                Opacity(
                  opacity: 0.75, // Reduced opacity for blending
                  child: Image.asset(
                    'assets/white_m.png',
                    height: 18, // Small size (16-20px range)
                    width: 18,
                    fit: BoxFit.contain,
                    color: Colors.white.withOpacity(0.8), // Slight tint for color scheme
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
                const SizedBox(width: 6), // Horizontal padding between logo and text
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Match input text size
                    fontWeight: FontWeight.w500, // Weight ~500 as requested
                    fontFamily: 'Inter', // Match input font
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient pill tab button for tabs
class TabPillButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const TabPillButton(
      {required this.text, required this.selected, required this.onTap, super.key});

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
