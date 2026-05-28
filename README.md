# Webprofits brand kit

Team-shared visual canon for the Webprofits design system - the rendered reference for every brand token, typography role, and component (Gellix typography, KPI tiles, charts, tables, sidebar/app-header, the website credibility components, the footer pattern). Mirrors what the [webprofits-brand skill](https://github.com/webprofits/wp-skills/tree/main/global/webprofits-brand) ships.

**Live URL:** https://effective-adventure-qje9n4j.pages.github.io/

(This is a randomised `*.pages.github.io` URL because the repo is private; GitHub assigns these for security and the URL is stable for the life of the repo. Bookmark it.)

Three layers of access:

1. The repo is **private** - only members of the `webprofits` GitHub org can view it.
2. GitHub Pages on private repos requires **GitHub authentication** - visiting the URL redirects to a GitHub login. You must be signed in to a GitHub account with access to `webprofits/brand-kit`.
3. The page itself is **StatiCrypt-encrypted** - after auth you'll see a Webprofits-branded password screen. Enter the team brand password to view the kit.

The team password is `WPbrand777` (also stored in 1Password under _WP Brand Kit_). Don't share outside the team.

## What you'll see

The page renders the full visual canon - tokens (colour, radius, layout), typography (Gellix with the new section-header trio), every component class in the system (KPI tiles, tables, charts, change list, next cards, hook/example cards, anti-pattern blocks, rule cards), the wordmark variants, voice rules, do / don't, and the new **website credibility components** (case-study cards, testimonials, partner + award medallion rows, the colour client logo wall, AI callout, looked-at card).

Open the page in a browser when you're unsure how a Webprofits HTML deliverable should look or feel - the styling here is the source of truth.

## Repo layout

```
brand-kit/
├── index.html                       # encrypted, served by GitHub Pages
├── source/
│   ├── brand-kit.html               # plaintext source (open directly = same view)
│   ├── design-system.css            # canonical CSS (synced from the skill)
│   └── gellix-base64.css            # base64 Gellix @font-face faces (synced from the skill)
└── scripts/
    ├── encrypt.sh                   # re-encrypt the source -> index.html
    └── encrypt/template.html        # the WP-branded StatiCrypt login template
```

`source/` is the plaintext bundle that builds the live page. `index.html` is the encrypted output that GitHub Pages serves. Both are committed; the private repo + the StatiCrypt gate are the two layers of access control.

## How to update

1. Edit `source/brand-kit.html` (or pull a fresh copy of `design-system.css` / `gellix-base64.css` from the [webprofits-brand skill](https://github.com/webprofits/wp-skills/tree/main/global/webprofits-brand) when the skill ships an update).
2. Re-bake the self-contained file + re-encrypt:
   ```bash
   ./scripts/encrypt.sh <password>
   ```
   Pass the team brand password as the only argument. The script inlines `design-system.css` + `gellix-base64.css` into `brand-kit.html`, then runs `staticrypt` against the result and writes the encrypted output to `index.html`.
3. `git commit -am "Refresh brand kit"` + `git push`. GitHub Pages redeploys automatically.

Requires `staticrypt` (`npm i -g @robinmoisson/staticrypt`) and `python3`.

## Why password-protected

The kit documents internal class names, component-fidelity rules, and the skill's deterministic harness. It's also nominally available to anyone who has the repo URL (`*.github.io` is public unless you pay for private Pages). Encryption keeps it team-only without needing GitHub Pro on the org.

## Linked, not bundled

Logos (client / partner / award) are referenced from `https://webprofits.com.au/assets/{logos,partners,awards}/` rather than bundled into the repo. `<img>` isn't subject to CORS so this works from any origin and keeps the encrypted file lean. Fonts are bundled (the woff2 served from the website has no `Access-Control-Allow-Origin` header, which would CORS-block a cross-origin `@font-face`).
