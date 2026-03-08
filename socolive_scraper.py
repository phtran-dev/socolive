#!/usr/bin/env python3
"""
Socolive Stream Scraper
Scrapes live streaming URLs from the Socolive API
"""

import requests
import json
import re
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass


@dataclass
class StreamInfo:
    """Stream information container"""
    room_id: str
    streamer: str
    match_name: str
    category: str
    flv: Optional[str] = None
    hd_flv: Optional[str] = None
    m3u8: Optional[str] = None
    hd_m3u8: Optional[str] = None


class SocoliveScraper:
    """Scraper for Socolive streaming endpoints"""

    BASE_URL = "https://json.vnres.co"
    MATCHES_ENDPOINT = "/match/matches_{date}.json"
    ROOM_ENDPOINT = "/room/{room_id}/detail.json"

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
        })

    def _fetch_jsonp(self, url: str) -> dict:
        """Fetch JSONP response and parse to JSON"""
        response = self.session.get(url, timeout=10)
        response.raise_for_status()

        # Remove JSONP callback wrapper: callback_name({...})
        text = response.text
        match = re.match(r'^\w+\((.*)\)$', text, re.DOTALL)
        if match:
            json_str = match.group(1)
        else:
            json_str = text

        return json.loads(json_str)

    def get_matches(self, date: Optional[datetime] = None) -> List[dict]:
        """
        Get list of matches for a specific date

        Args:
            date: Date to fetch matches for (defaults to today)

        Returns:
            List of match dictionaries
        """
        if date is None:
            date = datetime.now()

        date_str = date.strftime("%Y%m%d")
        url = f"{self.BASE_URL}{self.MATCHES_ENDPOINT.format(date=date_str)}"

        data = self._fetch_jsonp(url)

        if data.get('code') != 200:
            raise Exception(f"API error: {data.get('msg', 'Unknown error')}")

        return data.get('data', [])

    def get_room_detail(self, room_id: str) -> dict:
        """
        Get stream details for a specific room

        Args:
            room_id: The room identifier

        Returns:
            Room detail dictionary with stream URLs
        """
        url = f"{self.BASE_URL}{self.ROOM_ENDPOINT.format(room_id=room_id)}"
        data = self._fetch_jsonp(url)

        if data.get('code') != 200:
            raise Exception(f"API error: {data.get('msg', 'Unknown error')}")

        return data.get('data', {})

    def get_all_streams(self, date: Optional[datetime] = None) -> List[StreamInfo]:
        """
        Get all available streams for a date

        Args:
            date: Date to fetch streams for (defaults to today)

        Returns:
            List of StreamInfo objects
        """
        matches = self.get_matches(date)
        streams = []
        seen_rooms = set()

        for match in matches:
            match_name = f"{match.get('hostName', '?')} vs {match.get('guestName', '?')}"
            category = match.get('subCateName', match.get('categoryName', 'Unknown'))

            # Each match can have multiple streamers (anchors)
            for anchor in match.get('anchors', []):
                room_id = anchor.get('anchor', {}).get('roomNum') or str(anchor.get('uid', ''))

                if not room_id or room_id in seen_rooms:
                    continue

                seen_rooms.add(room_id)
                streamer = anchor.get('nickName', 'Unknown')

                try:
                    detail = self.get_room_detail(room_id)
                    stream_data = detail.get('stream', {})

                    # Handle unicode escapes in URLs
                    def clean_url(url):
                        if url:
                            return url.replace('\\u003d', '=').replace('\\u0026', '&')
                        return url

                    stream_info = StreamInfo(
                        room_id=room_id,
                        streamer=streamer,
                        match_name=match_name,
                        category=category,
                        flv=clean_url(stream_data.get('flv')),
                        hd_flv=clean_url(stream_data.get('hdFlv')),
                        m3u8=clean_url(stream_data.get('m3u8')),
                        hd_m3u8=clean_url(stream_data.get('hdM3u8'))
                    )
                    streams.append(stream_info)
                    print(f"  [+] Room {room_id}: {streamer} - {match_name}")

                except Exception as e:
                    print(f"  [-] Error fetching room {room_id}: {e}")

        return streams

    def print_streams(self, streams: List[StreamInfo], format: str = 'table'):
        """
        Print streams in specified format

        Args:
            streams: List of StreamInfo objects
            format: Output format ('table', 'json', 'm3u8', 'urls')
        """
        if format == 'json':
            output = []
            for s in streams:
                output.append({
                    'room_id': s.room_id,
                    'streamer': s.streamer,
                    'match': s.match_name,
                    'category': s.category,
                    'urls': {
                        'flv': s.flv,
                        'hd_flv': s.hd_flv,
                        'm3u8': s.m3u8,
                        'hd_m3u8': s.hd_m3u8
                    }
                })
            print(json.dumps(output, indent=2, ensure_ascii=False))

        elif format == 'm3u8':
            print("# Socolive M3U8 Playlist")
            print(f"# Generated: {datetime.now().isoformat()}")
            print()
            for s in streams:
                if s.hd_m3u8:
                    print(f"# {s.match_name} - {s.streamer} (HD)")
                    print(s.hd_m3u8)
                if s.m3u8:
                    print(f"# {s.match_name} - {s.streamer} (SD)")
                    print(s.m3u8)

        elif format == 'urls':
            for s in streams:
                print(f"\n# Room {s.room_id}: {s.streamer}")
                print(f"# Match: {s.match_name} [{s.category}]")
                if s.hd_m3u8:
                    print(f"HD_M3U8={s.hd_m3u8}")
                if s.m3u8:
                    print(f"SD_M3U8={s.m3u8}")
                if s.hd_flv:
                    print(f"HD_FLV={s.hd_flv}")
                if s.flv:
                    print(f"SD_FLV={s.flv}")

        else:  # table format
            print("\n" + "=" * 80)
            print(f"{'Room':<10} {'Streamer':<20} {'Match':<35} {'Category':<15}")
            print("=" * 80)

            for s in streams:
                print(f"{s.room_id:<10} {s.streamer:<20} {s.match_name[:35]:<35} {s.category[:15]:<15}")

            print("=" * 80)
            print(f"Total: {len(streams)} streams\n")


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Scrape Socolive streaming URLs')
    parser.add_argument('-d', '--date', type=str, help='Date in YYYYMMDD format (default: today)')
    parser.add_argument('-f', '--format', choices=['table', 'json', 'm3u8', 'urls'],
                        default='table', help='Output format (default: table)')
    parser.add_argument('-r', '--room', type=str, help='Fetch specific room ID only')
    parser.add_argument('-o', '--output', type=str, help='Output file path')

    args = parser.parse_args()

    scraper = SocoliveScraper()

    # Parse date if provided
    date = None
    if args.date:
        date = datetime.strptime(args.date, "%Y%m%d")

    # Fetch specific room or all streams
    if args.room:
        print(f"Fetching room {args.room}...")
        try:
            detail = scraper.get_room_detail(args.room)
            stream_data = detail.get('stream', {})

            def clean_url(url):
                if url:
                    return url.replace('\\u003d', '=').replace('\\u0026', '&')
                return url

            stream = StreamInfo(
                room_id=args.room,
                streamer=detail.get('room', {}).get('anchor', {}).get('nickName', 'Unknown'),
                match_name=detail.get('room', {}).get('title', 'Unknown'),
                category='N/A',
                flv=clean_url(stream_data.get('flv')),
                hd_flv=clean_url(stream_data.get('hdFlv')),
                m3u8=clean_url(stream_data.get('m3u8')),
                hd_m3u8=clean_url(stream_data.get('hdM3u8'))
            )
            scraper.print_streams([stream], args.format)
        except Exception as e:
            print(f"Error: {e}")
    else:
        print(f"Fetching streams for {date.strftime('%Y-%m-%d') if date else 'today'}...")
        streams = scraper.get_all_streams(date)
        scraper.print_streams(streams, args.format)

    # Save to file if specified
    if args.output and 'streams' in locals():
        with open(args.output, 'w', encoding='utf-8') as f:
            for s in streams:
                f.write(f"# Room {s.room_id}: {s.streamer} - {s.match_name}\n")
                if s.hd_m3u8:
                    f.write(f"{s.hd_m3u8}\n")
                if s.m3u8:
                    f.write(f"{s.m3u8}\n")
        print(f"Saved to {args.output}")


if __name__ == '__main__':
    main()
