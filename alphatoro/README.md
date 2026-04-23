# ALPHATORO — Marketing Website

Production-ready static site for Alpha Toro Holdings LLC. Built with plain HTML, CSS, and a tiny bit of vanilla JS. No build step. Deploy anywhere.

Built against the ALPHATORO Brand Guidelines 2024 — exact palette, real logo assets.

## Pages

- `index.html` — homepage (hero, thesis, 5 lanes, engagement, partners, CTA)
- `about.html` — partner bios
- `services.html` — six service disciplines, pricing as lead
- `industries.html` — all five lanes with market data
- `contact.html` — form + contact details

## File layout

```
alphatoro/
├── index.html
├── about.html
├── services.html
├── industries.html
├── contact.html
├── styles.css
├── script.js
├── README.md
└── assets/
    ├── logo.png            (full ALPHATORO lockup — also used as apple-touch-icon)
    ├── bull.png            (bull only — hero visual)
    └── bull-icon.png       (square bull mark — nav & footer)
```

## Brand system applied

**Palette** (exact hex from guidelines):
- TYPE black `#231F20`
- Silver `#808285`
- EYE red `#ED1C24`
- Taurus grays `#767C80` `#5C6268` `#3D4249` `#313639`
- Off-white `#F6F6F7` / white `#FFFFFF`

**Typography**:
- Brand logo per guidelines: Arial Black (used in the nav wordmark)
- Body copy per guidelines: Helvetica Regular (Inter substituted as the screen-optimized primary, with Helvetica as the fallback stack — identical visual texture, better web rendering)
- Display headlines: Space Grotesk Bold — chosen for editorial weight; swap to Arial Black in `styles.css` if you want to stay strictly on-brand

## Deploy options

### Replit
1. Create a new Repl (type: "HTML, CSS, JS")
2. Upload all files and the `assets/` folder to the Repl root
3. Click Run. Replit serves `index.html` automatically.

### Netlify (drag and drop, fastest)
1. Go to `app.netlify.com`
2. Drag the `alphatoro` folder onto the dashboard
3. Live URL in ~15 seconds
4. Then: domain settings → add custom domain `alphatoro.us` → Netlify gives you DNS records to point at

### Vercel
1. `vercel` from inside the folder, or connect a GitHub repo
2. Auto-detects static, deploys, gives you a URL and a free custom domain

### GitHub Pages
1. Push to a GitHub repo
2. Settings → Pages → deploy from `main` branch root

## Form submissions

The contact form uses a `mailto:` fallback that opens the user's email client with subject and body pre-filled. To upgrade:

- **Formspree** — change the form's `action` to your Formspree endpoint
- **Netlify Forms** — add `data-netlify="true"` to the form tag. Works automatically on Netlify.
- **Web3Forms** — free, no account needed

## Editing content

All copy lives directly in the HTML files. Brand tokens (colors, fonts, spacing) live at the top of `styles.css` in the `:root` block — change once, cascades site-wide.

The industry market figures in `industries.html` (agency breakdowns, small-business shares, incumbent names) are reasonable defaults. Swap them with your real numbers from the capability statements.

## Performance

- Google Fonts preconnected for fast load
- IntersectionObserver-based reveals, respects `prefers-reduced-motion`
- No framework, no bundler, no hydration
- Should hit 95+ Lighthouse on desktop out of the box

## Next steps (when you want to go further)

- Convert to Next.js 14 when you want a CMS or server-side form handling. The design system in `styles.css` ports directly into a Tailwind config.
- Add an image-rich "Case Studies" page once wins stack up.
- Hook up Plausible or Fathom for privacy-friendly analytics.
- Get headshots of Richard and Cameron to replace the initial avatars.
