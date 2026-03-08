/**
 * Socolive TV - Samsung Tizen App
 * Sports streaming application for Samsung Smart TV
 */

// API Configuration (direct calls - Tizen allows CORS)
const API = {
    baseUrl: 'https://json.vnres.co',
    matchesEndpoint: '/match/matches_{date}.json',
    roomEndpoint: '/room/{roomId}/detail.json'
};

// App State
const state = {
    currentDate: new Date(),
    matches: [],
    currentMatch: null,
    currentStream: null,
    quality: 'hd', // 'hd' or 'sd'
    isPlaying: false,
    focusedElement: null,
    focusableElements: [],
    hls: null  // HLS.js instance
};

// DOM Elements
const elements = {
    currentDate: document.getElementById('currentDate'),
    prevDay: document.getElementById('prevDay'),
    nextDay: document.getElementById('nextDay'),
    todayBtn: document.getElementById('todayBtn'),
    matchList: document.getElementById('matchList'),
    loading: document.getElementById('loading'),
    status: document.getElementById('status'),
    playerSection: document.getElementById('playerSection'),
    playerMatchTitle: document.getElementById('playerMatchTitle'),
    playerStreamer: document.getElementById('playerStreamer'),
    videoPlayer: document.getElementById('videoPlayer'),
    playerOverlay: document.getElementById('playerOverlay'),
    playerError: document.getElementById('playerError'),
    errorText: document.getElementById('errorText'),
    backBtn: document.getElementById('backBtn'),
    retryBtn: document.getElementById('retryBtn'),
    playPauseBtn: document.getElementById('playPauseBtn'),
    stopBtn: document.getElementById('stopBtn'),
    hdBtn: document.getElementById('hdBtn'),
    sdBtn: document.getElementById('sdBtn')
};

// Initialize App
document.addEventListener('DOMContentLoaded', init);

function init() {
    setupEventListeners();
    setupTVKeys();
    loadMatches();
    updateDateDisplay();
}

// Event Listeners
function setupEventListeners() {
    elements.prevDay.addEventListener('click', () => changeDate(-1));
    elements.nextDay.addEventListener('click', () => changeDate(1));
    elements.todayBtn.addEventListener('click', goToToday);
    elements.backBtn.addEventListener('click', closePlayer);
    elements.retryBtn.addEventListener('click', retryStream);
    elements.playPauseBtn.addEventListener('click', togglePlayPause);
    elements.stopBtn.addEventListener('click', stopStream);
    elements.hdBtn.addEventListener('click', () => setQuality('hd'));
    elements.sdBtn.addEventListener('click', () => setQuality('sd'));

    // External player button
    const externalBtn = document.getElementById('externalBtn');
    if (externalBtn) {
        externalBtn.addEventListener('click', openInExternalPlayer);
    }

    // Video events
    elements.videoPlayer.addEventListener('playing', () => {
        elements.playerOverlay.classList.add('hidden');
        state.isPlaying = true;
    });

    elements.videoPlayer.addEventListener('error', (e) => {
        showError('Stream error: ' + (e.message || 'Unknown error'));
    });

    elements.videoPlayer.addEventListener('waiting', () => {
        elements.playerOverlay.classList.remove('hidden');
    });
}

// Samsung TV Remote Key Handler
function setupTVKeys() {
    document.addEventListener('keydown', (e) => {
        switch (e.keyCode) {
            case 37: // Left
                navigateFocus('left');
                break;
            case 38: // Up
                navigateFocus('up');
                break;
            case 39: // Right
                navigateFocus('right');
                break;
            case 40: // Down
                navigateFocus('down');
                break;
            case 13: // Enter
            case 32: // Space
                activateFocused();
                break;
            case 10009: // Return/Back (Samsung TV)
            case 27: // Escape
                if (!elements.playerSection.classList.contains('hidden')) {
                    closePlayer();
                }
                break;
            case 415: // Play
                if (state.currentStream) togglePlayPause();
                break;
            case 19: // Pause
                if (state.currentStream) elements.videoPlayer.pause();
                break;
            case 413: // Stop
                if (state.currentStream) stopStream();
                break;
        }
    });
}

// Focus Management
function updateFocusableElements() {
    state.focusableElements = Array.from(document.querySelectorAll('[data-focusable]'));
    if (state.focusableElements.length > 0 && !state.focusedElement) {
        setFocus(state.focusableElements[0]);
    }
}

