# Noor: Prayer Times & Quran

Phase 1 (MVP) scaffold — built with Flutter (free, open-source).

## What's working right now
- Home screen: live next-prayer countdown + today's full prayer schedule
  (pulled from the free Aladhan API, based on GPS location, using the
  Karachi calculation method by default)
- Bottom navigation shell (Prayer / Quran / Qibla / Settings)
- App-wide theme (teal + gold, light + dark mode)
- Quran, Qibla, Settings screens are placeholders — built in the next steps

## How to run this — 100% online, nothing installed on your computer

### Step 1 — Create a free GitHub account (if you don't have one)
https://github.com/signup

### Step 2 — Create a new repository
- Click "+" (top right) → "New repository"
- Name it `noor-app` → Create repository (keep it Private or Public, your choice)

### Step 3 — Upload this project folder
- On the new repo page, click "Add file" → "Upload files"
- Drag the ENTIRE `noor_app` folder (all of it — including the hidden
  `.github` and `.gitignore` files) into the upload box
- Scroll down, click "Commit changes"

> Note: some browsers hide the `.github` folder when drag-selecting because
> it starts with a dot. If you don't see it get uploaded, use GitHub
> Desktop (free, no coding needed) or GitHub Codespaces (Step 5 below) —
> both handle hidden folders correctly.

### Step 4 — Watch it build automatically
- Click the "Actions" tab at the top of your repo
- You'll see "Build Android APK" running (takes ~3-5 minutes)
- When it turns green ✅, click into that run → scroll to "Artifacts"
  → download `noor-app-debug-apk`
- Unzip it, transfer `app-debug.apk` to your Android phone (via WhatsApp
  to yourself, Google Drive, USB — any way), tap it to install
  (you'll need to allow "install from unknown sources" once)
- That's it — you're running the real app on your real phone, zero local
  installs.

### Step 5 (recommended) — Edit code in the browser with Codespaces
This is how we'll keep building features together without you installing
anything, ever:
- On your repo page, click the green "Code" button → "Codespaces" tab
  → "Create codespace on main"
- This opens a full VS Code editor in your browser, already connected to
  your repo, with a terminal
- Free tier: ~60 hours/month, more than enough for this project
- Any changes you commit/push there automatically re-trigger Step 4's
  build

## Project structure
```
lib/
  main.dart                  -> app entry point + bottom nav shell
  theme/app_theme.dart       -> colors, light/dark theme
  models/prayer_times.dart   -> prayer times data model
  services/prayer_times_service.dart -> fetches times from Aladhan API
  screens/
    home_screen.dart         -> DONE - live countdown + today's times
    quran_screen.dart        -> placeholder, next step
    qibla_screen.dart        -> placeholder, next step
    settings_screen.dart     -> placeholder, next step
```

## Next steps (in order)
1. Android permissions setup (location) + app icon + app name in
   AndroidManifest.xml
2. Qibla compass screen
3. Quran reader screen (Arabic + Urdu + English, using free Quran API/data)
4. Settings screen (calculation method, language, notifications)
5. Prayer-time notifications with short Arabic recitation cue sound
6. Push to GitHub
