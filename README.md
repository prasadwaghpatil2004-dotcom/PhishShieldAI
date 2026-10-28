# PhishShield AI | scamalert-ai

**Real-Time Threat Forensics & Social Engineering Defense**

A single-file, browser-based phishing and social engineering scanner. Paste an email, SMS, or work chat, or import an email file, to inspect identity, pressure, sensitive requests, and suspicious destinations. Every finding links back to the original text and explains its contribution to the threat score.

**Live demo:** after deployment, use this repository's **About -> Website** link. The deployment script also prints the GitHub and production Vercel URLs and saves them locally in `deployment-urls.txt`.

## Run locally

Open `index.html` in a modern browser. No server, API key, database, npm install, or build step is required to use the app. Critical CSS, SVG icons, heuristics, and file handling are embedded. Tailwind's CDN is an optional styling enhancement; the embedded stylesheet provides the complete layout.

## One-command Windows deployment

Keep all seven project files together and run in PowerShell or CMD:

```powershell
.\deploy.bat
```

The launcher uses the included PowerShell helper with a process-scoped execution policy; it does not change the machine's policy.

The script:

1. Checks Git, GitHub CLI (`gh`), and Vercel CLI. Missing tools produce a one-line install command and a nonzero exit code. Open a fresh terminal after installing tools.
2. Checks `gh auth status` and `vercel whoami`. If necessary, starts `gh auth login --web` and `vercel login`; complete those one-time sign-ins. After authentication, project linking and deployment use non-interactive flags.
3. Creates an isolated local Git repository and generates missing `.gitignore`, `.vercelignore`, `vercel.json`, and this README. Existing files are preserved; unsafe hosting/ignore settings cause a clear error.
4. Commits only the explicit project allowlist. It refuses unrelated tracked files, unrelated staged changes, unrelated history, private repositories, or a mismatched `origin`. It never force-pushes or overwrites a remote.
5. Creates a **public** `scamalert-ai` repository on the authenticated **github.com** account with `gh repo create scamalert-ai --public --source=. --remote=origin --push`. A subsequent run resumes only when the existing origin matches that same public repository.
6. Links the Vercel project `scamalert-ai` and runs `vercel --prod --yes` in the selected scope. Vercel CLI's actual stdout URL is used; no deployment address is guessed.
7. Prints and saves both URLs and sets the GitHub repository's About website to the production deployment URL when permitted.

Select a Vercel team explicitly if needed:

```powershell
.\deploy.bat -VercelScope your-team-slug
```

Read-only preflight (does not log in, initialize Git, create repositories, or deploy):

```powershell
.\deploy.bat -CheckOnly
```

For a first deployment, `scamalert-ai` must be available on your GitHub account. If it already exists and is not this checkout's verified origin, the script stops rather than adopting or exposing another repository. Authentication, network access, repository creation permission, and a usable Vercel account are required. Existing Vercel project links or environment-bound project IDs are checked before use.

### Install prerequisites

Run the relevant command if prompted:

```powershell
winget install --id Git.Git --exact --source winget
winget install --id GitHub.cli --exact --source winget
winget install --id OpenJS.NodeJS.LTS --exact --source winget
npm install -g vercel
```

Node.js/npm is needed for Vercel CLI, not to run the static app. Git author details, if missing, are configured only in this repository using the authenticated account's public name/login and GitHub no-reply address. The GitHub CLI credential helper is configured **locally for this repository**, with no token written into project files.

## A 90-second judge walkthrough

1. Choose **Email** and enter `IT Security <security@rnicrosoft.test>` as the sender.
2. Paste this isolated synthetic example and click **Analyze Threat Forensics**:

```text
URGENT: Your account will be suspended within 2 hours.
Confirm your password and OTP at http://192.0.2.44/verify.
Do not call. Keep this between us.
```

3. Observe **100/100 Critical Threat**, sender lookalike evidence, coercion and credential flags, and an IP/HTTP link warning. Click a highlight or evidence card for its explanation; filter evidence categories and inspect the score calculation.
4. Start a new investigation. Use `jane@example.com` and `The meeting notes are attached. Thank you.` to see **0/100 Low Risk** with no matched signals.
5. Enter `not-an-email` with no message to see the malformed-sender finding and **25/100**, demonstrating that sender-only checks work.
6. Import `.eml` or `.txt`: From and Subject are parsed, readable MIME text is decoded, and analysis starts automatically, even when live typing is off.
7. Import PNG/JPG: preview the image and inspect genuine metadata. No OCR engine is bundled; screenshots remain **not assessed** until actual OCR text or a transcription is supplied. No sample message text is invented.
8. Download the forensic JSON report. It includes the original message, signals, scoring, and recommendations; treat it as private.

