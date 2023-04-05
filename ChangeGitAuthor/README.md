# Change Git Author PowerShell Script

This PowerShell script allows you to change the author and committer information of commits in a Git repository. It can be used to update the author and committer name and email for all commits in the specified Git repository.

## Prerequisites

- PowerShell 5.1 or later
- Git command line tool
- All local commits pushed

## Usage

*Backup your repository just in case.*

1. Save the provided script as a file named `ChangeGitAuthor.ps1`.
2. Open a PowerShell terminal.
3. Navigate to the directory containing the `ChangeGitAuthor.ps1` script.
4. Run the script by providing the path to the Git repository and the new author information, as shown in the following example:
5. If you are happy with the results run `git push --force`

```powershell
.\ChangeGitAuthor.ps1 -RepoFolderPath "C:\path\to\your\repository" -NewAuthor "New Author Name <new.author@example.com>"
```

Replace `C:\path\to\your\repository` with the actual path to your Git repository, and `New Author Name <new.author@example.com>` with the desired author name and email.

## Parameters

`-RepoFolderPath`: The path to the Git repository folder.
`-NewAuthor`: The new author information in the format "Author Name author@email.com".

## Notes

- The script will change the author and committer information for all commits in the repository, including branches and tags.
- Be cautious when using this script on shared repositories, as it will rewrite the commit history, which can cause issues for collaborators.