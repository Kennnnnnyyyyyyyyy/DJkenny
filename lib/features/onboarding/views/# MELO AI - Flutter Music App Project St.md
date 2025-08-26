# MELO AI - Flutter Music App Project Structure

## 📁 Complete Directory Structure

```
music_app/
├── android/                           # Android platform files
├── ios/                              # iOS platform files
├── lib/                              # Main Dart source code
│   ├── core/                         # Core utilities and configurations
│   │   ├── router/
│   │   │   └── app_router.dart       # GoRouter configuration
│   │   └── theme/
│   │       └── app_theme.dart        # App theming and colors
│   ├── data/                         # Data layer (Repository pattern)
│   │   └── repo/
│   │       └── music_repo.dart       # Music data repository
│   ├── features/                     # Feature-based architecture
│   │   ├── auth/                     # Authentication feature
│   │   │   ├── models/
│   │   │   │   └── user_model.dart   # User data model
│   │   │   ├── services/
│   │   │   │   └── auth_service.dart # Authentication service
│   │   │   └── views/
│   │   │       ├── login_page.dart   # Login screen UI
│   │   │       └── signup_page.dart  # Signup screen UI
│   │   ├── home/                     # Home feature
│   │   │   └── views/
│   │   │       └── home_page.dart    # Main home screen
│   │   └── onboarding/               # Onboarding feature
│   │       └── views/
│   │           ├── onboarding_page_1.dart  # Welcome screen
│   │           ├── onboarding_page_2.dart  # Feature introduction
│   │           └── onboarding_page_3.dart  # Interactive song creation
│   ├── onboarding/                   # Onboarding services
│   │   └── onboarding_service.dart   # Track fetching service
│   ├── ui/                          # Shared UI components
│   │   └── widgets/
│   │       └── circular_album_player.dart # Custom audio player widget
│   └── main.dart                    # App entry point
├── assets/                          # Static assets
│   ├── images/
│   └── fonts/
├── pubspec.yaml                     # Dependencies and project config
└── README.md                        # Project documentation
```

## 📋 Detailed File Analysis

### 🎯 Core Files

#### `lib/main.dart`
- **Purpose**: App entry point and initialization
- **Type**: Entry Point
- **Contents**: 
  - Supabase initialization
  - GoRouter setup
  - MaterialApp configuration
  - Theme application
- **Key Features**: Sets up the entire app foundation with routing and database connection

#### `lib/core/router/app_router.dart`
- **Purpose**: Centralized navigation configuration using GoRouter
- **Type**: Navigation Logic
- **Routes**:
  - `/` → Home page
  - `/onboarding1` → First onboarding screen
  - `/onboarding2` → Second onboarding screen  
  - `/onboarding3` → Interactive song creation
  - `/login` → Authentication
  - `/signup` → User registration
- **Navigation Pattern**: Declarative routing with path-based navigation

#### `lib/core/theme/app_theme.dart`
- **Purpose**: Centralized theming and design system
- **Type**: UI Configuration
- **Theme Colors**:
  - Primary gradient: Pink (`#FF4AE2`) to Purple (`#7A4BFF`)
  - Background: Gradient-based dark theme
  - Font: SF Pro Display family
- **Components**: Custom button styles, text themes, color schemes

### 🎵 Audio & Music Features

#### `lib/ui/widgets/circular_album_player.dart`
- **Purpose**: Custom circular audio player with seek functionality
- **Type**: UI Widget (Reusable Component)
- **Contains**:
  - `CircularAlbumPlayer` - Main player widget
  - `_RingSeekBar` - Touch-based circular seek control
  - `_RingPainter` - Custom gradient progress ring painting
  - `PositionData` - Audio position state model
- **Features**:
  - Circular progress visualization with gradient
  - +5/-5 second skip buttons (replaced next/prev)
  - Touch-based seeking around the circle
  - Album art display with network image caching
  - Play/pause with smooth animations
  - Continue button with gradient styling
- **Audio Integration**: Uses `just_audio` package with `audio_session`
- **Dependencies**: `cached_network_image`, `rxdart` for streams

#### `lib/data/repo/music_repo.dart`
- **Purpose**: Data repository for music-related operations
- **Type**: Data Layer (Repository Pattern)
- **Responsibilities**:
  - Supabase database interactions
  - Track fetching and filtering
  - Cover art generation
  - Audio URL management
- **Integration**: Works with onboarding service for track selection

#### `lib/onboarding/onboarding_service.dart`
- **Purpose**: Business logic for onboarding track selection
- **Type**: Service Layer
- **Functions**:
  - `findTrackFromChoices()` - Matches user preferences to available tracks
  - Database querying based on mood, genre, and topic
  - Track model mapping and URL handling
- **Data Flow**: Connects UI choices to database tracks via repository

### 🚀 Onboarding Flow Analysis

#### Navigation Structure
The onboarding follows a **linear progression** with **GoRouter-based navigation**:

```
Onboarding Flow:
Page 1 (Welcome) → Page 2 (Features) → Page 3 (Interactive) → Upgrade → Home
```

#### `lib/features/onboarding/views/onboarding_page_1.dart`
- **Purpose**: Welcome screen with app introduction
- **Type**: UI View (Stateless)
- **Content**:
  - MELO AI branding
  - Welcome message
  - "Get Started" button
- **Navigation**: Routes to `/onboarding2` using `context.go()`
- **Design**: Gradient background matching app theme

