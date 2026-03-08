# Socolive Flutter App - Dart Code Analysis

## Blutter Analysis Complete

**Dart Version**: 3.7.0
**Snapshot Hash**: d91c0e6f35f0eb2e44124e8f42aa44a7
**Target**: android arm64

---

## App Structure (socolive3 package)

### Entry Point: `main.dart`
```
main() async {
  WidgetsFlutterBinding.ensureInitialized()
  SystemChrome.setPreferredOrientations([portraitUp])
  InAppWebViewController.setWebContentsDebuggingEnabled()
  SystemChrome.setSystemUIOverlayStyle()
  InternetConnectionChecker.onStatusChange.listen()
  RESTfulDataProvider.shared.initProvider()
  PackageInfo.fromPlatform()
  getConfigApp()
  SettingManager.shared
  runApp(MyApp())
}
```

### Key Classes

| Class | Location | Purpose |
|-------|----------|---------|
| `MyApp` | main.dart | Main application widget (StatelessWidget) |
| `GlobalBind` | global_binding.dart | GetX dependency injection |
| `SettingManager` | manager/setting_manager.dart | App settings state |
| `RESTfulDataProvider` | service/restful_data_provider.dart | HTTP client (Dio) |
| `RESTfulDataProviderImplement` | service/restful_data_provider_implement.dart | API implementation |

### Screens Structure
```
screen/
├── main_screen.dart          # Main navigation container
├── home_screen.dart          # Home with HomeController
├── live/
│   ├── live_screen.dart      # Live matches list
│   ├── live_controller.dart
│   ├── match_detail_screen.dart  # Match details
│   ├── watch_screen.dart     # Video player
│   └── watch_controller.dart
├── news/
│   ├── news_screen.dart
│   ├── news_controller.dart
│   └── news_detail_screen.dart
├── result/
│   ├── result_screen.dart    # Match results
│   └── result_controller.dart
├── 8xbet/
│   ├── bet_controller.dart   # Betting controller
│   └── fb88_screen.dart      # FB88 betting screen
├── odds/
│   ├── debet_screen.dart     # Debet betting
│   └── odds_controller.dart
└── photoview/
    └── photo_view_screen.dart
```

### Data Models
```
model/
├── channel.dart
├── ConfigData.dart           # App configuration
├── detail/
│   ├── Anchor.dart
│   ├── Data.dart
│   ├── Detail.dart
│   ├── GrowDto.dart
│   ├── Room.dart
│   └── Stream.dart
├── match/
│   ├── Anchor.dart
│   ├── Anchors.dart
│   ├── Data.dart
│   ├── GrowDto.dart
│   └── Matches.dart
└── result/
    └── ResultMatchResponse.dart
```

---

## API Endpoints Discovered

### Primary API
| Endpoint | Purpose |
|----------|---------|
| `https://json.vnres.co/match/matches_` | Match data |
| `https://json.vnres.co/room/` | Stream room data |
| `https://fast.besoccer.com/scripts/api/api.php?` | Soccer data API |
| `https://cdn.resfu.com/img_data/equipos/` | Team images |

### Configuration
| Endpoint | Purpose |
|----------|---------|
| `https://xemmienphi.xyz/app/bongda/config.json` | Remote config |
| `https://xemmienphi.xyz/` | Base URL for Dio client |

### Betting/Affiliate Links
| URL | Purpose |
|-----|---------|
| `https://www.fb88affwc.com/Track?aID=2695` | FB88 affiliate |
| `https://m.zenandfe.com/?sportId=1&loginUrl=` | Betting redirect |
| `https://debet.mn/?invite=1054557` | Debet referral |
| `https://keonhacai.de/` | Odds site |
| `https://bit.ly/socolive` | Short link |
| `https://socolive-bongda.web.app/` | Web app / redirect |

### Test/Placeholder APIs (likely debug)
- `https://dummyapi.online/api/movies/1`
- `https://jsonplaceholder.typicode.com/albums/1`
- `https://fakestoreapi.com/products/1`

---

## Remote Config Structure (ConfigData)

```json
{
  "domainSocolive": "https://bit.ly/socolive",
  "domainFB88": "https://www.fb88affcn.com/Track?aID=2695",
  "domainWC": "...",
  "domainOdds": "https://xemmienphi.xyz/app/bongda/fb88.gif",
  "isBet": true,
  "isSubmit": false,
  "appUrl": "https://xemmienphi.xyz/app/socolive.apk",
  "forceUpdate": false,
  "forceUpdateNew": true,
  "code": 5,
  "domainKNC": "https://keonhacai55.click/",
  "domainDebet": "https://www.fb88affcn.com/Track?aID=2695"
}
```

---

## Third-Party Packages Used

| Package | Purpose |
|---------|---------|
| `get` (GetX) | State management, routing, DI |
| `dio` | HTTP client |
| `flick_video_player` | Video player UI |
| `video_player_android` | Native video playback |
| `flutter_inappwebview` | WebView for betting sites |
| `cached_network_image` | Image caching |
| `flutter_svg` | SVG support |
| `google_fonts` | Custom fonts |
| `connectivity_plus` | Network status |
| `internet_connection_checker` | Connection monitoring |
| `package_info_plus` | App version info |
| `sqflite` | SQLite database |
| `url_launcher` | Open URLs |
| `flutter_cache_manager` | Cache management |
| `ota_update` | Over-the-air updates |

---

## App Flow Analysis

### Startup Sequence
1. Initialize Flutter binding
2. Set portrait orientation
3. Enable WebView debugging
4. Setup internet connection listener
5. Initialize RESTfulDataProvider (Dio with `https://xemmienphi.xyz/`)
6. Get package info (version)
7. Fetch remote config from `config.json`
8. Update SettingManager with config values
9. Check for force update
10. Run MyApp with GetMaterialApp

### Main Features
1. **Live Streaming**: Watch live football/soccer matches
2. **Match Results**: View completed match scores
3. **News**: Sports news section
4. **Betting Integration**: FB88, Debet affiliate links
5. **OTA Updates**: Self-update from remote APK

---

## Output Files

| File | Description |
|------|-------------|
| `blutter_output/asm/` | Disassembled Dart code (ARM64) |
| `blutter_output/pp.txt` | Object pool dump (all strings, objects) |
| `blutter_output/objs.txt` | Complete object dump |
| `blutter_output/blutter_frida.js` | Frida script template |

---

## Security Observations

1. **WebView Debugging Enabled**: `InAppWebViewController.setWebContentsDebuggingEnabled()`
2. **Cleartext Traffic Allowed**: `usesCleartextTraffic="true"`
3. **OTA Updates**: Downloads APK from remote server
4. **Affiliate Tracking**: Contains multiple betting affiliate IDs
5. **Dynamic Config**: Remote config can change app behavior

---

## Developer Information

- **Source Path**: `/Users/hieulbp/StudioProjects/socolive3/`
- **Developer**: hieulbp

---

## Files Generated

```
blutter_output/
├── asm/                    # Assembly with symbols
│   ├── socolive3/         # Main app code
│   ├── flutter/           # Flutter framework
│   ├── dio/               # Dio HTTP client
│   └── ...                # Other packages
├── pp.txt                  # Object pool (1.5MB)
├── objs.txt                # Objects dump (580KB)
├── blutter_frida.js        # Frida script
└── ida_script/             # IDA Pro scripts
```
