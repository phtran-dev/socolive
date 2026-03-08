#!/usr/bin/env python3
"""
Simple CORS proxy server for Socolive TV app
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import urllib.request
import json

class CORSProxyHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path == '/matches':
            # Proxy to matches API
            date = parse_qs(parsed.query).get('date', [''])[0]
            if not date:
                self.send_error(400, 'Missing date parameter')
                return

            url = f'https://json.vnres.co/match/matches_{date}.json'
            self.proxy_request(url)

        elif parsed.path == '/room':
            # Proxy to room detail API
            room_id = parse_qs(parsed.query).get('id', [''])[0]
            if not room_id:
                self.send_error(400, 'Missing room id')
                return

            url = f'https://json.vnres.co/room/{room_id}/detail.json'
            self.proxy_request(url)

        elif parsed.path in ['/', '/index.html']:
            # Serve index.html
            self.serve_file('index.html', 'text/html')

        elif parsed.path.endswith('.css'):
            self.serve_file(parsed.path[1:], 'text/css')

        elif parsed.path.endswith('.js'):
            self.serve_file(parsed.path[1:], 'application/javascript')

        elif parsed.path.endswith('.png') or parsed.path.endswith('.svg'):
            self.serve_file(parsed.path[1:], 'image/png' if parsed.path.endswith('.png') else 'image/svg+xml')

        else:
            self.serve_file('index.html', 'text/html')

    def proxy_request(self, url):
        try:
            req = urllib.request.Request(url, headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Accept': '*/*'
            })
            response = urllib.request.urlopen(req, timeout=10)
            data = response.read().decode('utf-8')

            # Strip JSONP callback wrapper
            import re
            match = re.match(r'^\w+\((.*)\)$', data, re.DOTALL)
            if match:
                data = match.group(1)

            # Send response with CORS headers
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(data.encode())

        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({'error': str(e)}).encode())

    def serve_file(self, path, content_type):
        try:
            with open(path, 'rb') as f:
                content = f.read()

            self.send_response(200)
            self.send_header('Content-Type', content_type)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(content)
        except FileNotFoundError:
            self.send_error(404)

    def log_message(self, format, *args):
        print(f"[Proxy] {args[0]}")

if __name__ == '__main__':
    PORT = 8888
    server = HTTPServer(('0.0.0.0', PORT), CORSProxyHandler)
    print(f'🚀 Socolive TV Server running at http://localhost:{PORT}')
    print('Press Ctrl+C to stop')
    server.serve_forever()
