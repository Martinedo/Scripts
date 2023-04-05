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
