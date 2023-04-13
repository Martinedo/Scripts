# Git Repository Checker

This PowerShell script helps you identify Git repositories in a given folder and its subdirectories. It prints the repository name, path, and the current branch for each Git repository found. The script will not traverse subdirectories of a Git repository.

## Requirements

- Git for Windows
- PowerShell (Windows)

## Usage

1. Save the script as `GetActualBranch.ps1` in your preferred location.

2. Open PowerShell and navigate to the location where you saved the script.

3. Run the script with the desired parameters:

```powershell
.\GetActualBranch.ps1 -ParentFolder "C:\path\to\parent\folder"
```

Replace the parameter values with your desired folder paths and author information.

## Parameters
`-ParentFolder`: The path to the parent folder containing all git repositories.

## Example

Here's an example output when running the script with a given parent folder:

```
Repository Name: MyFirstRepo
Repository Path: C:\path\to\parent\folder\MyFirstRepo
Current Branch: main

Repository Name: AnotherProject
Repository Path: C:\path\to\parent\folder\Projects\AnotherProject
Current Branch: development

Repository Name: SampleRepo
Repository Path: C:\path\to\parent\folder\Projects\SampleRepo
Current Branch: feature/new-feature

```