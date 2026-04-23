# Alpha Toro Holdings - Marketing Website

## Project Overview
Static marketing website for Alpha Toro Holdings LLC (ALPHATORO), a firm specializing in federal business development and capture.

## Tech Stack
- **Frontend**: Vanilla HTML5, CSS3, JavaScript (no framework or build system)
- **Server**: Node.js HTTP server (`server.js`) serving static files from `alphatoro/` directory
- **Port**: 5000

## Project Structure
```
/
├── server.js          # Node.js static file server
├── alphatoro/         # Website files
│   ├── index.html     # Homepage
│   ├── about.html     # Partner bios
│   ├── services.html  # Services and pricing
│   ├── industries.html# Market data and industry lanes
│   ├── contact.html   # Contact form
│   ├── styles.css     # Main stylesheet
│   ├── script.js      # Interactive functionality
│   └── assets/        # Images and branding
└── README.md
```

## Running the App
The workflow `Start application` runs `sh setup-git.sh && node server.js` and serves the site on port 5000.

## GitHub Sync
Automatic GitHub credential configuration is set up via two scripts:
- **`.git-credentials-helper.sh`** — returns the `GITHUB_TOKEN` secret as the git password (using `x-access-token` as the username, which is correct for GitHub PATs)
- **`setup-git.sh`** — configures local git config to use the credential helper and installs a post-commit hook; runs automatically on every app startup

After the workflow has started at least once, `git push origin main` works from the shell without supplying a token. You can also run `sh setup-git.sh` manually in the shell before pushing if the workflow hasn't been started yet.

### Sync Status Log
Every push attempt (from both the post-commit hook and the post-merge script) appends a timestamped entry to **`github-sync-status.log`** in the project root:
- `[TIMESTAMP] SUCCESS: pushed branch '...' to GitHub` on a successful push
- `[TIMESTAMP] FAILED: push of branch '...' to GitHub failed` followed by the full error output on failure; failures are also echoed to stderr

The log file is excluded from git via `.gitignore` — it is a local runtime artifact, not source code.

### Sync Failure Alerts
When a push fails, both the post-commit hook and the post-merge script send an email alert to **adaphna@alphatoro.us** via Formspree. The notification includes the branch name, timestamp, and full error output.

To enable alerts:
1. Go to [formspree.io/forms](https://formspree.io/forms) and create a new form pointed at `adaphna@alphatoro.us`.
2. Copy the form endpoint URL (looks like `https://formspree.io/f/XXXXXXXX`).
3. Add it as the **`FORMSPREE_ENDPOINT`** environment variable in Replit's Secrets tab.

If `FORMSPREE_ENDPOINT` is not set, the alert step is silently skipped — failures are still logged to `github-sync-status.log` and echoed to stderr as before.
