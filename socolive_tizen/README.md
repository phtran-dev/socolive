# Socolive TV - Samsung TV App

A Tizen web application for Samsung Smart TV to watch live sports streams.

## Features

- Browse live matches by date
- Multiple streamers per match
- HD/SD quality selection
- Samsung TV remote control support
- HLS (M3U8) streaming support

## Project Structure

```
socolive_tizen/
├── config.xml          # Tizen app configuration
├── index.html          # Main HTML file
├── css/
│   └── style.css       # TV-optimized styles (1920x1080)
├── js/
│   └── app.js          # Application logic
└── images/
    └── icon.png        # App icon (512x512)
```

## Installation Methods

### Method 1: Tizen Studio (Recommended)

1. Download Tizen Studio from https://developer.tizen.org/development/tizen-studio/download
2. Install Tizen Studio with TV SDK
3. Open Tizen Studio
4. File → Import → Existing Project
5. Select the `socolive_tizen` folder
6. Connect Samsung TV (Developer Mode enabled)
7. Right-click project → Run As → Tizen Web Application

### Method 2: Using Tizen CLI

```bash
# Install Tizen CLI
# Package the app
tizen package -t wgt -s <certificate>

# Install on TV
sdb install <app.wgt>
```

### Method 3: Test in Browser

Simply open `index.html` in Chrome browser for testing:
```bash
google-chrome index.html
```

## Enable Developer Mode on Samsung TV

1. Go to Settings → Support → About This TV
2. Press remote: Info (1), Mute (2), OK (3), Right (4), Return (5), Up (6), Down (7), Left (8)
3. Or use: Smart Hub → Apps → Settings → Developer Mode → On
4. Enter TV's IP address in Tizen Studio

## Remote Control Keys

| Key | Action |
|-----|--------|
| ◀ ▶ ▲ ▼ | Navigate |
| Enter/OK | Select |
| Return | Go back |
| Play | Play stream |
| Pause | Pause stream |
| Stop | Stop stream |

## API Endpoints Used

- Match List: `https://json.vnres.co/match/matches_{YYYYMMDD}.json`
- Room Detail: `https://json.vnres.co/room/{roomId}/detail.json`
- Streams: HLS (M3U8) format from `pull.niues.live`

## Notes

- Auth keys in stream URLs expire after some time
- App refreshes stream URLs when selecting a match
- Designed for 1920x1080 resolution (Full HD)
- Supports HLS streaming via native HTML5 video

## Building WGT Package

```bash
# In Tizen Studio or using CLI
tizen build-web -out .buildResult
tizen package -t wgt -s <profile_name> -- .buildResult
```

## License

MIT License
