import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ai_lyrics_service.dart';

class AiLyricsButton extends StatefulWidget {
  final TextEditingController controller;
  const AiLyricsButton({super.key, required this.controller});

  @override
  State<AiLyricsButton> createState() => _AiLyricsButtonState();
}

class _AiLyricsButtonState extends State<AiLyricsButton> {
  bool _loading = false;
  bool _inserted = false;
  Timer? _resetTimer;

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      final text = await AiLyricsService.fetchRandomLyrics();
      widget.controller.text = text;
      if (!mounted) return;
      setState(() {
        _inserted = true;
      });
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _inserted = false);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showingGenerating = _loading;
    final showingInserted = _inserted && !_loading;
    return FilledButton.icon(
      onPressed: showingGenerating ? null : _generate,
      icon: showingGenerating
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(showingInserted ? Icons.check_circle : Icons.auto_awesome),
      label: Text(
        showingGenerating
            ? 'Generating…'
            : showingInserted
                ? 'Inserted!'
                : 'AI Lyrics',
      ),
    );
  }
}
