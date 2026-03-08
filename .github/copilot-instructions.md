# Project Guidelines

## Architecture
- This repository is a Hugo site using the `github.com/hugo-toha/toha/v4` module as the theme (`hugo.yaml`, `go.mod`).
- Most rendering logic comes from the theme module; this repo overrides selected partials in `layouts/partials/**`.
- Content/data split:
  - `content/**` for Markdown pages/posts/notes.
  - `data/{en,fr}/**` for section and profile data.
  - `layouts/partials/**` for HTML template overrides.
- Generated site output is in `public/`; treat it as build output, not source of truth.

## Build and Validation
- Preferred local workflow:
  - `mise install`
  - `mise run server`
- Theme/npm sync workflow (required when dependencies or module versions change):
  - `hugo mod tidy`
  - `hugo mod npm pack`
  - `npm install`
- Production-style build:
  - `hugo --gc --minify`
- CI/hosting references:
  - Netlify build commands are in `netlify.toml`.
  - GitHub Pages workflow is `.github/workflows/merge-to-main.yml`.

## Hugo API Usage in This Repo
- Existing template overrides use Hugo resource APIs for media lookup and image handling:
  - `resources.Get` for image/video/logo retrieval in:
    - `layouts/partials/sections/home.html`
    - `layouts/partials/sections/experiences/positions.html`
    - `layouts/partials/cards/project.html`
  - `.Fit` is used only when media subtype supports processing (avoid svg/gif/webp processing where unsupported in existing patterns).
  - Prefer `.RelPermalink` for rendered asset URLs.
- Output formats:
  - `hugo.yaml` configures `home` outputs as `HTML`, `RSS`, and `JSON`.
  - Keep `HTML` first unless changing primary permalink behavior intentionally.

## HTML / JS / TS Generator Conventions
- HTML generation:
  - Follow existing Go template style (`{{ ... }}`) and keep overrides minimal/targeted in `layouts/partials/**`.
  - Reuse current fallback behavior (resource lookup first, then direct path fallback).
- JavaScript/TypeScript generation:
  - There are currently no first-party `assets/**/*.js` or `assets/**/*.ts` source files in this repo; JS/CSS assets primarily come from the theme/module pipeline.
  - If adding custom JS/TS, place source files under `assets/` and build with Hugo Pipes (`resources.Get` + `js.Build`), then fingerprint in production.
  - Prefer `js.Build` options that are environment-aware: `targetPath`, `minify`, `sourceMap`; use `loaders` (`ts`/`tsx`) when importing TS/TSX explicitly.
  - Do not hand-edit generated `public/application*.js` files.

## Pitfalls and Practical Rules
- Keep Hugo/Node versions coherent with `mise.toml`, Netlify, and workflow configs before changing build behavior.
- Run module/npm sync commands before assuming JS dependency resolution issues are template bugs.
- When changing multilingual content or data keys, verify both `en` and `fr` variants.