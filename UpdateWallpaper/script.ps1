#requires -Version 5.1
<#
Priority order:
1) P_yyyy-MM-dd.<ext>
2) P_yyyy-MM-dd_yyyy-MM-dd.<ext>
3) P_MM-dd.<ext>
4) P_MM-dd_MM-dd.<ext>
5) P_default.<ext>

Guard:
- If current wallpaper filename DOES NOT start with "P_", do nothing and exit.
  (Prevents overwriting user-chosen wallpapers.)
#>

# ============ CONFIG ============
$WallDir  = '.'          # e.g. 'C:\Wallpapers' or '.' (script/current working dir)
$Prefix   = 'P_'
$Style    = 'Fill'       # Fill, Fit, Stretch, Tile, Center, Span
$Exts     = @('jpg','jpeg','png','bmp')

# Log file (per-user)
$LogDir   = Join-Path $env:LOCALAPPDATA 'WallpaperByDate'
$LogFile  = Join-Path $LogDir 'wallpaper.log'
# ===============================

function Ensure-LogDir {
    if (-not (Test-Path -LiteralPath $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
}

function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG')]
        [string]$Level = 'INFO'
    )
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts][$Level] $Message"
    Write-Host $line
    Add-Content -LiteralPath $LogFile -Value $line
}

function Get-CurrentWallpaperPath {
    try {
        (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallPaper -ErrorAction Stop).WallPaper
    } catch {
        ""
    }
}

# ---- A) IMPORTANT FIX: always return FULL (absolute) path ----
function Resolve-FirstExistingFile {
    param(
        [Parameter(Mandatory)][string]$BasePathNoExt
    )
    foreach ($e in $Exts) {
        $p = "$BasePathNoExt.$e"
        if (Test-Path -LiteralPath $p) {
            return (Resolve-Path -LiteralPath $p).Path.Trim()
        }
    }
    return $null
}

function Find-ExactYMD {
    param([datetime]$Today)
    $base = Join-Path $WallDir ("{0}{1}" -f $Prefix, $Today.ToString('yyyy-MM-dd'))
    Resolve-FirstExistingFile -BasePathNoExt $base
}

function Find-ExactMD {
    param([datetime]$Today)
    $base = Join-Path $WallDir ("{0}{1}" -f $Prefix, $Today.ToString('MM-dd'))
    Resolve-FirstExistingFile -BasePathNoExt $base
}

function Find-RangeYMD {
    param([datetime]$Today)

    $pattern = '^' + [regex]::Escape($Prefix) + '(?<a>\d{4}-\d{2}-\d{2})_(?<b>\d{4}-\d{2}-\d{2})$'

    foreach ($ext in $Exts) {
        $files = Get-ChildItem -LiteralPath $WallDir -File -ErrorAction SilentlyContinue |
                 Where-Object { $_.Extension -ieq ".$ext" }
        
        foreach ($file in $files) {
            if ($file.BaseName -match $pattern) {
                try {
                    $a = [datetime]::ParseExact($Matches.a, 'yyyy-MM-dd', $null)
                    $b = [datetime]::ParseExact($Matches.b, 'yyyy-MM-dd', $null)
                    if ($a -le $Today -and $Today -le $b) {
                        return $file.FullName.Trim()
                    }
                } catch { }
            }
        }
    }
    return $null
}

function Find-RangeMD {
    param([datetime]$Today)

    $pattern = '^' + [regex]::Escape($Prefix) + '(?<a>\d{2}-\d{2})_(?<b>\d{2}-\d{2})$'
    $todayMD = $Today.ToString('MM-dd')

    foreach ($ext in $Exts) {
        $files = Get-ChildItem -LiteralPath $WallDir -File -ErrorAction SilentlyContinue |
                 Where-Object { $_.Extension -ieq ".$ext" }
        
        foreach ($file in $files) {
            if ($file.BaseName -match $pattern) {
                $a = $Matches.a
                $b = $Matches.b

                # Supports wrap-around, e.g. 12-28_01-05
                $inRange =
                    if ($a -le $b) { ($todayMD -ge $a -and $todayMD -le $b) }
                    else           { ($todayMD -ge $a -or  $todayMD -le $b) }

                if ($inRange) {
                    return $file.FullName.Trim()
                }
            }
        }
    }
    return $null
}

function Find-Default {
    $base = Join-Path $WallDir ("{0}default" -f $Prefix)
    Resolve-FirstExistingFile -BasePathNoExt $base
}