## Features

| Capability | What judges can inspect |
| --- | --- |
| Universal message input | Email, SMS, and work chat, including case-insensitive analysis |
| Sender checks | Malformed addresses, public-webmail brand claims, lookalikes, TLD watchlists, and corporate claims from personal-style SMS numbers |
| Language analysis | Urgency, credentials, codes, payment requests, and secrecy |
| URL inspection | Shorteners, IP destinations, HTTP, TLD indicators, Unicode and user-info tricks, plus HTML/Markdown anchor mismatches |
| Explainable scoring | Category caps, combination bonuses, SVG meter, risk badges, and source-linked evidence |
| Local file imports | EML/TXT decoding, folded/encoded headers, multipart text, and PNG/JPG previews |
| Local session tools | In-memory scan history, stale-result protection, and JSON report download |

## Scoring and limits

Category caps are sender/domain 35, urgency 22, sensitive requests 35, secrecy 20, and suspicious links 40. Each distinct rule contributes once; repeated phrases remain visible but do not multiply the rule's score. Pressure plus sensitive requests adds 8, and suspicious links plus sensitive requests adds 8. Total risk is capped at 100.

- **0-30:** Low Risk.
- **31-65:** Suspicious.
- **66-100:** Critical Threat.

These are heuristic thresholds, not calibrated fraud probabilities. Low risk does not prove authenticity, and legitimate text may trigger rules. There are no live DNS, reputation, malware, SPF, DKIM, or DMARC checks. The header preview is illustrative, not fabricated authentication evidence.

Limits: 100,000 message characters, 300 retained URL occurrences, and 1,000 displayed findings; imports are limited to 2 MB of email/text or 10 MB of PNG/JPG. Image previews are limited to 40 megapixels and 20,000 pixels per side. Email attachments are not opened. Imported HTML is inert text.

## Privacy and deployment boundaries

The app opens no inspected links, runs no pasted HTML, and uploads no message or screenshot content. Session history is in tab memory and resets on reload. A report download is an explicit local export of the message.

Git's allowlist contains only the seven project files below. Vercel's upload allowlist contains only `index.html` and `vercel.json`. Scratch work, sample uploads, screenshots, environment files, `.vercel/`, tokens, logs, and `deployment-urls.txt` are excluded. New assets must be reviewed and added to the relevant allowlists deliberately.

```text
index.html        Complete browser application
deploy.bat        Windows launcher
deploy.ps1        Checked GitHub + Vercel deployment workflow
vercel.json       Static hosting and security/cache headers
.gitignore        Explicit Git project allowlist
.vercelignore     Minimal hosting upload allowlist
README.md         Judge walkthrough and operations guide
```

The static site has no build step or server runtime. Production deployment protection is inherited from Vercel. If judges receive a login page, review the project's Deployment Protection settings; the script does not weaken security settings automatically. There is no automatic Git-triggered deployment configured by this script; rerun it after updating `index.html`.

## Troubleshooting

- **Tool missing:** run the printed install line, open a fresh terminal, and rerun.
- **Login required:** finish the browser/device login in the same terminal; do not paste tokens into project files.
- **Repository already exists / wrong origin:** use the intended checkout or resolve the name conflict. Do not delete a repository to make this script pass.
- **Push rejected:** inspect remote changes and reconcile them normally. The script never uses `--force`.
- **Vercel build or permission failure:** read `.deploy-output/vercel-stderr.txt`. A failed command exits nonzero and does not claim success.
- **Deployment succeeded but no URL parsed:** inspect `.deploy-output/vercel-stdout.txt` and the Vercel dashboard before retrying.
- **Public access cannot be confirmed:** the printed URL is the actual production deployment; confirm availability in a signed-out browser before sharing.

## Official command references

- [GitHub repository creation](https://cli.github.com/manual/gh_repo_create)
- [GitHub authentication](https://cli.github.com/manual/gh_auth_status)
- [Vercel production deployment and stdout URL contract](https://vercel.com/docs/cli/deploy)
- [Vercel project linking](https://vercel.com/docs/cli/link)
- [Vercel static project configuration](https://vercel.com/docs/project-configuration/vercel-json)
