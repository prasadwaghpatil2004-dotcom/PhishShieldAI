#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$CheckOnly,
    [ValidatePattern('^[A-Za-z0-9_-]*$')][string]$VercelScope = ''
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}
$ProjectRoot = $PSScriptRoot
$RepoName = 'scamalert-ai'
$ApprovedFiles = @('index.html', '.gitignore', '.vercelignore', 'vercel.json', 'README.md', 'deploy.bat', 'deploy.ps1')
$DefaultFiles = [ordered]@{
    '.gitignore' = (@(
        '# Publish only the standalone app and deployment documentation.',
        '*',
        '!/.gitignore',
        '!/.vercelignore',
        '!/index.html',
        '!/vercel.json',
        '!/README.md',
        '!/deploy.bat',
        '!/deploy.ps1'
    ) -join "`n")
    '.vercelignore' = (@(
        '# Upload only the static application and its hosting configuration.',
        '*',
        '!index.html',
        '!vercel.json'
    ) -join "`n")
    'vercel.json' = (@(
        '{',
        '  "$schema": "https://openapi.vercel.sh/vercel.json",',
        '  "framework": null,',
        '  "buildCommand": "",',
        '  "installCommand": "",',
        '  "outputDirectory": ".",',
        '  "cleanUrls": true,',
        '  "trailingSlash": false,',
        '  "headers": [',
        '    {',
        '      "source": "/(.*)",',
        '      "headers": [',
        '        { "key": "X-Content-Type-Options", "value": "nosniff" },',
        '        { "key": "X-Frame-Options", "value": "DENY" },',
        '        { "key": "Referrer-Policy", "value": "no-referrer" },',
        '        { "key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=(), payment=()" },',
        '        { "key": "Cache-Control", "value": "public, max-age=0, must-revalidate" }',
        '      ]',
        '    }',
        '  ]',
        '}'
    ) -join "`n")
    'README.md' = (@(
        '# PhishShield AI | scamalert-ai',
        '',
        '**Real-Time Threat Forensics & Social Engineering Defense**',
        '',
        'A single-file, browser-based phishing and social engineering scanner. Paste an email, SMS, or work chat, or import an email file, to inspect identity, pressure, sensitive requests, and suspicious destinations. Every finding links back to the original text and explains its contribution to the threat score.',
        '',
        '**Live demo:** after deployment, use this repository''s **About -> Website** link. The deployment script also prints the GitHub and production Vercel URLs and saves them locally in `deployment-urls.txt`.',
        '',
        '## Run locally',
        '',
        'Open `index.html` in a modern browser. No server, API key, database, npm install, or build step is required to use the app. Critical CSS, SVG icons, heuristics, and file handling are embedded. Tailwind''s CDN is an optional styling enhancement; the embedded stylesheet provides the complete layout.',
        '',
        '## One-command Windows deployment',
        '',
        'Keep all seven project files together and run in PowerShell or CMD:',
        '',
        '```powershell',
        '.\deploy.bat',
        '```',
        '',
        'The launcher uses the included PowerShell helper with a process-scoped execution policy; it does not change the machine''s policy.',
        '',
        'The script:',
        '',
        '1. Checks Git, GitHub CLI (`gh`), and Vercel CLI. Missing tools produce a one-line install command and a nonzero exit code. Open a fresh terminal after installing tools.',
        '2. Checks `gh auth status` and `vercel whoami`. If necessary, starts `gh auth login --web` and `vercel login`; complete those one-time sign-ins. After authentication, project linking and deployment use non-interactive flags.',
        '3. Creates an isolated local Git repository and generates missing `.gitignore`, `.vercelignore`, `vercel.json`, and this README. Existing files are preserved; unsafe hosting/ignore settings cause a clear error.',
        '4. Commits only the explicit project allowlist. It refuses unrelated tracked files, unrelated staged changes, unrelated history, private repositories, or a mismatched `origin`. It never force-pushes or overwrites a remote.',
        '5. Creates a **public** `scamalert-ai` repository on the authenticated **github.com** account with `gh repo create scamalert-ai --public --source=. --remote=origin --push`. A subsequent run resumes only when the existing origin matches that same public repository.',
        '6. Links the Vercel project `scamalert-ai` and runs `vercel --prod --yes` in the selected scope. Vercel CLI''s actual stdout URL is used; no deployment address is guessed.',
        '7. Prints and saves both URLs and sets the GitHub repository''s About website to the production deployment URL when permitted.',
        '',
        'Select a Vercel team explicitly if needed:',
        '',
        '```powershell',
        '.\deploy.bat -VercelScope your-team-slug',
        '```',
        '',
        'Read-only preflight (does not log in, initialize Git, create repositories, or deploy):',
        '',
        '```powershell',
        '.\deploy.bat -CheckOnly',
        '```',
        '',
        'For a first deployment, `scamalert-ai` must be available on your GitHub account. If it already exists and is not this checkout''s verified origin, the script stops rather than adopting or exposing another repository. Authentication, network access, repository creation permission, and a usable Vercel account are required. Existing Vercel project links or environment-bound project IDs are checked before use.',
        '',
        '### Install prerequisites',
        '',
        'Run the relevant command if prompted:',
        '',
        '```powershell',
        'winget install --id Git.Git --exact --source winget',
        'winget install --id GitHub.cli --exact --source winget',
        'winget install --id OpenJS.NodeJS.LTS --exact --source winget',
        'npm install -g vercel',
        '```',
        '',
        'Node.js/npm is needed for Vercel CLI, not to run the static app. Git author details, if missing, are configured only in this repository using the authenticated account''s public name/login and GitHub no-reply address. The GitHub CLI credential helper is configured **locally for this repository**, with no token written into project files.',
        '',
        '## A 90-second judge walkthrough',
        '',
        '1. Choose **Email** and enter `IT Security <security@rnicrosoft.test>` as the sender.',
        '2. Paste this isolated synthetic example and click **Analyze Threat Forensics**:',
        '',
        '```text',
        'URGENT: Your account will be suspended within 2 hours.',
        'Confirm your password and OTP at http://192.0.2.44/verify.',
        'Do not call. Keep this between us.',
        '```',
        '',
        '3. Observe **100/100 Critical Threat**, sender lookalike evidence, coercion and credential flags, and an IP/HTTP link warning. Click a highlight or evidence card for its explanation; filter evidence categories and inspect the score calculation.',
        '4. Start a new investigation. Use `jane@example.com` and `The meeting notes are attached. Thank you.` to see **0/100 Low Risk** with no matched signals.',
        '5. Enter `not-an-email` with no message to see the malformed-sender finding and **25/100**, demonstrating that sender-only checks work.',
        '6. Import `.eml` or `.txt`: From and Subject are parsed, readable MIME text is decoded, and analysis starts automatically, even when live typing is off.',
        '7. Import PNG/JPG: preview the image and inspect genuine metadata. No OCR engine is bundled; screenshots remain **not assessed** until actual OCR text or a transcription is supplied. No sample message text is invented.',
        '8. Download the forensic JSON report. It includes the original message, signals, scoring, and recommendations; treat it as private.',
        '',
        '## Features',
        '',
        '| Capability | What judges can inspect |',
        '| --- | --- |',
        '| Universal message input | Email, SMS, and work chat, including case-insensitive analysis |',
        '| Sender checks | Malformed addresses, public-webmail brand claims, lookalikes, TLD watchlists, and corporate claims from personal-style SMS numbers |',
        '| Language analysis | Urgency, credentials, codes, payment requests, and secrecy |',
        '| URL inspection | Shorteners, IP destinations, HTTP, TLD indicators, Unicode and user-info tricks, plus HTML/Markdown anchor mismatches |',
        '| Explainable scoring | Category caps, combination bonuses, SVG meter, risk badges, and source-linked evidence |',
        '| Local file imports | EML/TXT decoding, folded/encoded headers, multipart text, and PNG/JPG previews |',
        '| Local session tools | In-memory scan history, stale-result protection, and JSON report download |',
        '',
        '## Scoring and limits',
        '',
        'Category caps are sender/domain 35, urgency 22, sensitive requests 35, secrecy 20, and suspicious links 40. Each distinct rule contributes once; repeated phrases remain visible but do not multiply the rule''s score. Pressure plus sensitive requests adds 8, and suspicious links plus sensitive requests adds 8. Total risk is capped at 100.',
        '',
        '- **0-30:** Low Risk.',
        '- **31-65:** Suspicious.',
        '- **66-100:** Critical Threat.',
        '',
        'These are heuristic thresholds, not calibrated fraud probabilities. Low risk does not prove authenticity, and legitimate text may trigger rules. There are no live DNS, reputation, malware, SPF, DKIM, or DMARC checks. The header preview is illustrative, not fabricated authentication evidence.',
        '',
        'Limits: 100,000 message characters, 300 retained URL occurrences, and 1,000 displayed findings; imports are limited to 2 MB of email/text or 10 MB of PNG/JPG. Image previews are limited to 40 megapixels and 20,000 pixels per side. Email attachments are not opened. Imported HTML is inert text.',
        '',
        '## Privacy and deployment boundaries',
        '',
        'The app opens no inspected links, runs no pasted HTML, and uploads no message or screenshot content. Session history is in tab memory and resets on reload. A report download is an explicit local export of the message.',
        '',
        'Git''s allowlist contains only the seven project files below. Vercel''s upload allowlist contains only `index.html` and `vercel.json`. Scratch work, sample uploads, screenshots, environment files, `.vercel/`, tokens, logs, and `deployment-urls.txt` are excluded. New assets must be reviewed and added to the relevant allowlists deliberately.',
        '',
        '```text',
        'index.html        Complete browser application',
        'deploy.bat        Windows launcher',
        'deploy.ps1        Checked GitHub + Vercel deployment workflow',
        'vercel.json       Static hosting and security/cache headers',
        '.gitignore        Explicit Git project allowlist',
        '.vercelignore     Minimal hosting upload allowlist',
        'README.md         Judge walkthrough and operations guide',
        '```',
        '',
        'The static site has no build step or server runtime. Production deployment protection is inherited from Vercel. If judges receive a login page, review the project''s Deployment Protection settings; the script does not weaken security settings automatically. There is no automatic Git-triggered deployment configured by this script; rerun it after updating `index.html`.',
        '',
        '## Troubleshooting',
        '',
        '- **Tool missing:** run the printed install line, open a fresh terminal, and rerun.',
        '- **Login required:** finish the browser/device login in the same terminal; do not paste tokens into project files.',
        '- **Repository already exists / wrong origin:** use the intended checkout or resolve the name conflict. Do not delete a repository to make this script pass.',
        '- **Push rejected:** inspect remote changes and reconcile them normally. The script never uses `--force`.',
        '- **Vercel build or permission failure:** read `.deploy-output/vercel-stderr.txt`. A failed command exits nonzero and does not claim success.',
        '- **Deployment succeeded but no URL parsed:** inspect `.deploy-output/vercel-stdout.txt` and the Vercel dashboard before retrying.',
        '- **Public access cannot be confirmed:** the printed URL is the actual production deployment; confirm availability in a signed-out browser before sharing.',
        '',
        '## Official command references',
        '',
        '- [GitHub repository creation](https://cli.github.com/manual/gh_repo_create)',
        '- [GitHub authentication](https://cli.github.com/manual/gh_auth_status)',
        '- [Vercel production deployment and stdout URL contract](https://vercel.com/docs/cli/deploy)',
        '- [Vercel project linking](https://vercel.com/docs/cli/link)',
        '- [Vercel static project configuration](https://vercel.com/docs/project-configuration/vercel-json)'
    ) -join "`n")
}

