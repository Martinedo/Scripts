param (
    [string]$ParentFolder
)

function Check-GitRepository {
    param (
        [string]$FolderPath
    )

    $gitFolder = Join-Path $FolderPath ".git"
    if (Test-Path $gitFolder -PathType Container) {
        try {
            $branch = git -C $FolderPath symbolic-ref --short HEAD
            $repoName = Split-Path $FolderPath -Leaf
            Write-Host "Repository Name: $repoName"
            Write-Host "Repository Path: $FolderPath"
            Write-Host "Current Branch: $branch"
            Write-Host ""
            return $true
        } catch {
            Write-Host "Error while fetching branch details for $FolderPath"
        }
    }
    return $false
}

function Get-SubDirectories {
    param (
        [string]$FolderPath
    )

    if (Check-GitRepository $FolderPath) {
        return
    }

    $subDirectories = Get-ChildItem -Path $FolderPath -Directory
    foreach ($dir in $subDirectories) {
        Get-SubDirectories $dir.FullName
    }
}

if (-not (Test-Path $ParentFolder -PathType Container)) {
    Write-Host "Parent folder not found. Please provide a valid path."
    exit
}

Get-SubDirectories $ParentFolder
