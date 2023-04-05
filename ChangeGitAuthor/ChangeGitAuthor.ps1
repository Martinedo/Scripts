param(
    [Parameter(Mandatory = $true)][string]$RepoFolderPath,
    [Parameter(Mandatory = $true)][string]$NewAuthor
)

function ChangeGitAuthor {
    param (
        [string]$RepoFolderPath,
        [string]$NewAuthor
    )

    if (-not (Test-Path $RepoFolderPath)) {
        Write-Host "Error: The specified folder does not exist." -ForegroundColor Red
        return
    }

    Set-Location $RepoFolderPath

    if (-not (git rev-parse --is-inside-work-tree 2>&1 | Out-String).Trim()) {
        Write-Host "Error: The specified folder is not a Git repository." -ForegroundColor Red
        return
    }

    $authorName = $NewAuthor.Split('<')[0].Trim()
    $authorEmail = $NewAuthor.Split('<>')[1]

    $envFilter = @"
export GIT_AUTHOR_NAME=`"$authorName`"
export GIT_AUTHOR_EMAIL=`"$authorEmail`"
export GIT_COMMITTER_NAME=`"$authorName`"
export GIT_COMMITTER_EMAIL=`"$authorEmail`"
"@

    git filter-branch --env-filter $envFilter --force --tag-name-filter cat -- --branches --tags

    Set-Location ..
}

ChangeGitAuthor -RepoFolderPath $RepoFolderPath -NewAuthor $NewAuthor
