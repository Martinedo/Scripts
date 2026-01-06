# Wallpaper by Date

A PowerShell script that automatically changes your Windows desktop wallpaper based on the current date.

## What it does

The script checks the current date and sets your wallpaper according to a prioritized naming pattern:

1. **Exact date with year** (`P_2026-01-06.jpg`) - for specific dates
2. **Date range with year** (`P_2025-12-24_2026-01-07.jpg`) - for multi-day periods
3. **Month and day** (`P_01-06.jpg`) - repeats annually on the same date
4. **Month-day range** (`P_12-24_01-07.jpg`) - repeats annually (supports year wrap-around)
5. **Default fallback** (`P_default.jpg`) - when no other pattern matches

**Guard mechanism**: The script only changes wallpaper if the current wallpaper filename starts with `P_` prefix. This prevents overwriting manually-chosen wallpapers.

## Setup

### Supported formats
- `.jpg`, `.jpeg`, `.png`, `.bmp`

### Configuration
Edit the script's config section if needed:
- `$WallDir` - Directory containing wallpapers (default: current directory)
- `$Prefix` - Filename prefix (default: `P_`)
- `$Style` - Wallpaper style: Fill, Fit, Stretch, Tile, Center, Span (default: Fill)

## Running the script

### Manual execution
```powershell
.\script.ps1
```

### Run on every Windows startup

**Option 1: Task Scheduler (Recommended)**

1. Open **Task Scheduler** (search for it in Start menu)
2. Click **Create Task** (not "Create Basic Task")
3. **General tab**:
   - Name: `Wallpaper by Date`
   - Check "Run whether user is logged on or not"
   - Check "Run with highest privileges"
4. **Triggers tab**:
   - Click **New**
   - Begin the task: **At startup**
   - Delay task for: **30 seconds** (optional, gives system time to initialize)
   - Click **OK**
5. **Actions tab**:
   - Click **New**
   - Action: **Start a program**
   - Program/script: `powershell.exe`
   - Add arguments: `-ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\repos\Scripts\UpdateWallpaper\script.ps1"`
   - Click **OK**
6. **Conditions tab**:
   - Uncheck "Start the task only if the computer is on AC power" (for laptops)
7. Click **OK** to save

**Option 2: Startup folder**

1. Press `Win + R` and type `shell:startup`, press Enter
2. Create a shortcut to the script:
   - Right-click → New → Shortcut
   - Location: `powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\repos\Scripts\UpdateWallpaper\script.ps1"`
   - Name: `Wallpaper by Date`

**Option 3: Run on login via Task Scheduler**

Same as Option 1, but in step 4, choose **At log on** instead of **At startup**

## Logs

Execution logs are stored in: `%LOCALAPPDATA%\WallpaperByDate\wallpaper.log`

## Example filenames

- `P_2026-12-25.jpg` - Christmas 2026
- `P_2026-12-24_2026-12-26.jpg` - Christmas period 2026
- `P_12-25.jpg` - Christmas every year
- `P_12-01_12-31.jpg` - Entire December every year
- `P_06-01_08-31.jpg` - Summer months (June-August)
- `P_default.jpg` - Fallback wallpaper
