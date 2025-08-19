import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logging/logger.dart';
import '../../../domain/models/track.dart';
import '../viewmodels/player_viewmodel.dart';
import '../widgets/circular_album_player_mvvm.dart';

/// MVVM version of PlayerPage using ViewModels for state management
class PlayerPageMVVM extends ConsumerStatefulWidget {
  final Track track;
  final VoidCallback? onBack;
  final VoidCallback? onFinished;

  const PlayerPageMVVM({
    super.key,
    required this.track,
    this.onBack,
    this.onFinished,
  });

  @override
  ConsumerState<PlayerPageMVVM> createState() => _PlayerPageMVVMState();
}

class _PlayerPageMVVMState extends ConsumerState<PlayerPageMVVM> {
  @override
  void initState() {
    super.initState();
    Logger.d('Initializing PlayerPageMVVM for track: ${widget.track.title}', tag: 'PLAYER_UI');
  }

  @override
  void dispose() {
    Logger.d('Disposing PlayerPageMVVM', tag: 'PLAYER_UI');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              _buildHeader(),
              
              // Main player content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: CircularAlbumPlayerMVVM(
                      track: widget.track,
                      onFinished: widget.onFinished,
                    ),
                  ),
                ),
              ),
              
              // Additional controls or information
              _buildBottomSection(playerState),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF1A1A2E),
          Color(0xFF16213E),
          Color(0xFF0F3460),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: IconButton(
              onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
          ),
          
          // Title
          Expanded(
            child: Text(
              'Now Playing',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Menu button (placeholder)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: IconButton(
              onPressed: () => _showPlayerMenu(),
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(PlayerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Volume control
          _buildVolumeControl(state),
          
          const SizedBox(height: 16),
          
          // Additional actions
          _buildAdditionalActions(),
        ],
      ),
    );
  }

  Widget _buildVolumeControl(PlayerState state) {
    return Row(
      children: [
        Icon(
          Icons.volume_down,
          color: Colors.white.withOpacity(0.7),
        ),
        Expanded(
          child: Slider(
            value: state.volume,
            min: 0.0,
            max: 1.0,
            activeColor: const Color(0xFFFF4AE2),
            inactiveColor: Colors.white.withOpacity(0.3),
            onChanged: (value) {
              ref.read(playerViewModelProvider.notifier).setVolume(value);
            },
          ),
        ),
        Icon(
          Icons.volume_up,
          color: Colors.white.withOpacity(0.7),
        ),
      ],
    );
  }

  Widget _buildAdditionalActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Share button
        _buildActionButton(
          icon: Icons.share,
          onPressed: () => _shareTrack(),
        ),
        
        // Favorite button
        Consumer(
          builder: (context, ref, child) {
            final playerState = ref.watch(playerViewModelProvider);
            return _buildActionButton(
              icon: playerState.isFavorite ? Icons.favorite : Icons.favorite_border,
              onPressed: () => ref.read(playerViewModelProvider.notifier).toggleFavorite(),
              color: playerState.isFavorite ? Colors.red : null,
            );
          },
        ),
        
        // Download button
        _buildActionButton(
          icon: Icons.download,
          onPressed: () => _downloadTrack(),
        ),
        
        // Add to playlist button
        _buildActionButton(
          icon: Icons.playlist_add,
          onPressed: () => _showAddToPlaylistDialog(),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color ?? Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  void _showPlayerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('Track Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showTrackInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.equalizer, color: Colors.white),
              title: const Text('Equalizer', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEqualizer();
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer, color: Colors.white),
              title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSleepTimer();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareTrack() {
    Logger.d('Sharing track: ${widget.track.title}', tag: 'PLAYER_UI');
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _downloadTrack() {
    Logger.d('Downloading track: ${widget.track.title}', tag: 'PLAYER_UI');
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon!')),
    );
  }

  void _showAddToPlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Add to Playlist', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Playlist functionality coming soon!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTrackInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Track Information', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Title', widget.track.title),
            _buildInfoRow('Artist', 'Melo AI'),
            _buildInfoRow('ID', widget.track.id),
            if (widget.track.coverUrl?.isNotEmpty == true)
              _buildInfoRow('Cover URL', widget.track.coverUrl!),
            _buildInfoRow('Audio URL', widget.track.audioUrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showEqualizer() {
    Logger.d('Opening equalizer', tag: 'PLAYER_UI');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Equalizer coming soon!')),
    );
  }

  void _showSleepTimer() {
    Logger.d('Opening sleep timer', tag: 'PLAYER_UI');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep timer coming soon!')),
    );
  }
}
