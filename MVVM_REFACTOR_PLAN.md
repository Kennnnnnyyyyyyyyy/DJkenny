# MELO AI - MVVM Refactor Implementation Plan

## Phase 1: Setup Foundation ✅
- [x] Add required dependencies (Riverpod already present)
- [ ] Create new directory structure 
- [ ] Implement Result<T> and AppException types
- [ ] Setup DI container with providers
- [ ] Create base ViewModels and States

## Phase 2: Core Services & Repositories
- [ ] Extract AudioService from just_audio
- [ ] Refactor MusicRepository with Result<T>
- [ ] Create AuthRepository with Supabase
- [ ] Setup logging and error handling

## Phase 3: Auth Feature (Simplest)
- [ ] Create AuthViewModel with AsyncValue<User?>
- [ ] Wire up login/signup pages to AuthViewModel
- [ ] Add router guards

## Phase 4: Audio Player System
- [ ] Create PlayerViewModel with AudioService
- [ ] Refactor CircularAlbumPlayer to be stateless
- [ ] Wire audio state through providers

## Phase 5: Onboarding (Most Complex)
- [ ] Create OnboardingViewModel
- [ ] Move all setState logic to ViewModel
- [ ] Wire up chat messages and choices
- [ ] Fix TestFlight navigation issue

## Phase 6: Testing & Cleanup
- [ ] Add unit tests for ViewModels
- [ ] Test on simulators and TestFlight
- [ ] Remove old files and dead code

## Current Issues to Address:
1. TestFlight continue button navigation
2. Duplicate upgrade flow triggers
3. State management complexity in onboarding_page_3.dart
4. Direct audio player usage in widgets

## Migration Strategy:
- Keep old files alongside new ones during transition
- Test each phase thoroughly before proceeding
- Use feature flags if needed for gradual rollout
