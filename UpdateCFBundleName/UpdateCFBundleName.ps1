# Define the root directory (current directory)
$rootDir = Get-Location

# Get all Info.plist files in .iOS project directories, excluding bin and obj folders
$plistFiles = Get-ChildItem -Path $rootDir -Filter "Info.plist" -Recurse |
    Where-Object { $_.FullName -match "\.iOS" -and $_.FullName -notmatch "\\bin\\" -and $_.FullName -notmatch "\\obj\\" }

foreach ($plistFile in $plistFiles) {
    # Read the file lines into an array
    $fileContent = Get-Content -Path $plistFile.FullName -Raw -Encoding UTF8

    # Find the CFBundleDisplayName value
    $displayNamePattern = '<key>CFBundleDisplayName</key>\s*<string>(.*?)</string>'
    $displayNameValue = [regex]::Match($fileContent, $displayNamePattern).Groups[1].Value

    # Update CFBundleName with the CFBundleDisplayName value if found
    if ($displayNameValue) {
        # Replace CFBundleName value
        $bundleNamePattern = '(<key>CFBundleName</key>\s*<string>)(.*?)(</string>)'
        $updatedContent = [regex]::Replace($fileContent, $bundleNamePattern, "`$1$displayNameValue`$3")

        # Write the changes back to the file with the same encoding
        Set-Content -Path $plistFile.FullName -Value $updatedContent -Encoding UTF8
        Write-Host "Updated CFBundleName to CFBundleDisplayName ($displayNameValue) in $($plistFile.FullName)"
    } else {
        Write-Host "CFBundleDisplayName not found in $($plistFile.FullName)"
    }
}