#### `lib/features/onboarding/views/onboarding_page_2.dart`
- **Purpose**: Feature showcase and value proposition
- **Type**: UI View (Stateless)
- **Content**:
  - Feature highlights (AI generation, voice cloning, etc.)
  - "Try Now" call-to-action button
- **Navigation**: Routes to `/onboarding3` for interactive experience
- **Design**: Card-based feature list with icons and descriptions

#### `lib/features/onboarding/views/onboarding_page_3.dart` ⭐
- **Purpose**: Interactive song creation experience
- **Type**: UI View (Complex Stateful)
- **State Management**: Local state with `setState()` - no external state management
- **Flow Structure**:

```
Chat-based Interaction Flow:
1. Welcome → "Sure, sounds fun!"
2. Mood Selection → ["Motivational", "Chill", "Happy"]
3. Genre Selection → ["K-Pop", "Rap", "Rock", "Pop"]  
4. Subject Selection → ["My pet", "My future self", "My love"]
5. Song Creation → Loading → Audio Player
6. Upgrade Prompt → Payment Options → Home
```

- **Contains**:
  - `_OnboardingPage3State` - Main state management
  - `ChatMessage` - Message data model
  - `MessageType` enum - Different message types
  - `_ChatParticlePainter` - Animated background particles
  - `_PsychedelicWaveVisualizer` - Audio-reactive background
  - `_PsychedelicWavePainter` - Custom wave animations

- **Key Features**:
  - **Chat Interface**: Simulated conversation with AI
  - **Choice System**: Multiple-choice buttons for user preferences
  - **Real-time Creation**: Integrates with Supabase to fetch matching tracks
  - **Audio Player Integration**: Uses `CircularAlbumPlayer` for playback
  - **Upgrade Flow**: Leads to subscription modal
  - **Visual Effects**: Psychedelic waves during song playback
  - **State Flags**: `_isProcessingChoice`, `_upgradeFlowShown` to prevent duplicate actions

- **Navigation Logic**:
  - Choice buttons clear messages and transition between steps
  - Continue button triggers upgrade flow
  - Subscription modal navigates to home (`context.go('/')`)
  - Handles both purchase and skip scenarios

- **Audio Integration**:
  - Fetches tracks from Supabase based on user choices
  - Maps UI selections to database keys
  - Handles cover art generation if missing
  - Manages playback state and audio session

### 🔐 Authentication Features

#### `lib/features/auth/views/login_page.dart`
- **Purpose**: User authentication interface
- **Type**: UI View
- **Integration**: Supabase Auth
- **Navigation**: Routes to home on successful login

#### `lib/features/auth/views/signup_page.dart`
- **Purpose**: User registration interface  
- **Type**: UI View
- **Integration**: Supabase Auth
- **Flow**: Registration → Email verification → Home

#### `lib/features/auth/services/auth_service.dart`
- **Purpose**: Authentication business logic
- **Type**: Service Layer
- **Functions**: Login, signup, logout, session management

### 🏠 Home Features

#### `lib/features/home/views/home_page.dart`
- **Purpose**: Main application dashboard
- **Type**: UI View
- **Expected Features**: Music library, creation tools, user profile
- **Navigation**: Central hub after onboarding completion

## 🔧 Technical Architecture

### State Management
- **Pattern**: Local State with `setState()`
- **No External Library**: No Provider, Riverpod, or Bloc detected
- **Scope**: Each page manages its own state independently
- **Data Flow**: Service layer → Repository → UI with manual state updates

### Navigation System
- **Library**: GoRouter (declarative routing)
- **Pattern**: Path-based navigation with `context.go()`
- **Structure**: Flat route structure, no nested routing
- **Navigation Style**: Linear progression for onboarding, direct navigation elsewhere

### Data Layer
- **Backend**: Supabase (PostgreSQL)
- **Pattern**: Repository pattern with service layer
- **Audio Storage**: Supabase Storage for track files and cover art
- **Caching**: Network image caching for album artwork

### Audio System
- **Library**: `just_audio` with `audio_session`
- **Features**: Streaming, seeking, session management
- **UI Integration**: Custom circular player with touch controls
- **Background**: Proper audio session handling for iOS/Android

### Design System
- **Theme**: Pink-to-purple gradient throughout
- **Typography**: SF Pro Display font family
- **Components**: Consistent button styling with gradient backgrounds
- **Animations**: Custom painters for visual effects and particle systems

## 🎯 Key Integration Points

1. **Onboarding → Audio**: Page 3 integrates user choices with track database
2. **Audio → Navigation**: Player continue button triggers upgrade flow
3. **Upgrade → Subscription**: Modal system with payment integration setup
4. **Auth → Home**: Authentication gates access to main features
5. **Repository → Service**: Clean separation between data and business logic

## 🔄 Current Navigation Flow

```
App Launch → Onboarding 1 → Onboarding 2 → Onboarding 3
                                              ↓
                                        (User creates song)
                                              ↓
                                        Continue button
                                              ↓
                                        Upgrade prompt
                                              ↓
                                    [Subscription Modal]
                                    ↙              ↘
                            "Start Trial"    "Continue Free"
                                    ↓              ↓
                                  Home ←----------┘
```

## 🚨 Current Issues & Observations

1. **TestFlight Navigation**: Continue button works in simulator but not on TestFlight
2. **Duplicate State**: Some upgrade flow triggers happening multiple times
3. **State Management**: Could benefit from centralized state management for complex flows
4. **Error Handling**: Limited error handling in audio playback and network requests

This structure follows a **feature-based architecture** with clear separation of concerns, making it maintainable and scalable for a music creation app.