function Set-Wallpaper {
    param(
        [Parameter(Mandatory)][string]$Path,
        [ValidateSet('Fill','Fit','Stretch','Tile','Center','Span')]
        [string]$WallpaperStyle = 'Fill'
    )

    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;

public static class Wallpaper {
  [DllImport("user32.dll", SetLastError=true)]
  public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

  public const int SPI_SETDESKWALLPAPER = 20;
  public const int SPIF_UPDATEINIFILE = 0x01;
  public const int SPIF_SENDWININICHANGE = 0x02;

  public static void SetStyle(string style) {
    using (var k = Registry.CurrentUser.OpenSubKey(@"Control Panel\Desktop", true)) {
      if (k == null) return;
      switch ((style ?? "Fill").ToLowerInvariant()) {
        case "fill":    k.SetValue("WallpaperStyle","10"); k.SetValue("TileWallpaper","0"); break;
        case "fit":     k.SetValue("WallpaperStyle","6");  k.SetValue("TileWallpaper","0"); break;
        case "stretch": k.SetValue("WallpaperStyle","2");  k.SetValue("TileWallpaper","0"); break;
        case "tile":    k.SetValue("WallpaperStyle","0");  k.SetValue("TileWallpaper","1"); break;
        case "center":  k.SetValue("WallpaperStyle","0");  k.SetValue("TileWallpaper","0"); break;
        case "span":    k.SetValue("WallpaperStyle","22"); k.SetValue("TileWallpaper","0"); break;
        default:        k.SetValue("WallpaperStyle","10"); k.SetValue("TileWallpaper","0"); break;
      }
    }
  }
}
"@ -ErrorAction SilentlyContinue | Out-Null

    [Wallpaper]::SetStyle($WallpaperStyle)

    $ok = [Wallpaper]::SystemParametersInfo(
        [Wallpaper]::SPI_SETDESKWALLPAPER, 0, $Path,
        [Wallpaper]::SPIF_UPDATEINIFILE -bor [Wallpaper]::SPIF_SENDWININICHANGE
    )

    if (-not $ok) {
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "SystemParametersInfo failed. Win32Error=$err"
    }
}

function Format-Opt {
    param([string]$Value)
    if ($Value) { $Value } else { "<none>" }
}

# ---------------- MAIN ----------------
Ensure-LogDir
Write-Log "---- Script start ----"

# Ensure WallDir is absolute (critical for correct wallpaper paths)
try {
    $WallDir = (Resolve-Path -LiteralPath $WallDir -ErrorAction Stop).Path
} catch {
    Write-Log "WallDir '$WallDir' cannot be resolved. Exiting." "ERROR"
    Write-Log "---- Script end ----"
    exit 0
}

Write-Log "WallDir=$WallDir Prefix=$Prefix Style=$Style"

$today = Get-Date
Write-Log ("Today: {0} (YMD={1}, MD={2})" -f $today, $today.ToString('yyyy-MM-dd'), $today.ToString('MM-dd'))

$current = Get-CurrentWallpaperPath
Write-Log "Current wallpaper registry path: '$current'"

$currentName = if ($current) { Split-Path $current -Leaf } else { "" }
Write-Log "Current wallpaper filename: '$currentName'"

# Guard
if (-not $currentName.StartsWith($Prefix, [StringComparison]::OrdinalIgnoreCase)) {
    Write-Log "Guard triggered: current wallpaper does not start with '$Prefix'. Not changing anything." "WARN"
    Write-Log "Tip: set any wallpaper named like 'P_default.jpg' once to activate rotation."
    Write-Log "---- Script end ----"
    exit 0
}

# Choose by priority (PS 5.1 compatible)
$chosen = Find-ExactYMD -Today $today
Write-Log ("Candidate #1 exact YMD: {0}" -f (Format-Opt $chosen)) "DEBUG"

if (-not $chosen) {
    $chosen = Find-RangeYMD -Today $today
    Write-Log ("Candidate #2 range YMD: {0}" -f (Format-Opt $chosen)) "DEBUG"
}
if (-not $chosen) {
    $chosen = Find-ExactMD -Today $today
    Write-Log ("Candidate #3 exact MD: {0}" -f (Format-Opt $chosen)) "DEBUG"
}
if (-not $chosen) {
    $chosen = Find-RangeMD -Today $today
    Write-Log ("Candidate #4 range MD: {0}" -f (Format-Opt $chosen)) "DEBUG"
}
if (-not $chosen) {
    $chosen = Find-Default
    Write-Log ("Candidate #5 default: {0}" -f (Format-Opt $chosen)) "DEBUG"
}

if (-not $chosen) {
    Write-Log "No matching wallpaper found (even default). Exiting." "ERROR"
    Write-Log "---- Script end ----"
    exit 0
}

# Trim any whitespace from chosen path (in case filename has trailing/leading spaces)
Write-Log "Chosen before trim: '$chosen' (length: $($chosen.Length))" "DEBUG"
if ($chosen) {
    $chosen = $chosen.Trim()
}
Write-Log "Chosen after trim: '$chosen' (length: $($chosen.Length))" "DEBUG"

Write-Log "Chosen wallpaper: '$chosen'"
Write-Log ("Chosen exists: {0}" -f (Test-Path -LiteralPath $chosen)) "DEBUG"

# Avoid re-setting if already the same
if ($current -and ([string]::Equals($current, $chosen, [StringComparison]::OrdinalIgnoreCase))) {
    Write-Log "Chosen wallpaper is already set. Nothing to do." "INFO"
    Write-Log "---- Script end ----"
    exit 0
}

try {
    Set-Wallpaper -Path $chosen -WallpaperStyle $Style
    Write-Log "Wallpaper set successfully."
} catch {
    Write-Log ("Failed to set wallpaper: {0}" -f $_.Exception.Message) "ERROR"
}

Write-Log "---- Script end ----"
