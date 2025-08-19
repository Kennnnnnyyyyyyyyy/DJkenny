import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logging/logger.dart';
import '../../../domain/models/chat_message.dart';
import '../../../domain/models/track.dart';
import '../../../data/repositories/music_repository.dart';
import '../../../app/di.dart';

/// Current step in the onboarding flow
enum OnboardingStep {
  intro,
  moodSelection,
  genreSelection,
  subjectSelection,
  creating,
  songCreated,
  upgradeFlow,
  payment,
}

/// State for the onboarding flow
class OnboardingState {
  final List<ChatMessage> messages;
  final OnboardingStep currentStep;
  final String? selectedMood;
  final String? selectedGenre;
  final String? selectedSubject;
  final AsyncValue<Track?> currentTrack;
  final bool isProcessingChoice;
  final bool upgradeFlowShown;
  final bool showPsychedelicBackground;
  final String? error;

  const OnboardingState({
    required this.messages,
    required this.currentStep,
    this.selectedMood,
    this.selectedGenre,
    this.selectedSubject,
    required this.currentTrack,
    required this.isProcessingChoice,
    required this.upgradeFlowShown,
    required this.showPsychedelicBackground,
    this.error,
  });

  /// Initial state
  factory OnboardingState.initial() => const OnboardingState(
        messages: [],
        currentStep: OnboardingStep.intro,
        selectedMood: null,
        selectedGenre: null,
        selectedSubject: null,
        currentTrack: AsyncValue.data(null),
        isProcessingChoice: false,
        upgradeFlowShown: false,
        showPsychedelicBackground: false,
        error: null,
      );

  /// Create a copy with updated values
  OnboardingState copyWith({
    List<ChatMessage>? messages,
    OnboardingStep? currentStep,
    String? selectedMood,
    String? selectedGenre,
    String? selectedSubject,
    AsyncValue<Track?>? currentTrack,
    bool? isProcessingChoice,
    bool? upgradeFlowShown,
    bool? showPsychedelicBackground,
    String? error,
  }) {
    return OnboardingState(
      messages: messages ?? this.messages,
      currentStep: currentStep ?? this.currentStep,
      selectedMood: selectedMood ?? this.selectedMood,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      currentTrack: currentTrack ?? this.currentTrack,
      isProcessingChoice: isProcessingChoice ?? this.isProcessingChoice,
      upgradeFlowShown: upgradeFlowShown ?? this.upgradeFlowShown,
      showPsychedelicBackground: showPsychedelicBackground ?? this.showPsychedelicBackground,
      error: error,
    );
  }

  /// Clear error
  OnboardingState clearError() => copyWith(error: null);

  /// Check if all choices have been made
  bool get hasAllChoices => selectedMood != null && selectedGenre != null && selectedSubject != null;

  /// Check if track is ready
  bool get hasTrack => currentTrack.value != null;

  /// Check if creating track
  bool get isCreatingTrack => currentTrack.isLoading;

  /// Get track or null
  Track? get track => currentTrack.value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          messages.length == other.messages.length &&
          currentStep == other.currentStep &&
          selectedMood == other.selectedMood &&
          selectedGenre == other.selectedGenre &&
          selectedSubject == other.selectedSubject &&
          currentTrack == other.currentTrack &&
          isProcessingChoice == other.isProcessingChoice &&
          upgradeFlowShown == other.upgradeFlowShown &&
          showPsychedelicBackground == other.showPsychedelicBackground &&
          error == other.error;

  @override
  int get hashCode =>
      messages.length.hashCode ^
      currentStep.hashCode ^
      selectedMood.hashCode ^
      selectedGenre.hashCode ^
      selectedSubject.hashCode ^
      currentTrack.hashCode ^
      isProcessingChoice.hashCode ^
      upgradeFlowShown.hashCode ^
      showPsychedelicBackground.hashCode ^
      error.hashCode;

  @override
  String toString() {
    return 'OnboardingState(step: $currentStep, mood: $selectedMood, genre: $selectedGenre, subject: $selectedSubject, track: ${track?.title}, upgradeShown: $upgradeFlowShown)';
  }
}

