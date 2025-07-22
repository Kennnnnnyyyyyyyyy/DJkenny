# Music App - Supabase Integration

This Flutter app is now integrated with Supabase backend for AI music generation using Suno.

## Setup Instructions

### 1. Environment Variables

Copy `.env.example` to `.env` and fill in your Supabase credentials:

```bash
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON=your-anon-key-here
```

### 2. Running the App

Run the app with your environment variables:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON=your-anon-key-here
```

### 3. Features Implemented

- ✅ Supabase client initialization
- ✅ Real-time song updates via WebSocket
- ✅ Song model and data structures
- ✅ Suno AI payload generation
- ✅ Audio playback with just_audio
- ✅ Explore page with real-time song feed
- ✅ Library page with user's songs
- ✅ Create button integration with Supabase edge functions

### 4. Backend Requirements

Your Supabase backend should have:

1. **songs** table with columns:
   - `id` (UUID, primary key)
   - `user_id` (UUID, foreign key to auth.users)
   - `title` (text)
   - `public_url` (text)
   - `style` (text)
   - `instrumental` (boolean)
   - `model` (text)
   - `status` (text)
   - `created_at` (timestamp)

2. **Edge Functions**:
   - `generate-track` - handles music generation requests
   - `suno-callback` - processes Suno AI responses

### 5. How It Works

1. User fills in prompt/lyrics and clicks "Create"
2. App sends request to `generate-track` edge function
3. Edge function calls Suno AI API
4. Suno AI generates music and calls back via webhook
5. `suno-callback` edge function uploads MP3 to Supabase Storage
6. New song row is inserted into database
7. Real-time subscription pushes update to all connected clients
8. Song appears in Explore and Library pages
9. Users can play songs directly from Supabase Storage

### 6. Authentication

Currently the app runs without authentication. To add auth:

1. Implement authentication flow in your app
2. Update `bootstrap.dart` and `realtime.dart` to handle authenticated users
3. Add user-specific features like private songs, playlists, etc.

Happy shipping! 🚀
