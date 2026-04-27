const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 5000;
const HOST = '0.0.0.0';
const ROOT = path.join(__dirname, 'alphatoro');
const LOG_FILE = path.join(__dirname, 'visits.log');
const STATE_FILE = path.join(__dirname, 'report-state.json');
const FORMSPREE_URL = 'https://formspree.io/f/xkokpkdn';
const REPORT_INTERVAL_MS = 72 * 60 * 60 * 1000;

const mimeTypes = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.webp': 'image/webp',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.json': 'application/json',
};

function logVisit(urlPath, userAgent) {
  const now = new Date();
  const timestamp = now.toISOString().replace('T', ' ').slice(0, 19) + ' UTC';
  const ua = (userAgent || 'unknown').replace(/\n/g, ' ').slice(0, 200);
  const line = `${timestamp} | ${urlPath} | ${ua}\n`;
  fs.appendFile(LOG_FILE, line, () => {});
}

function formatDateLabel(dateStr) {
  const [year, month, day] = dateStr.split('-');
  const d = new Date(Date.UTC(+year, +month - 1, +day));
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
}

function buildReportEmail(lines, periodStart, periodEnd) {
  const byDate = {};

  for (const line of lines) {
    const parts = line.split(' | ');
    if (parts.length < 2) continue;
    const dateStr = parts[0].slice(0, 10);
    const page = parts[1].trim();
    if (!byDate[dateStr]) byDate[dateStr] = {};
    byDate[dateStr][page] = (byDate[dateStr][page] || 0) + 1;
  }

  const dates = Object.keys(byDate).sort();
  if (dates.length === 0) return null;

  const total = lines.length;
  const startLabel = formatDateLabel(periodStart);
  const endLabel = formatDateLabel(periodEnd);

  const subject = `Alpha Toro — Website Report ${startLabel} to ${endLabel}`;

  let body = `Alpha Toro Holdings — Website Traffic Report\n`;
  body += `Period: ${startLabel} – ${endLabel}\n`;
  body += `Total page views: ${total}\n`;
  body += `${'─'.repeat(40)}\n\n`;

  for (const date of dates) {
    const pages = byDate[date];
    const dayTotal = Object.values(pages).reduce((a, b) => a + b, 0);
    body += `${formatDateLabel(date)}: ${dayTotal} visit${dayTotal !== 1 ? 's' : ''}\n`;
    const sorted = Object.entries(pages).sort((a, b) => b[1] - a[1]);
    for (const [page, count] of sorted) {
      body += `  ${page.padEnd(30)} ${count} visit${count !== 1 ? 's' : ''}\n`;
    }
    body += '\n';
  }

  return { subject, message: body };
}

function readReportState() {
  try {
    const raw = fs.readFileSync(STATE_FILE, 'utf8');
    return JSON.parse(raw);
  } catch (e) {
    return null;
  }
}

function saveReportState(lastSentMs) {
  try {
    fs.writeFileSync(STATE_FILE, JSON.stringify({ lastSentMs }));
  } catch (e) {
    console.error('[report] Failed to save report state:', e.message);
  }
}

async function sendReport(periodStartMs, periodEndMs) {
  let raw = '';
  try {
    raw = fs.readFileSync(LOG_FILE, 'utf8');
  } catch (e) {
    return;
  }

  const lines = raw.split('\n').filter(l => l.trim().length > 0);
  if (lines.length === 0) {
    saveReportState(Date.now());
    return;
  }

  const now = Date.now();
  const windowEnd = periodEndMs != null ? periodEndMs : now;
  const windowStart = periodStartMs != null ? periodStartMs : windowEnd - REPORT_INTERVAL_MS;
  const periodStart = new Date(windowStart).toISOString().slice(0, 10);
  const periodEnd = new Date(windowEnd).toISOString().slice(0, 10);

  const payload = buildReportEmail(lines, periodStart, periodEnd);
  if (!payload) {
    console.log('[report] Could not parse log entries — skipping email.');
    return;
  }

  try {
    const res = await fetch(FORMSPREE_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
      body: JSON.stringify(payload),
    });
    if (res.ok) {
      console.log(`[report] Summary email sent (${lines.length} visits).`);
      fs.writeFileSync(LOG_FILE, '');
      saveReportState(Date.now());
    } else {
      console.error(`[report] Formspree responded with status ${res.status} — log not cleared.`);
    }
  } catch (err) {
    console.error('[report] Failed to send report email:', err.message);
  }
}

function startReportScheduler() {
  const state = readReportState();
  const now = Date.now();
  let delay;

  if (state && typeof state.lastSentMs === 'number') {
    const elapsed = now - state.lastSentMs;
    const remaining = REPORT_INTERVAL_MS - elapsed;
    if (remaining > 0) {
      delay = remaining;
      console.log(`[report] Resuming scheduler — next report in ${Math.round(delay / 1000 / 60)} minute(s).`);
    } else {
      delay = 0;
      const missedWindowStart = state.lastSentMs;
      const missedWindowEnd = state.lastSentMs + REPORT_INTERVAL_MS;
      console.log('[report] Window expired while offline — sending overdue report now.');
      setTimeout(() => {
        sendReport(missedWindowStart, missedWindowEnd);
        setInterval(sendReport, REPORT_INTERVAL_MS);
      }, 0);
      return;
    }
  } else {
    delay = REPORT_INTERVAL_MS;
    console.log('[report] No prior state found — scheduling first report in 3 days.');
  }

  setTimeout(() => {
    sendReport();
    setInterval(sendReport, REPORT_INTERVAL_MS);
  }, delay);
}

const server = http.createServer((req, res) => {
  let urlPath = req.url.split('?')[0];
  if (urlPath === '/') urlPath = '/index.html';

  const filePath = path.join(ROOT, urlPath);

  if (!filePath.startsWith(ROOT)) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }

  fs.stat(filePath, (err, stat) => {
    if (err || !stat.isFile()) {
      const htmlFile = filePath.endsWith('.html') ? filePath : filePath + '.html';
      fs.readFile(htmlFile, (err2, data) => {
        if (err2) {
          res.writeHead(404, { 'Content-Type': 'text/html' });
          res.end('<h1>404 Not Found</h1>');
        } else {
          logVisit(urlPath, req.headers['user-agent']);
          res.writeHead(200, { 'Content-Type': 'text/html' });
          res.end(data);
        }
      });
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = mimeTypes[ext] || 'application/octet-stream';

    if (ext === '.html') {
      logVisit(urlPath, req.headers['user-agent']);
    }

    fs.readFile(filePath, (err2, data) => {
      if (err2) {
        res.writeHead(500);
        res.end('Server Error');
        return;
      }
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(data);
    });
  });
});

server.listen(PORT, HOST, () => {
  console.log(`Server running at http://${HOST}:${PORT}`);
  startReportScheduler();
});
