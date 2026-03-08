# Socolive Clone

A simple Flutter app that clones the Socolive sports streaming functionality.

## Features

- View live matches by date
- See available streamers for each match
- Play live streams using HLS/M3U8

## API Endpoints Used

- Match List: `https://json.vnres.co/match/matches_{YYYYMMDD}.json`
- Room Detail: `https://json.vnres.co/room/{roomId}/detail.json`
- Stream URLs: `https://pull.niues.live/live/stream-{roomId}_{quality}.m3u8`

## Getting Started

1. Install Flutter SDK (https://docs.flutter.dev/get-started/install)

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on Linux:
   ```bash
   flutter run -d linux
   ```

4. Or build for Linux:
   ```bash
   flutter build linux
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── match.dart           # Match & Anchor models
│   └── stream.dart          # Stream & RoomDetail models
├── services/
│   └── api_service.dart     # HTTP API client
├── controllers/
│   └── match_controller.dart # State management
└── screens/
    ├── home_screen.dart         # Match list view
    ├── match_detail_screen.dart # Streamers list
    └── video_player_screen.dart # Video playback
```

## Dependencies

- `http` - HTTP client
- `video_player` - Video playback
- `chewie` - Video player UI controls
- `provider` - State management
- `cached_network_image` - Image caching
- `intl` - Date formatting

## Notes

- Auth keys in stream URLs expire after some time
- The app uses Provider for simple state management
- Video player supports HLS (M3U8) format