function setFocus(element) {
    if (state.focusedElement) {
        state.focusedElement.classList.remove('focused');
        state.focusedElement.blur();
    }
    state.focusedElement = element;
    if (element) {
        element.focus();
        element.classList.add('focused');
    }
}

function navigateFocus(direction) {
    if (!state.focusedElement || state.focusableElements.length === 0) return;

    const currentIndex = state.focusableElements.indexOf(state.focusedElement);
    let nextIndex = currentIndex;

    // Simple navigation - can be improved with spatial navigation
    switch (direction) {
        case 'up':
            nextIndex = Math.max(0, currentIndex - 1);
            break;
        case 'down':
            nextIndex = Math.min(state.focusableElements.length - 1, currentIndex + 1);
            break;
        case 'left':
        case 'right':
            // Could implement horizontal navigation
            break;
    }

    setFocus(state.focusableElements[nextIndex]);
}

function activateFocused() {
    if (state.focusedElement) {
        state.focusedElement.click();
    }
}

// Date Functions
function formatDate(date) {
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    return date.toLocaleDateString('en-US', options);
}

function formatDateAPI(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}${month}${day}`;
}

function updateDateDisplay() {
    elements.currentDate.textContent = formatDate(state.currentDate);
}

function changeDate(days) {
    state.currentDate.setDate(state.currentDate.getDate() + days);
    updateDateDisplay();
    loadMatches();
}

function goToToday() {
    state.currentDate = new Date();
    updateDateDisplay();
    loadMatches();
}

// API Functions
async function fetchAPI(url) {
    try {
        const response = await fetch(url);
        let text = await response.text();

        // Strip JSONP callback wrapper if present
        const match = text.match(/^\w+\((.*)\)$/s);
        if (match) {
            text = match[1];
        }

        return JSON.parse(text);
    } catch (error) {
        console.error('Fetch error:', error);
        throw error;
    }
}

async function loadMatches() {
    setStatus('Loading matches...');
    elements.loading.classList.remove('hidden');
    elements.matchList.innerHTML = '';
    state.matches = [];

    try {
        const dateStr = formatDateAPI(state.currentDate);
        const url = `${API.baseUrl}${API.matchesEndpoint.replace('{date}', dateStr)}`;
        const data = await fetchAPI(url);

        if (data.code === 200 && data.data) {
            state.matches = data.data;
            renderMatches();
            setStatus(`Found ${state.matches.length} matches`);
        } else {
            throw new Error(data.msg || 'Failed to load matches');
        }
    } catch (error) {
        elements.matchList.innerHTML = `
            <div class="loading">
                <div class="error-icon">⚠️</div>
                <div>Error: ${error.message}</div>
                <button onclick="loadMatches()" class="retry-btn" data-focusable>Retry</button>
            </div>
        `;
        setStatus('Error loading matches');
    }

    updateFocusableElements();
}

async function getRoomDetail(roomId) {
    const url = `${API.baseUrl}${API.roomEndpoint.replace('{roomId}', roomId)}`;
    const data = await fetchAPI(url);

    if (data.code === 200 && data.data) {
        return data.data;
    }
    throw new Error(data.msg || 'Failed to get room details');
}

// Render Functions
function renderMatches() {
    elements.loading.classList.add('hidden');

    if (state.matches.length === 0) {
        elements.matchList.innerHTML = '<div class="loading">No matches available</div>';
        return;
    }

    const html = state.matches.map((match, index) => `
        <div class="match-card" data-index="${index}" tabindex="0" data-focusable>
            <div class="match-league">${match.subCateName || match.categoryName || 'Unknown League'}</div>
            <div class="match-teams">
                <div class="team">
                    <img class="team-logo" src="${match.hostIcon || 'images/default-team.png'}" alt="${match.hostName}" onerror="this.src='images/default-team.png'">
                    <div class="team-name">${match.hostName || 'TBD'}</div>
                </div>
                <div class="vs">VS</div>
                <div class="team">
                    <img class="team-logo" src="${match.guestIcon || 'images/default-team.png'}" alt="${match.guestName}" onerror="this.src='images/default-team.png'">
                    <div class="team-name">${match.guestName || 'TBD'}</div>
                </div>
            </div>
            <div class="match-time">${formatMatchTime(match.matchTime)}</div>
            <div class="match-streamers">
                📺 ${match.anchors ? match.anchors.length : 0} streamers available
            </div>
            ${renderStreamers(match.anchors, index)}
        </div>
    `).join('');

    elements.matchList.innerHTML = html;

    // Add click handlers
    document.querySelectorAll('.match-card').forEach(card => {
        card.addEventListener('click', () => {
            const index = parseInt(card.dataset.index);
            // If clicked on card itself (not streamer), expand streamers
        });
    });

    document.querySelectorAll('.streamer-item').forEach(item => {
        item.addEventListener('click', (e) => {
            e.stopPropagation();
            const roomNum = item.dataset.room;
            const matchIndex = parseInt(item.dataset.matchIndex);
            playStream(matchIndex, roomNum);
        });
    });
}

function renderStreamers(anchors, matchIndex) {
    if (!anchors || anchors.length === 0) {
        return '';
    }

    return `
        <div class="streamer-list">
            ${anchors.slice(0, 3).map(anchor => `
                <div class="streamer-item" data-room="${anchor.anchor?.roomNum || anchor.uid}" data-match-index="${matchIndex}" tabindex="0" data-focusable>
                    <span class="streamer-name">📺 ${anchor.nickName}</span>
                    <span class="watch-btn">Watch</span>
                </div>
            `).join('')}
            ${anchors.length > 3 ? `<div style="text-align:center;color:#888;font-size:16px;padding:10px;">+${anchors.length - 3} more</div>` : ''}
        </div>
    `;
}

function formatMatchTime(timestamp) {
    if (!timestamp) return 'TBD';
    const date = new Date(timestamp);
    return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
}

// Player Functions
async function playStream(matchIndex, roomNum) {
    const match = state.matches[matchIndex];
    state.currentMatch = match;

    setStatus('Loading stream...');
    elements.playerSection.classList.remove('hidden');
    elements.playerMatchTitle.textContent = `${match.hostName} vs ${match.guestName}`;
    elements.playerOverlay.classList.remove('hidden');
    elements.playerError.classList.add('hidden');

    try {
        const roomDetail = await getRoomDetail(roomNum);
        const stream = roomDetail.stream || {};

        // Clean URL (handle unicode escapes)
        const cleanUrl = (url) => {
            if (!url) return '';
            return url.replace(/\\u003d/g, '=').replace(/\\u0026/g, '&');
        };

        // Select quality
        let streamUrl = '';
        if (state.quality === 'hd') {
            streamUrl = cleanUrl(stream.hdM3u8) || cleanUrl(stream.m3u8);
        } else {
            streamUrl = cleanUrl(stream.m3u8) || cleanUrl(stream.hdM3u8);
        }

        if (!streamUrl) {
            throw new Error('No stream URL available');
        }

        state.currentStream = {
            hd: cleanUrl(stream.hdM3u8) || cleanUrl(stream.m3u8),
            sd: cleanUrl(stream.m3u8) || cleanUrl(stream.hdM3u8),
            streamer: roomDetail.room?.anchor?.nickName || 'Unknown'
        };

        elements.playerStreamer.textContent = `📺 ${state.currentStream.streamer}`;

        // Play video using HLS.js (for cross-browser HLS support)
        if (Hls.isSupported()) {
            if (state.hls) {
                state.hls.destroy();
            }
            state.hls = new Hls({
                enableWorker: true,
                lowLatencyMode: true,
            });
            state.hls.loadSource(streamUrl);
            state.hls.attachMedia(elements.videoPlayer);
            state.hls.on(Hls.Events.MANIFEST_PARSED, () => {
                elements.videoPlayer.play();
            });
            state.hls.on(Hls.Events.ERROR, (event, data) => {
                if (data.fatal) {
                    showError('HLS Error: ' + data.type);
                }
            });
        } else if (elements.videoPlayer.canPlayType('application/vnd.apple.mpegurl')) {
            // Safari native HLS support
            elements.videoPlayer.src = streamUrl;
            elements.videoPlayer.play();
        } else {
            showError('HLS is not supported in this browser');
            return;
        }

        setStatus('Playing');
        updateFocusableElements();

    } catch (error) {
        showError(error.message);
    }
}

function closePlayer() {
    elements.videoPlayer.pause();
    elements.videoPlayer.src = '';
    if (state.hls) {
        state.hls.destroy();
        state.hls = null;
    }
    elements.playerSection.classList.add('hidden');
    state.currentStream = null;
    state.currentMatch = null;
    state.isPlaying = false;
    updateFocusableElements();
}

function togglePlayPause() {
    if (elements.videoPlayer.paused) {
        elements.videoPlayer.play();
    } else {
        elements.videoPlayer.pause();
    }
}

function stopStream() {
    elements.videoPlayer.pause();
    elements.videoPlayer.currentTime = 0;
    closePlayer();
}

function setQuality(quality) {
    state.quality = quality;

    elements.hdBtn.classList.toggle('active', quality === 'hd');
    elements.sdBtn.classList.toggle('active', quality === 'sd');

    // If playing, switch stream
    if (state.currentStream && state.isPlaying) {
        const newUrl = quality === 'hd' ? state.currentStream.hd : state.currentStream.sd;
        const currentTime = elements.videoPlayer.currentTime;

        if (state.hls) {
            state.hls.loadSource(newUrl);
            state.hls.on(Hls.Events.MANIFEST_PARSED, () => {
                elements.videoPlayer.currentTime = currentTime;
                elements.videoPlayer.play();
            });
        } else {
            elements.videoPlayer.src = newUrl;
            elements.videoPlayer.currentTime = currentTime;
            elements.videoPlayer.play();
        }
    }
}

// Open in external player (MPV or VLC)
function openInExternalPlayer() {
    if (!state.currentStream) {
        alert('No stream loaded');
        return;
    }

    const streamUrl = state.quality === 'hd' ? state.currentStream.hd : state.currentStream.sd;

    // Create a temporary link to open the stream
    // On most systems, this will offer to open with a video player
    const popup = window.open('', '_blank', 'width=400,height=200');
    if (popup) {
        popup.document.write(`
            <html>
            <head><title>Open Stream</title></head>
            <body style="font-family:Arial;padding:20px;text-align:center;background:#1a1a2e;color:#fff;">
                <h2>📺 Open Stream in External Player</h2>
                <p>Copy this URL and open in MPV or VLC:</p>
                <textarea style="width:350px;height:80px;font-family:monospace;font-size:12px;"
                          onclick="this.select()">${streamUrl}</textarea>
                <p style="margin-top:20px;font-size:14px;color:#888;">
                    <strong>Terminal command:</strong><br>
                    <code style="background:#333;padding:5px 10px;border-radius:4px;">
                        mpv "${streamUrl}"
                    </code>
                </p>
                <button onclick="navigator.clipboard.writeText('${streamUrl}');this.innerHTML='✓ Copied!';"
                        style="margin-top:10px;padding:10px 20px;background:#4CAF50;color:#fff;border:none;border-radius:5px;cursor:pointer;">
                    Copy to Clipboard
                </button>
            </body>
            </html>
        `);
    }
}

function retryStream() {
    if (state.currentMatch && state.currentStream) {
        elements.playerError.classList.add('hidden');
        elements.playerOverlay.classList.remove('hidden');

        const streamUrl = state.quality === 'hd' ? state.currentStream.hd : state.currentStream.sd;

        if (Hls.isSupported() && state.hls) {
            state.hls.loadSource(streamUrl);
            state.hls.on(Hls.Events.MANIFEST_PARSED, () => {
                elements.videoPlayer.play();
            });
        } else {
            elements.videoPlayer.src = streamUrl;
            elements.videoPlayer.play();
        }
    }
}

function showError(message) {
    elements.playerOverlay.classList.add('hidden');
    elements.playerError.classList.remove('hidden');
    elements.errorText.textContent = message;
    setStatus('Error: ' + message);
}

// Utility Functions
function setStatus(message) {
    elements.status.textContent = message;
    console.log('[Socolive]', message);
}

// Tizen WebAPI (optional - for advanced features)
function registerTizenKeys() {
    try {
        if (typeof tizen !== 'undefined' && tizen.tvinputdevice) {
            tizen.tvinputdevice.registerKey('MediaPlay');
            tizen.tvinputdevice.registerKey('MediaPause');
            tizen.tvinputdevice.registerKey('MediaStop');
            tizen.tvinputdevice.registerKey('MediaRewind');
            tizen.tvinputdevice.registerKey('MediaFastForward');
        }
    } catch (e) {
        console.log('Tizen API not available');
    }
}

// Call on init
registerTizenKeys();
