# Socolive APK Reverse Engineering Report

## App Information
- **Package Name**: `com.bongda.socolive.app`
- **App Name**: Socolive.app
- **Type**: Flutter Application (Sports Streaming)

## Decompiled Output Locations
```
decompiled_output/
├── apktool_out/     # Resources, manifest, smali code, assets
├── jadx_out/        # Java/Kotlin source code
```

## App Architecture (Dart/Flutter Structure)

### Main Entry Point
- `package:socolive3/main.dart` - Application entry
- `package:socolive3/global_binding.dart` - Dependency injection bindings

### Screens (UI Layer)
- `screen/home_screen.dart` - Main home screen
- `screen/main_screen.dart` - Main navigation container
- `screen/main_controller.dart` - Main navigation logic
- `screen/live/live_screen.dart` - Live streaming screen
- `screen/live/live_controller.dart` - Live streaming logic
- `screen/live/match_detail_screen.dart` - Match details view
- `screen/live/watch_screen.dart` - Video player screen
- `screen/news/news_screen.dart` - News section
- `screen/result/result_screen.dart` - Match results
- `screen/8xbet/bet_controller.dart` - Betting integration
- `screen/8xbet/fb88_screen.dart` - FB88 betting screen
- `screen/odds/debet_screen.dart` - Odds/betting screen

### Models (Data Layer)
- `model/channel.dart` - Channel data model
- `model/ConfigData.dart` - App configuration
- `model/detail/` - Stream detail models (Anchor, Room, Stream, etc.)
- `model/match/` - Match data models
- `model/result/ResultMatchResponse.dart` - Match results

### Services (API Layer)
- `service/http_service.dart` - HTTP service interface
- `service/http_service_impl.dart` - HTTP implementation
- `service/restful_data_provider.dart` - Data provider
- `service/restful_data_provider_implement.dart` - Implementation

### Repositories
- `repository/live/live_repo.dart` - Live streaming repository
- `repository/result/result_repo.dart` - Results repository

### Widgets
- `widget/app_utils.dart` - Utility functions
- `widget/common_screen.dart` - Common screen components
- `widget/common_image_network.dart` - Network image handling

## Discovered API Endpoints

### Main API
- `https://json.vnres.co/match/matches_` - Match data API
- `https://json.vnres.co/room/` - Room/stream data
- `https://fast.besoccer.com/scripts/api/api.php?` - Soccer data API

### Remote Configuration
- `https://xemmienphi.xyz/app/bongda/config.json` - App configuration

### Config Structure (from remote config)
```json
{
    "domainSocolive": "https://bit.ly/socolive",
    "domainFB88": "https://www.fb88affcn.com/Track?aID=2695",
    "domainOdds": "https://xemmienphi.xyz/app/bongda/fb88.gif",
    "isBet": true,
    "appUrl": "https://xemmienphi.xyz/app/socolive.apk",
    "code": 5,
    "domainKNC": "https://keonhacai55.click/",
    "domainDebet": "https://www.fb88affcn.com/Track?aID=2695"
}
```

## Third-Party Packages Used
- `video_player_android` - Video playback
- `flick_video_player` - Video player UI
- `flutter_inappwebview` - WebView for embedded content
- `dio` - HTTP client
- `get` (GetX) - State management
- `rxdart` - Reactive programming
- `sqflite` - SQLite database
- `google_fonts` - Custom fonts
- `fluttertoast` - Toast notifications
- `wakelock_plus` - Keep screen on
- `ota_update` - Over-the-air updates

## Key Features Identified
1. **Live Sports Streaming** - Main functionality
2. **Match Results/Scores** - Sports data display
3. **News Section** - Sports news
4. **Betting Integration** - FB88, 8xbet, Debet affiliate links
5. **OTA Updates** - Self-update capability
6. **Deep Linking** - `trauscore-dec41.web.app`

## Native Libraries
- `libflutter.so` (10.5MB) - Flutter engine
- `libapp.so` (7MB) - Compiled Dart application code

## Important Files to Analyze
1. `decompiled_output/apktool_out/AndroidManifest.xml` - Permissions & components
2. `decompiled_output/apktool_out/assets/flutter_assets/` - App assets
3. `decompiled_output/jadx_out/sources/` - Java/Kotlin code
4. `decompiled_output/apktool_out/lib/arm64-v8a/libapp.so` - Dart binary (use strings analysis)

## Tools for Further Analysis

### For Dart Code (libapp.so)
```bash
# Extract strings from compiled Dart
strings decompiled_output/apktool_out/lib/arm64-v8a/libapp.so | grep -E "package:socolive"

# Extract URLs
strings decompiled_output/apktool_out/lib/arm64-v8a/libapp.so | grep -E "https?://"
```

### For Dynamic Analysis
- **reFlutter**: Specialized Flutter reverse engineering tool
- **Frida**: Dynamic instrumentation
- **objection**: Runtime exploration

### Install reFlutter (for deeper analysis)
```bash
pip3 install reflutter
reflutter socolive102.apk
```

## Permissions Required
- `INTERNET` - Network access
- `ACCESS_NETWORK_STATE` - Network status
- `ACCESS_WIFI_STATE` - WiFi status
- `READ_EXTERNAL_STORAGE` - File access
- `WRITE_EXTERNAL_STORAGE` - File writing
- `REQUEST_INSTALL_PACKAGES` - APK installation (for OTA updates)
