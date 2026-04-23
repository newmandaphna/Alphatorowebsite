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
The workflow `Start application` runs `node server.js` and serves the site on port 5000.