/// ViewModel for onboarding functionality
class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final MusicRepository _musicRepository;

  OnboardingViewModel(this._musicRepository) : super(OnboardingState.initial()) {
    _startChat();
  }

  /// Start the chat flow
  void _startChat() {
    Logger.d('Starting onboarding chat flow', tag: 'ONBOARDING_VM');
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _addMessage(ChatMessage.systemText("Hey there! 👋 I'm excited to help you create your first AI song!"));
      
      Future.delayed(const Duration(milliseconds: 1200), () {
        _addMessage(ChatMessage.systemText("Think about it like this - I'm your personal music producer, and we're about to cook up something amazing together."));
        
        Future.delayed(const Duration(milliseconds: 1800), () {
          _addMessage(ChatMessage.systemText("Ready to see what we can create? This should be fun! 🎵"));
          
          Future.delayed(const Duration(milliseconds: 1000), () {
            _addMessage(ChatMessage.choices(["Sure, sounds fun!"]));
            state = state.copyWith(currentStep: OnboardingStep.moodSelection);
          });
        });
      });
    });
  }

  /// Add a message to the chat
  void _addMessage(ChatMessage message) {
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
    Logger.d('Added message: ${message.type} - "${message.text}"', tag: 'ONBOARDING_VM');
  }

  /// Clear all messages
  void _clearMessages() {
    state = state.copyWith(messages: []);
    Logger.d('Cleared all messages', tag: 'ONBOARDING_VM');
  }

  /// Handle user choice selection
  Future<void> handleChoice(String choice) async {
    if (state.isProcessingChoice) {
      Logger.w('Already processing choice, ignoring', tag: 'ONBOARDING_VM');
      return;
    }

    Logger.d('Handling choice: "$choice" in step: ${state.currentStep}', tag: 'ONBOARDING_VM');
    state = state.copyWith(isProcessingChoice: true, error: null);

    try {
      // Add user message
      _addMessage(ChatMessage.userText(choice));

      // Process based on current step
      switch (state.currentStep) {
        case OnboardingStep.moodSelection:
          await _handleMoodSelection(choice);
          break;
        case OnboardingStep.genreSelection:
          await _handleGenreSelection(choice);
          break;
        case OnboardingStep.subjectSelection:
          await _handleSubjectSelection(choice);
          break;
        default:
          Logger.w('Unhandled choice in step: ${state.currentStep}', tag: 'ONBOARDING_VM');
      }
    } catch (e, st) {
      Logger.e('Error handling choice', error: e, stackTrace: st, tag: 'ONBOARDING_VM');
      state = state.copyWith(error: 'Failed to process choice: ${e.toString()}');
    } finally {
      state = state.copyWith(isProcessingChoice: false);
    }
  }

  Future<void> _handleMoodSelection(String choice) async {
    if (choice == "Sure, sounds fun!") {
      _clearMessages();
      
      await Future.delayed(const Duration(milliseconds: 500));
      _addMessage(ChatMessage.systemText("Perfect! Let's start with the vibe. What mood are you feeling today?"));
      
      await Future.delayed(const Duration(milliseconds: 800));
      _addMessage(ChatMessage.choices(["Motivational", "Chill", "Happy"]));
      
      state = state.copyWith(currentStep: OnboardingStep.genreSelection);
    } else {
      // User selected a mood
      state = state.copyWith(selectedMood: choice);
      _clearMessages();
      
      await Future.delayed(const Duration(milliseconds: 500));
      _addMessage(ChatMessage.systemText("Nice choice! $choice vibes it is. Now, what's your style?"));
      
      await Future.delayed(const Duration(milliseconds: 800));
      _addMessage(ChatMessage.choices(["K-Pop", "Rap", "Rock", "Pop"]));
      
      state = state.copyWith(currentStep: OnboardingStep.subjectSelection);
    }
  }

  Future<void> _handleGenreSelection(String choice) async {
    state = state.copyWith(selectedGenre: choice);
    _clearMessages();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _addMessage(ChatMessage.systemText("$choice! Great taste. Last question - what should this song be about?"));
    
    await Future.delayed(const Duration(milliseconds: 800));
    _addMessage(ChatMessage.choices(["My pet", "My future self", "My love"]));
    
    state = state.copyWith(currentStep: OnboardingStep.creating);
  }

  Future<void> _handleSubjectSelection(String choice) async {
    state = state.copyWith(selectedSubject: choice);
    _clearMessages();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _addMessage(ChatMessage.systemText("Perfect! Let me cook up a ${state.selectedMood} ${state.selectedGenre} song about $choice..."));
    
    await Future.delayed(const Duration(milliseconds: 800));
    _addMessage(ChatMessage.creating());
    
    state = state.copyWith(
      currentStep: OnboardingStep.songCreated,
      showPsychedelicBackground: true,
    );
    
    // Start creating the song
    await _createSong();
  }

  /// Create song based on selections
  Future<void> _createSong() async {
    try {
      Logger.d('Creating song with choices: mood=${state.selectedMood}, genre=${state.selectedGenre}, subject=${state.selectedSubject}', tag: 'ONBOARDING_VM');
      
      state = state.copyWith(currentTrack: const AsyncValue.loading());
      
      final result = await _musicRepository.findTrackFromChoices(
        mood: state.selectedMood,
        genre: state.selectedGenre,
        subject: state.selectedSubject,
      );
      
      result.fold(
        (error) {
          Logger.e('Failed to create song', error: error, tag: 'ONBOARDING_VM');
          state = state.copyWith(
            currentTrack: AsyncValue.error(error, StackTrace.current),
            error: error.message,
          );
        },
        (track) {
          Logger.d('Song created successfully: ${track.title}', tag: 'ONBOARDING_VM');
          state = state.copyWith(currentTrack: AsyncValue.data(track));
          
          // Clear creating message and add song created
          _clearMessages();
          _addMessage(ChatMessage.songCreated());
        },
      );
    } catch (e, st) {
      Logger.e('Unexpected error creating song', error: e, stackTrace: st, tag: 'ONBOARDING_VM');
      state = state.copyWith(
        currentTrack: AsyncValue.error(e, st),
        error: 'Failed to create song: ${e.toString()}',
      );
    }
  }

  /// Navigate to upgrade flow
  void navigateToUpgrade() {
    if (state.upgradeFlowShown) {
      Logger.w('Upgrade flow already shown, ignoring', tag: 'ONBOARDING_VM');
      return;
    }

    Logger.d('Navigating to upgrade flow', tag: 'ONBOARDING_VM');
    
    state = state.copyWith(
      upgradeFlowShown: true,
      currentStep: OnboardingStep.upgradeFlow,
      showPsychedelicBackground: false,
    );
    
    _showUpgradeFlow();
  }

  /// Show upgrade flow
  void _showUpgradeFlow() {
    _clearMessages();
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _addMessage(ChatMessage.systemText("Unlock Full Potential — here's what you get:"));
      
      Future.delayed(const Duration(milliseconds: 800), () {
        _addMessage(ChatMessage.upgrade());
        
        Future.delayed(const Duration(milliseconds: 2000), () {
          _addMessage(ChatMessage.systemText("How does it sound?"));
          
          Future.delayed(const Duration(milliseconds: 800), () {
            _addMessage(ChatMessage.payment());
            state = state.copyWith(currentStep: OnboardingStep.payment);
          });
        });
      });
    });
  }

  /// Handle payment choice
  void handlePaymentChoice(String choice) {
    Logger.d('Handling payment choice: $choice', tag: 'ONBOARDING_VM');
    
    // This will be handled by navigation in the UI
    // The ViewModel just tracks that the flow is complete
  }

  /// Reset onboarding state
  void reset() {
    Logger.d('Resetting onboarding state', tag: 'ONBOARDING_VM');
    state = OnboardingState.initial();
    _startChat();
  }

  /// Clear any error state
  void clearError() {
    state = state.clearError();
  }

  @override
  void dispose() {
    Logger.d('Disposing OnboardingViewModel', tag: 'ONBOARDING_VM');
    super.dispose();
  }
}

/// Provider for OnboardingViewModel
final onboardingViewModelProvider = StateNotifierProvider.autoDispose<OnboardingViewModel, OnboardingState>((ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return OnboardingViewModel(musicRepository);
});