function Resolve-Tool {
    param([string[]]$Names)
    foreach ($candidate in $Names) {
        $found = Get-Command $candidate -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { return $found.Source }
    }
    return $null
}
function Invoke-Native {
    param([string]$Command, [string[]]$CliArguments, [switch]$Quiet)
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $lines = @(& $Command @CliArguments 2>&1)
        $statusCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previousPreference }
    $message = ($lines | ForEach-Object { $_.ToString() }) -join "`n"
    if (-not $Quiet -and $message) { Write-Host $message }
    return [pscustomobject]@{ Code = $statusCode; Text = $message.Trim() }
}
function Invoke-Checked {
    param([string]$Command, [string[]]$CliArguments, [switch]$Quiet)
    $response = Invoke-Native -Command $Command -CliArguments $CliArguments -Quiet:$Quiet
    if ($response.Code -ne 0) {
        if ($Quiet -and $response.Text) { Write-Host $response.Text -ForegroundColor Yellow }
        throw ('Command failed (exit ' + $response.Code + '): ' + [IO.Path]::GetFileName($Command) + ' ' + ($CliArguments -join ' '))
    }
    return $response.Text
}
function Invoke-Interactive {
    param([string]$Command, [string[]]$CliArguments)
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & $Command @CliArguments
        $interactiveExitCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previousPreference }
    if ($interactiveExitCode -ne 0) { throw 'Authentication did not complete successfully. Finish login and rerun deploy.bat.' }
}
function Write-Utf8 {
    param([string]$Path, [string]$Content)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $Content.TrimEnd() + "`n", $encoding)
}
function Normalize-Text { param([string]$Text) return $Text.Replace("`r`n", "`n").TrimEnd() }
function Ensure-ProjectFiles {
    param([switch]$ReadOnly)
    foreach ($name in $DefaultFiles.Keys) {
        $path = Join-Path $ProjectRoot $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            if ($ReadOnly) { throw ('Missing ' + $name + '. Run deploy.bat normally to generate it.') }
            Write-Utf8 -Path $path -Content $DefaultFiles[$name]
            Write-Host ('Created ' + $name)
        }
    }
    foreach ($name in @('.gitignore', '.vercelignore')) {
        if ((Normalize-Text ([IO.File]::ReadAllText((Join-Path $ProjectRoot $name)))) -cne (Normalize-Text $DefaultFiles[$name])) {
            throw ($name + ' differs from the single-file deployment allowlist. Review it before publishing; this script will not overwrite it.')
        }
    }
    $config = Get-Content -LiteralPath (Join-Path $ProjectRoot 'vercel.json') -Raw | ConvertFrom-Json
    foreach ($property in @('framework', 'buildCommand', 'installCommand', 'outputDirectory')) {
        if ($config.PSObject.Properties.Name -notcontains $property) { throw ('vercel.json is missing ' + $property) }
    }
    if ($null -ne $config.framework -or $config.buildCommand -ne '' -or $config.installCommand -ne '' -or $config.outputDirectory -ne '.') {
        throw 'vercel.json must use framework=null, empty build/install commands, and outputDirectory="." for this static project.'
    }
}
function Assert-VercelTarget {
    $path = Join-Path $ProjectRoot '.vercel/project.json'
    $link = $null
    if (Test-Path -LiteralPath $path) {
        $link = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        if ($link.PSObject.Properties.Name -notcontains 'projectName') {
            throw 'Existing .vercel/project.json has no projectName. Verify/archive that link manually or update Vercel CLI before continuing.'
        }
        if ($link.projectName -cne $RepoName) { throw ('Existing Vercel link targets ' + $link.projectName + ', not ' + $RepoName + '. No project was changed.') }
    }
    foreach ($binding in @(@('VERCEL_PROJECT_ID', 'projectId'), @('VERCEL_ORG_ID', 'orgId'))) {
        $value = [Environment]::GetEnvironmentVariable($binding[0], 'Process')
        if ($value) {
            if (-not $link -or $link.PSObject.Properties.Name -notcontains $binding[1] -or $link.($binding[1]) -cne $value) {
                throw ($binding[0] + ' conflicts with the verified local project link. Use the intended account/scope environment before rerunning.')
            }
        }
    }
}
function Assert-ApprovedPaths {
    param([string]$Text, [string]$Description)
    $unexpected = @($Text -split "`r?`n" | Where-Object { $_ -and $ApprovedFiles -cnotcontains $_ } | Sort-Object -Unique)
    if ($unexpected.Count -gt 0) {
        Write-Host ($unexpected -join "`n") -ForegroundColor Yellow
        throw ('Unrelated files found in ' + $Description + '. Use a clean app-only checkout; no unrelated content will be published.')
    }
}

