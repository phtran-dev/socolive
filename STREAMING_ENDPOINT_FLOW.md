# Streaming Endpoint Flow Analysis - Socolive App

## Real Streaming URL Examples

### API Endpoint
```
https://json.vnres.co/room/511240/detail.json
```

### Match: AUS NNSW: Broadmeadow Magic vs Edgeworth Eagles FC
- **Room ID:** 511240
- **Streamer:** BLV CHIM SẺ

---

## Live Streaming URLs (ACTUAL)

### FLV (Standard Quality - RTMP):
```
https://pull06.scstream.net/live/stream-511240_lsd.flv?auth_key=1753599431-0-0-302054590369297d6266d489c6f50785
```

### HD FLV (High Quality - RTMP):
```
https://pull06.scstream.net/live/stream-511240_lhd.flv?auth_key=1753599431-0-0-33d6b3b0f83f147ebf3a882231fd8f3b
```

### M3U8 (Standard Quality - HLS):
```
https://pull.niues.live/live/stream-511240_lsd.m3u8?auth_key=1753599431-0-0-d15472059b87eac972fc712e82bd3455
```

### HD M3U8 (High Quality - HLS):
```
https://pull.niues.live/live/stream-511240_lhd.m3u8?auth_key=1753599431-0-0-e2777e62f83747dd518778506b2ad05b
```

---

## Streaming Infrastructure

| CDN Server | Protocol | Purpose |
|-----------|----------|---------|
| `pull06.scstream.net` | FLV/RTMP | Flash Video Streaming |
| `pull.niues.live` | M3U8/HLS | HTTP Live Streaming |

**Stream Types Supported:** `7, 2, 6`
- Type 2 = FLV (RTMP)
- Type 6 = HD FLV
- Type 7 = M3U8/HLS

**Authentication:** `auth_key` parameter (time-based token)

---

## Complete API Flow

```
1. Home Screen
   └── API: https://json.vnres.co/match/matches_YYYYMMDD.json
       └── Returns: List of matches with room IDs

2. Match Detail Screen
   └── API: https://json.vnres.co/room/{roomId}/detail.json
       └── Returns: Stream URLs (flv, hdFlv, m3u8, hdM3u8)

3. Video Player
   └── Uses: flick_video_player with M3U8 or FLV URL
```

---

## How to Test

### Using VLC Media Player:
1. Open VLC
2. Media → Open Network Stream
3. Paste the M3U8 URL:
```
https://pull.niues.live/live/stream-511240_lhd.m3u8?auth_key=1753599431-0-0-e2777e62f83747dd518778506b2ad05b
```
4. Click Play

### Using ffplay (FFmpeg):
```bash
ffplay "https://pull.niues.live/live/stream-511240_lhd.m3u8?auth_key=1753599431-0-0-e2777e62f83747dd518778506b2ad05b"
```

### Using curl to check stream:
```bash
curl -I "https://pull.niues.live/live/stream-511240_lsd.m3u8?auth_key=1753599431-0-0-d15472059b87eac972fc712e82bd3455"
```

---

## URL Pattern Analysis

### Stream URL Format:
```
https://{cdn-server}/live/stream-{room_id}_{quality}.{format}?auth_key={timestamp}-{0-0}-{hash}
```

**Parameters:**
- `{cdn-server}`: `pull06.scstream.net` or `pull.niues.live`
- `{room_id}`: Unique stream room identifier (e.g., 511240)
- `{quality}`: `lsd` (standard) or `lhd` (HD)
- `{format}`: `flv` or `m3u8`
- `{timestamp}`: Unix timestamp for auth key
- `{hash}`: MD5/SHA hash for authentication

---

## Response Structure (detail.json)

```json
{
  "code": 200,
  "msg": "ok",
  "data": {
    "room": {
      "anchor": { ... },
      "roomNum": "511240",
      "title": "Match Title",
      "streamType": 7
    },
    "stream": {
      "flv": "https://...",
      "hdFlv": "https://...",
      "m3u8": "https://...",
      "hdM3u8": "https://..."
    },
    "streamTypes": "7,2,6"
  }
}
```

---

## Notes

1. **Auth keys are time-limited** - URLs expire after some time
2. **CDN servers may vary** - Different matches use different CDN nodes
3. **Quality depends on streamer** - Not all streams have HD available
4. **FLV is legacy format** - M3U8/HLS is preferred for modern players
