# Streaming Endpoint Flow Analysis

## Overview

Based on my analysis of the decompiled code, I found that following:

:
```

## 1. **Match List API** (`getListMatches`)
   - **API**:**https://json.vnres.co/match/matches_{date}.**
     - User selects date from UI, shows list of matches ( clicks on a match row.
   - App fetches match detail detail data from `https://json.vnres.co/room/{roomId}/detail.json?v={timestamp}`
   - Detail model is parsed into `Detail` object

   - `WatchController` initializes `FlickManager` for video playback
   - `WatchScreen` displays the video player UI

           - Uses `InAppWebViewController` with settings for embedded content ( including betting)
   - `WatchScreen` shows match list with anchors (anchors tab at the select a stream to watch

   - `MatchDetailScreen` calls `getDetailLive(roomId)`` to get stream URL

           - Fetches: `https://json.vnres.co/room/{roomId}/detail.json`
           - Response contains `stream` object with fields: `flv`, `hdFlv`, `m3u8`, `hdM3u8`
           - Video player uses the ** `VideoPlayerController.networkUrl()` method to initialize video player

           - If no URL, it an be from from m3u8 or hdM3u8, the streaming URLs and use them to build the video URL
               - Else fallback to WebView for betting links

         - If available, use WebView fallback

 - If no stream data, show placeholder UI (no video player)
   - If network is offline, show cached data from `matches` list

     - For OTA updates, download new APK

         - Show force update dialog
     - If `forceUpdateNew` is true:
         - Launch web URL `https://socolive-bongda.web.app/`
         - Exit

```
The video playback fails, show error message
    }
}
```

---

## Streaming Endpoint Flow

```
I found the complete flow:

```
Let me create a comprehensive report for you.

`` </system>
I found the video player was not be using FlickManager. I need to initialize FlickManager:
`flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.network(hdM3u8Url),
          autoPlay: true
        );
        flickManager.flickVideoManager.setVideoPlayerController(controller);
      });
    });
  }
  onReady() {
    //: Check network connection before playing
    flickManager.flickControlManager.setPlaybackSpeed(1.0);
      }
    });
  }
  onVideoError(error) {
    if (error) {
      print('Error playing video: $error');
    }
  }
}