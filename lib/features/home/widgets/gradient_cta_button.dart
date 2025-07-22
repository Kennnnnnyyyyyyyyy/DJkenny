import 'package:flutter/material.dart';

class GradientCTAButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  const GradientCTAButton({required this.text, required this.onTap, super.key});

  @override
  State<GradientCTAButton> createState() => _GradientCTAButtonState();
}

class _GradientCTAButtonState extends State<GradientCTAButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: _hovering
          ? [Color(0xFFFF8FE5), Color(0xFF3813C2)]
          : [Color(0xFFFF6FD8), Color(0xFF3813C2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            if (_hovering)
              BoxShadow(
                color: Color(0xFFFF6FD8).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: widget.onTap,
            child: Container(
              constraints: BoxConstraints(minWidth: 180),
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_note, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(width: 18),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                    decoration: BoxDecoration(
                      color: _hovering ? Color(0xFF3813C2) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: _hovering ? Colors.white : Color(0xFF3813C2),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