$previousLocation = Get-Location
$previousGhHost = [Environment]::GetEnvironmentVariable('GH_HOST', 'Process')
$exitStatus = 0
try {
    Set-Location -LiteralPath $ProjectRoot
    Write-Host "`nPhishShield AI / scamalert-ai deployment" -ForegroundColor Cyan
    if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot 'index.html') -PathType Leaf)) { throw 'index.html must be alongside deploy.bat and deploy.ps1.' }
    $Git = Resolve-Tool @('git.exe', 'git')
    $Gh = Resolve-Tool @('gh.exe', 'gh')
    $Vercel = Resolve-Tool @('vercel.cmd', 'vercel.exe', 'vercel')
    $missingTools = 0
    if (-not $Git) { Write-Host 'Install Git: winget install --id Git.Git --exact --source winget' -ForegroundColor Yellow; $missingTools++ }
    if (-not $Gh) { Write-Host 'Install GitHub CLI: winget install --id GitHub.cli --exact --source winget' -ForegroundColor Yellow; $missingTools++ }
    if (-not $Vercel) {
        Write-Host 'Install Vercel CLI: npm install -g vercel' -ForegroundColor Yellow
        if (-not (Resolve-Tool @('npm.cmd', 'npm'))) { Write-Host 'Install Node.js/npm first: winget install --id OpenJS.NodeJS.LTS --exact --source winget' -ForegroundColor Yellow }
        $missingTools++
    }
    if ($missingTools) { throw 'Install the missing tools, open a fresh terminal, and rerun deploy.bat.' }
    $null = Invoke-Checked $Git @('--version')
    $null = Invoke-Checked $Gh @('--version')
    $null = Invoke-Checked $Vercel @('--version')
    Ensure-ProjectFiles -ReadOnly:$CheckOnly
    Assert-VercelTarget
    $env:GH_HOST = 'github.com'
    Write-Host "`nChecking GitHub authentication..." -ForegroundColor Cyan
    $auth = Invoke-Native $Gh @('auth', 'status', '--hostname', 'github.com')
    if ($auth.Code -ne 0) {
        if ($CheckOnly) { throw 'GitHub login required. Run: gh auth login --hostname github.com --git-protocol https --web' }
        Invoke-Interactive $Gh @('auth', 'login', '--hostname', 'github.com', '--git-protocol', 'https', '--web')
        $null = Invoke-Checked $Gh @('auth', 'status', '--hostname', 'github.com')
    }
    Write-Host "`nChecking Vercel authentication..." -ForegroundColor Cyan
    $auth = Invoke-Native $Vercel @('whoami')
    if ($auth.Code -ne 0) {
        if ($CheckOnly) { throw 'Vercel login required. Run: vercel login' }
        Invoke-Interactive $Vercel @('login')
        $null = Invoke-Checked $Vercel @('whoami')
    }
    $account = (Invoke-Checked $Gh @('api', 'user', '--hostname', 'github.com') -Quiet) | ConvertFrom-Json
    if ($account.login -notmatch '^[A-Za-z0-9-]+$' -or [string]$account.id -notmatch '^\d+$') { throw 'GitHub did not return a valid account identity.' }
    $owner = [string]$account.login
    $targetRepo = $owner + '/' + $RepoName
    Write-Host ('GitHub target: ' + $targetRepo + ' (public)') -ForegroundColor Cyan
    if ($CheckOnly) {
        Write-Host "Preflight passed. No login, Git initialization, repository creation, commit, or deployment was performed." -ForegroundColor Green
    } else {
        if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot '.git'))) {
            $null = Invoke-Checked $Git @('init', '--initial-branch=main', '.')
        }
        $top = Invoke-Checked $Git @('rev-parse', '--show-toplevel') -Quiet
        if (-not [string]::Equals([IO.Path]::GetFullPath($top), [IO.Path]::GetFullPath($ProjectRoot), [StringComparison]::OrdinalIgnoreCase)) { throw 'Git repository root is not this project directory.' }
        Assert-ApprovedPaths (Invoke-Checked $Git @('ls-files') -Quiet) 'the Git index'
        Assert-ApprovedPaths (Invoke-Checked $Git @('diff', '--cached', '--name-only') -Quiet) 'staged changes'
        $head = Invoke-Native $Git @('rev-parse', '--verify', 'HEAD') -Quiet
        if ($head.Code -eq 0) { Assert-ApprovedPaths (Invoke-Checked $Git @('log', '--all', '--format=', '--name-only') -Quiet) 'repository history' }
        $branch = Invoke-Checked $Git @('symbolic-ref', '--quiet', '--short', 'HEAD') -Quiet
        if (-not $branch) { throw 'Detached HEAD is unsupported. Check out a branch before deploying.' }
        $originResult = Invoke-Native $Git @('remote', 'get-url', 'origin') -Quiet
        $hasOrigin = $originResult.Code -eq 0
        if ($hasOrigin) {
            $safeTarget = [regex]::Escape($targetRepo)
            if ($originResult.Text -notmatch ('^(?:https://github\.com/|git@github\.com:|ssh://git@github\.com/)' + $safeTarget + '(?:\.git)?/?$')) { throw ('Existing origin does not match ' + $targetRepo + '. It will not be overwritten.') }
        }
        $remoteInfo = Invoke-Native $Gh @('repo', 'view', $targetRepo, '--json', 'url,isPrivate,nameWithOwner') -Quiet
        $existingRemote = $remoteInfo.Code -eq 0
        if ($existingRemote) {
            $remote = $remoteInfo.Text | ConvertFrom-Json
            if ($remote.nameWithOwner -ine $targetRepo -or $remote.isPrivate) { throw 'Existing repository is private or belongs to a different owner. It will not be exposed or modified.' }
            if (-not $hasOrigin) { throw ($targetRepo + ' already exists. Use its intended checkout, or review and link origin manually before rerunning.') }
        } elseif ($hasOrigin) { throw 'Existing origin could not be verified on GitHub. Check authentication/network access before rerunning.' }
        foreach ($key in @('user.name', 'user.email')) {
            $identity = Invoke-Native $Git @('config', '--get', $key) -Quiet
            if ($identity.Code -ne 0 -or -not $identity.Text) {
                $value = if ($key -eq 'user.name') { if ($account.name) { [string]$account.name } else { $owner } } else { [string]$account.id + '+' + $owner + '@users.noreply.github.com' }
                $null = Invoke-Checked $Git @('config', '--local', $key, $value) -Quiet
            }
        }
        # Empty native arguments need explicit quote preservation on Windows PowerShell 5.1.
        $emptyArgument = ''
        $passingMode = Get-Variable PSNativeCommandArgumentPassing -ErrorAction SilentlyContinue
        if ($PSVersionTable.PSVersion.Major -lt 7 -or ($passingMode -and $passingMode.Value -eq 'Legacy')) { $emptyArgument = '""' }
        # Repository-local URL rewrites let gh's token authenticate GitHub pushes even
        # when the user's default gh transport is SSH. No global settings are changed.
        $null = Invoke-Checked $Git @('config', '--local', '--replace-all', 'url.https://github.com/.insteadOf', 'git@github.com:') -Quiet
        $null = Invoke-Checked $Git @('config', '--local', '--add', 'url.https://github.com/.insteadOf', 'ssh://git@github.com/') -Quiet
        $credentialKey = 'credential.https://github.com.helper'
        $null = Invoke-Checked $Git @('config', '--local', '--replace-all', $credentialKey, $emptyArgument) -Quiet
        $null = Invoke-Checked $Git @('config', '--local', '--add', $credentialKey, '!gh auth git-credential') -Quiet
        $null = Invoke-Checked $Git (@('add', '--') + $ApprovedFiles)
        $diff = Invoke-Native $Git @('diff', '--cached', '--quiet') -Quiet
        if ($diff.Code -eq 1) { $null = Invoke-Checked $Git @('commit', '-m', 'Prepare PhishShield AI static production deployment') }
        elseif ($diff.Code -ne 0) { throw 'Could not inspect staged changes.' }
        Write-Host "`nPublishing the GitHub source..." -ForegroundColor Cyan
        if ($existingRemote) { $null = Invoke-Checked $Git @('push', '--set-upstream', 'origin', $branch) }
        else { $null = Invoke-Checked $Gh @('repo', 'create', $RepoName, '--public', '--source=.', '--remote=origin', '--push') }
        $githubUrl = (Invoke-Checked $Gh @('repo', 'view', $targetRepo, '--json', 'url', '--jq', '.url') -Quiet).Trim()
        if ($githubUrl -ine ('https://github.com/' + $targetRepo)) { throw 'GitHub returned an unexpected repository URL.' }
        Write-Host ('GitHub repository: ' + $githubUrl) -ForegroundColor Green
        Write-Host "`nLinking Vercel project scamalert-ai..." -ForegroundColor Cyan
        $linkArguments = @('link', '--yes', '--project', $RepoName)
        if ($VercelScope) { $linkArguments += @('--scope', $VercelScope) }
        $null = Invoke-Checked $Vercel $linkArguments
        Assert-VercelTarget
        $logDirectory = Join-Path $ProjectRoot '.deploy-output'
        $null = New-Item -ItemType Directory -Path $logDirectory -Force
        $stderrPath = Join-Path $logDirectory 'vercel-stderr.txt'
        $stdoutPath = Join-Path $logDirectory 'vercel-stdout.txt'
        $deploymentArguments = @('--prod', '--yes')
        if ($VercelScope) { $deploymentArguments += @('--scope', $VercelScope) }
        Write-Host 'Deploying to Vercel production. Progress/errors are saved in .deploy-output/vercel-stderr.txt...' -ForegroundColor Cyan
        $previousPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $deploymentLines = @(& $Vercel @deploymentArguments 2> $stderrPath)
            $deploymentExitCode = $LASTEXITCODE
        } finally { $ErrorActionPreference = $previousPreference }
        $deploymentText = ($deploymentLines | ForEach-Object { $_.ToString() }) -join "`n"
        Write-Utf8 -Path $stdoutPath -Content $deploymentText
        if (Test-Path -LiteralPath $stderrPath) {
            $progress = Get-Content -LiteralPath $stderrPath -Raw
            if ($progress) { Write-Host $progress }
        }
        if ($deploymentExitCode -ne 0) { throw ('Vercel production deployment failed (exit ' + $deploymentExitCode + '). See .deploy-output logs. GitHub source remains at ' + $githubUrl) }
        $plainOutput = [regex]::Replace($deploymentText, '\x1B\[[0-?]*[ -/]*[@-~]', '')
        $urlMatches = @([regex]::Matches($plainOutput, '(?m)^\s*(https://[^\s<>]+)\s*$') | ForEach-Object { $_.Groups[1].Value.Trim() } | Select-Object -Unique)
        if ($urlMatches.Count -ne 1) { throw 'Vercel returned success but no unambiguous deployment URL. Check .deploy-output/vercel-stdout.txt and your Vercel dashboard before retrying.' }
        $vercelUrl = $urlMatches[0]
        $parsedUri = $null
        if (-not [Uri]::TryCreate($vercelUrl, [UriKind]::Absolute, [ref]$parsedUri) -or $parsedUri.Scheme -ne 'https' -or -not $parsedUri.Host -or $parsedUri.UserInfo) { throw 'Vercel returned an invalid HTTPS deployment URL. Inspect the logs before retrying.' }
        $linksText = 'GitHub repository: ' + $githubUrl + "`n" + 'Vercel production: ' + $vercelUrl
        Write-Utf8 -Path (Join-Path $ProjectRoot 'deployment-urls.txt') -Content $linksText
        Write-Host "`nDEPLOYMENT COMPLETE" -ForegroundColor Green
        Write-Host $linksText -ForegroundColor Green
        Write-Host ('Links saved to ' + (Join-Path $ProjectRoot 'deployment-urls.txt'))
        $homepage = Invoke-Native $Gh @('repo', 'edit', $targetRepo, '--homepage', $vercelUrl) -Quiet
        if ($homepage.Code -ne 0) { Write-Warning 'Deployment succeeded, but the GitHub About website could not be updated. Use the URLs printed above.' }
        try {
            $page = Invoke-WebRequest -Uri $vercelUrl -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 30
            $localHtml = [IO.File]::ReadAllText((Join-Path $ProjectRoot 'index.html'))
            $title = [regex]::Match($localHtml, '(?is)<title>.*?</title>').Value
            if ($page.StatusCode -eq 200 -and $title -and $page.Content.Contains($title)) { Write-Host 'Public HTTP check passed: the production page serves this app.' -ForegroundColor Green }
            else { Write-Warning 'Production was deployed, but the returned page did not match the local app. Check redirects/protection in a signed-out browser before sharing.' }
        } catch { Write-Warning 'Production was deployed, but unauthenticated HTTP access could not be confirmed. Check network access and Vercel Deployment Protection before sharing.' }
    }
} catch {
    $exitStatus = 1
    [Console]::Error.WriteLine('DEPLOYMENT STOPPED: ' + $_.Exception.Message)
} finally {
    [Environment]::SetEnvironmentVariable('GH_HOST', $previousGhHost, 'Process')
    Set-Location -LiteralPath $previousLocation.Path
}
exit $exitStatus
