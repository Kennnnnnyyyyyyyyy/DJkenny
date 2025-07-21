import 'package:flutter/material.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/gradient_dropdown_menu.dart';
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
  List<String> selectedStyles = [];

  final List<Map<String, dynamic>> musicStyles = [
    {"name": "Custom", "icon": Icons.edit, "color": Colors.greenAccent},
    {"name": "Random", "icon": Icons.casino, "color": Colors.greenAccent},
    {"name": "Pop", "icon": Icons.mic, "color": Colors.pinkAccent},
    {"name": "HipHop", "icon": Icons.headphones, "color": Colors.blueAccent},
    {"name": "Jazz", "icon": Icons.music_note, "color": Colors.orangeAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "MELO AI MUSIC",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // ✅ Gradient Pill Tabs (side by side)
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

                // ✅ Different content based on tab
                if (selectedTab == "Custom song")
                  _buildCustomSongUI()
                else
                  _buildSimpleSongUI(),

                const SizedBox(height: 20),

                // ✅ Modern Gradient Create Button
                Center(
                  child: GradientCTAButton(
                    text: "Create",
                    onTap: () {
                      // TODO: Trigger music generation
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      "A lyrical rock song about us walking through the woods, chasing freedom and dreams",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome, color: Colors.teal),
                label: const Text("Inspiration",
                    style: TextStyle(color: Colors.white)),
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
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
                  fontWeight: FontWeight.bold),
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

        // Text Area
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter your own lyrics",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSmallButton(Icons.auto_awesome, "AI Lyrics"),
                  const SizedBox(width: 10),
                  _buildSmallButton(Icons.casino, "Random"),
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
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Describe the style you want (e.g. energetic pop, chill jazz, etc)",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton(IconData icon, String label) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {},
      icon: Icon(icon, color: Colors.greenAccent),
      label: Text(label, style: const TextStyle(color: Colors.white)),
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
