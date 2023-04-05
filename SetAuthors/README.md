# Set Git Authors

This PowerShell script sets the author information (name and email) for all git repositories within a parent folder. It also handles an exception folder, setting different author information for all git repositories within the exception folder's subdirectories.

## Requirements

- Git for Windows
- PowerShell (Windows)

## Usage

1. Save the script as `SetAuthors.ps1` in your preferred location.

2. Open PowerShell and navigate to the location where you saved the script.

3. Run the script with the desired parameters:

```powershell
.\SetAuthors.ps1 -ParentFolder "C:\path\to\parent\folder" -ExceptionFolder "C:\path\to\exception\folder" -GlobalName "Your Name" -GlobalEmail "your.email@example.com" -ExceptionName "Exception Name" -ExceptionEmail "exception.email@example.com"
```

Replace the parameter values with your desired folder paths and author information.

## Parameters
`-ParentFolder`: The path to the parent folder containing all git repositories.
`-ExceptionFolder`: The path to the exception folder containing subdirectories with git repositories that require different author information.
`-GlobalName`: The name of the author to be set for all repositories in the parent folder, except those within the exception folder.
`-GlobalEmail`: The email of the author to be set for all repositories in the parent folder, except those within the exception folder.
`-ExceptionName`: The name of the author to be set for all repositories within the exception folder's subdirectories.
`-ExceptionEmail`: The email of the author to be set for all repositories within the exception folder's subdirectories.

## How It Works

The script will iterate through all repositories in the parent folder, setting the global author for each. If it encounters the exception folder, it will set the exception author for all repositories within the exception folder's subdirectories, regardless of the depth.