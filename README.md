# Webprofits brand kit

Team-shared visual canon for the Webprofits design system - the rendered reference for every brand token, typography role, and component (Gellix typography, KPI tiles, charts, tables, sidebar/app-header, the new website credibility components, the footer pattern). Mirrors what the [webprofits-brand skill](https://github.com/webprofits/wp-skills/tree/main/global/webprofits-brand) ships.

**Live URL:** https://webprofits.github.io/webprofits/

This is a **public** Pages site, but every visitor lands on a Webprofits-branded StatiCrypt password screen first. Enter the team brand password to view the kit.

**Password:** `WPbrand777` (also in 1Password under _WP Brand Kit_). Don't share outside the team.

## What you'll see

The page renders the full visual canon - tokens (colour, radius, layout), typography (Gellix with the new section-header trio), every component class in the system (KPI tiles, tables, charts, change list, next cards, hook/example cards, anti-pattern blocks, rule cards), the wordmark variants, voice rules, do / don't, and the **website credibility components** (case-study cards, testimonials, partner + award medallion rows, the colour client logo wall, AI callout, looked-at card).

Open it when you're unsure how a Webprofits HTML deliverable should look or feel - the styling here is the source of truth.

## Repo layout

```
webprofits/
├── index.html                       # ENCRYPTED, served by GitHub Pages
├── .staticrypt.json                 # encryption salt (committed)
├── README.md
└── scripts/
    ├── encrypt.sh                   # re-bake + re-encrypt the kit
    └── encrypt/template.html        # WP-branded StatiCrypt login template
```

The plaintext source (`brand-kit.html`, `design-system.css`, `gellix-base64.css`) is **not** in this repo - it lives in the [`webprofits-brand` skill](https://github.com/webprofits/wp-skills/tree/main/global/webprofits-brand) inside `webprofits/wp-skills`. This repo carries only the encrypted output so a public repo doesn't leak the source.

## How to refresh

You need a local checkout of `webprofits/wp-skills` (the encrypt script reads the latest brand-kit source from there) plus the `staticrypt` CLI:

```bash
npm i -g @robinmoisson/staticrypt
```

Then from this repo:

```bash
./scripts/encrypt.sh WPbrand777
git commit -am "Refresh brand kit"
git push
```

`encrypt.sh` looks for the wp-skills checkout at `$WP_SKILLS`, then `../wp-skills`, then `../../skills/wp-skills`. Override with `WP_SKILLS=/path/to/wp-skills` if yours lives elsewhere.

The script inlines `design-system.css` + the base64 Gellix `@font-face` faces from the skill into `brand-kit.html` to produce a single self-contained file, then encrypts it with StatiCrypt and the team password and writes the result to `index.html`. GitHub Pages redeploys on push.

## Why public + encrypted (not private)

Public + StatiCrypt gives a stable, clean URL (`webprofits.github.io/webprofits/`) without the randomised hostname GitHub assigns to private-repo Pages, and without requiring viewers to be authenticated to the `webprofits` GitHub org. The encryption is the gate; the password is the bottleneck. Source-of-truth lives in the skill so the public repo never exposes plaintext brand-kit content.

## Linked, not bundled

Logos (client / partner / award) are referenced from `https://webprofits.com.au/assets/{logos,partners,awards}/` rather than bundled. `<img>` isn't subject to CORS so this works from any origin and keeps the encrypted file lean. Fonts are bundled (the woff2 served from the website has no `Access-Control-Allow-Origin` header, which would CORS-block a cross-origin `@font-face`).
