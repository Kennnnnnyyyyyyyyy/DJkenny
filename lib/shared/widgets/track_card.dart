import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../shared/models/song.dart';
import '../services/audio_player_service.dart';

class TrackCard extends StatefulWidget {
  final Song song;
  const TrackCard(this.song, {super.key});

  @override
  State<TrackCard> createState() => _TrackCardState();
}

class _TrackCardState extends State<TrackCard> {
  final AudioPlayerService _audioService = AudioPlayerService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Listen to player state changes
    _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isLoading = state.processingState == ProcessingState.loading ||
                       state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  @override
  void dispose() {
    // Don't dispose the service here as it's shared
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      // Debug the URL we're trying to play
      print('🎵 TrackCard: Track data - ID: ${widget.song.id}, Title: ${widget.song.title}');
      print('🎵 TrackCard: Public URL: "${widget.song.publicUrl}"');
      
      if (widget.song.publicUrl.isEmpty) {
        throw Exception('No audio URL available for this track');
      }
      
      print('🎵 TrackCard: Attempting to play URL: ${widget.song.publicUrl}');
      await _audioService.playTrack(widget.song.id, widget.song.publicUrl);
    } catch (e) {
      print('❌ TrackCard: Playback error: $e');
      if (mounted) {
        String errorMessage = 'Playback failed';
        if (e.toString().contains('No audio URL')) {
          errorMessage = 'Track not ready yet - please wait for generation to complete';
        } else if (e.toString().contains('unsupported')) {
          errorMessage = 'Audio format not supported';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _audioService.playerStateStream,
      builder: (context, snapshot) {
        final isCurrentTrack = _audioService.isTrackLoaded(widget.song.id);
        final isPlaying = _audioService.isTrackPlaying(widget.song.id);
        
        return Card(
          color: isCurrentTrack ? Colors.grey.shade800 : Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  widget.song.title.isNotEmpty ? widget.song.title : 'Untitled',
                  style: TextStyle(
                    color: isCurrentTrack ? Colors.white : Colors.grey.shade300,
                    fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Manrope',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Status indicator for tracks without audio URL
                if (widget.song.publicUrl.isEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      color: Colors.orange.shade400,
                      fontSize: 12,
                      fontFamily: 'Manrope',
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Play button with gradient when playing
                Container(
                  decoration: BoxDecoration(
                    gradient: isPlaying ? const LinearGradient(
                      colors: [Color(0xFFFF4AE2), Color(0xFF7A4BFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ) : null,
                    color: isPlaying ? null : Colors.grey.shade800,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isLoading || widget.song.publicUrl.isEmpty ? null : _togglePlayback,
                    icon: _isLoading 
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white, 
                            strokeWidth: 2,
                          ),
                        )
                      : widget.song.publicUrl.isEmpty
                        ? Icon(
                            Icons.hourglass_empty,
                            color: Colors.grey.shade500,
                            size: 28,
                          )
                        : Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
                
                // Progress bar for current track
                if (isCurrentTrack) ...[
                  const SizedBox(height: 8),
                  StreamBuilder<Duration>(
                    stream: _audioService.positionStream,
                    builder: (context, positionSnapshot) {
                      return StreamBuilder<Duration?>(
                        stream: _audioService.durationStream,
                        builder: (context, durationSnapshot) {
                          final position = positionSnapshot.data ?? Duration.zero;
                          final duration = durationSnapshot.data ?? Duration.zero;
                          final progress = duration.inMilliseconds > 0 
                              ? position.inMilliseconds / duration.inMilliseconds 
                              : 0.0;
                              
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: Colors.grey.shade700,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF4AE2),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
