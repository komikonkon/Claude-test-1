# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Single-page travel itinerary web app — one file (`index.html`), no build step, no dependencies to install.

## Running the App

Open `index.html` directly in a browser. No server required.

## Architecture

Everything lives in `index.html`:

- **Tailwind CSS** (loaded via CDN) for styling
- **Vanilla JS** in a `<script>` block handles all logic
- **localStorage** (`travel_itinerary_v1`) persists data as `{ title: string, events: Event[] }`
- `Event` shape: `{ id: number, date: string, time: string, desc: string }`

Key functions:
- `addEvent()` — validates, pushes to `data.events`, sorts by date+time, saves, re-renders
- `render()` — groups events by date via `groupByDate()`, builds table HTML via template literals
- `escapeHtml()` — sanitizes user input before injecting into innerHTML

Print/PDF: `.no-print` class hides UI chrome; `@media print` in `<style>` handles the rest.

## Git & Deploy

- Development branch: `claude/travel-itinerary-planner-RCzM0`
- Push requires a PAT with **Contents: Read and write** — the environment's default proxy token lacks write access, so set the remote URL explicitly:
  ```
  git remote set-url origin https://<username>:<PAT>@github.com/komikonkon/Claude-test-1.git
  ```
- GitHub Pages serves from this branch's root (`/`)
