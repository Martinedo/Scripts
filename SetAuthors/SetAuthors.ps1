param (
    [string]$ParentFolder = "C:\path\to\parent\folder",
    [string]$ExceptionFolder = "C:\path\to\exception\folder",
    [string]$GlobalName = "Your Name",
    [string]$GlobalEmail = "your.email@example.com",
    [string]$ExceptionName = "Exception Name",
    [string]$ExceptionEmail = "exception.email@example.com"
)

function Set-GitAuthor {
    param (
        [string]$RepoPath,
        [string]$Name,
        [string]$Email
    )
    Set-Location -Path $RepoPath
    if (Test-Path ".git") {
        git config user.name $Name
        git config user.email $Email
    }
}

function Process-Subfolders {
    param (
        [string]$ParentPath,
        [string]$Name,
        [string]$Email
    )
    $folders = Get-ChildItem -Path $ParentPath -Directory
    foreach ($folder in $folders) {
        Set-GitAuthor -RepoPath $folder.FullName -Name $Name -Email $Email
        Process-Subfolders -ParentPath $folder.FullName -Name $Name -Email $Email
    }
}

$globalRepos = Get-ChildItem -Path $ParentFolder -Directory

foreach ($repo in $globalRepos) {
    if ($repo.FullName -eq $ExceptionFolder) {
        Process-Subfolders -ParentPath $ExceptionFolder -Name $ExceptionName -Email $ExceptionEmail
    } else {
        Set-GitAuthor -RepoPath $repo.FullName -Name $GlobalName -Email $GlobalEmail
    }
}
