<#
push-to-github.ps1
A small helper script to initialize the local repo (if needed), optionally create a GitHub repo using the gh CLI, add the remote, and push the current branch.
Usage (PowerShell):
  .\push-to-github.ps1 [-RepoName <name>] [-Owner <owner>] [-CreateWithGh] [-UseSsh]
Examples:
  .\push-to-github.ps1 -RepoName API-Automation-E2E -Owner kamalprasadpandey
  .\push-to-github.ps1 -CreateWithGh -RepoName API-Automation-E2E
Notes:
 - This script expects Git to be installed. If you want to create the repo automatically, install the GitHub CLI (gh) and authenticate with `gh auth login` first.
 - For HTTPS pushes use Windows Credential Manager (credential.helper manager-core) or provide a PAT when prompted.
 - For SSH, ensure your public key is added to GitHub and ssh-agent is running.
#>
param(
    [string]$RepoName = "API-Automation-E2E",
    [string]$Owner = "kamalprasadpandey",
    [switch]$CreateWithGh,
    [switch]$UseSsh
)

function ExitWithError($msg) {
    Write-Error $msg
    exit 1
}

# Ensure git exists
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    ExitWithError "git not found. Install Git for Windows (https://git-scm.com) and re-run this script."
}

$cwd = Get-Location
Write-Host "Working directory: $cwd"

# Initialize git if needed
if (-not (Test-Path ".git")) {
    git init
    Write-Host "Initialized empty git repository."
}

# Ensure user config exists
$userName = git config user.name
if (-not $userName) {
    git config user.name "Kamal Pandey"
    Write-Host "Set git user.name to 'Kamal Pandey' (change with git config --global user.name)"
}
$userEmail = git config user.email
if (-not $userEmail) {
    git config user.email "kamal@example.com"
    Write-Host "Set git user.email to 'kamal@example.com' (change with git config --global user.email)"
}

# Stage and commit
git add .
$commitResult = git commit -m "Initial commit from local" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Commit result: $commitResult"
    Write-Host "(This usually means there was nothing new to commit.)"
} else {
    Write-Host "Committed changes."
}

# Ensure branch main
git branch -M main

$remoteUrl = if ($UseSsh) { "git@github.com:$Owner/$RepoName.git" } else { "https://github.com/$Owner/$RepoName.git" }

if ($CreateWithGh) {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        ExitWithError "gh (GitHub CLI) not found. Install it from https://cli.github.com and run 'gh auth login' before using -CreateWithGh."
    }
    Write-Host "Creating repository $Owner/$RepoName using gh..."
    gh repo create "$Owner/$RepoName" --source . --remote origin --public --push
    if ($LASTEXITCODE -ne 0) {
        ExitWithError "gh repo create failed. See message above."
    }
    Write-Host "Repository created and pushed via gh."
    exit 0
}

# Add or update remote
if (git remote get-url origin 2>$null) {
    Write-Host "Remote 'origin' already exists. Updating to $remoteUrl"
    git remote set-url origin $remoteUrl
} else {
    git remote add origin $remoteUrl
}

Write-Host "Remote origin set to:"
git remote -v

# Suggest credential helper for HTTPS
if (-not $UseSsh) {
    Write-Host "Configuring credential helper to manager-core for Windows credential caching..."
    git config --global credential.helper manager-core
}

Write-Host "Pushing branch 'main' to origin (will prompt for credentials if needed)..."
git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Write-Error "Push failed. Inspect the output above. Common fixes: authenticate (gh auth login or set up SSH), ensure remote repo exists, or resolve non-fast-forward by pulling first."
    exit 1
}

Write-Host "Push successful. Repo is at: $remoteUrl"
exit 0

