# Rhino Journal Extractor

A small, transparent PowerShell utility for **Elite Dangerous Rhino planetary-mining surveys**.

`Rhino_Journal_Extractor.ps1` reads one Elite Dangerous journal chosen by the commander and writes a reduced `Rhino_Survey_Extract_*.jsonl` containing the journal events used by the Rhino Survey & Mapping workflow.

The goal is simple: **reduce what needs to be shared for a private AI site report while preserving enough provenance to audit the result.**

## Project

Maintained by **CMDR Dunn Actual**  
Reddit / Frontier Forums: **erichards2222**  
YouTube: **CMDRRhinoerichards2222**

This extractor is a companion to the **Rhino Planetary Survey and Mapping Field Manual** and the active Rhino Planetary Mining Public Field Guide project.

### Companion resources

- [Rhino Planetary Survey and Mapping Field Manual v0.4.2](https://docs.google.com/document/d/1ffHeh2wSPiWH_osVZUXwIuF6P9LGAqkVT91v85QbzUw/edit)
- [SMART Deposit Command Picker](https://docs.google.com/spreadsheets/d/1vviSfBO5fS0kkp9F8d17fJAn7wrYfpC7d9z1s_tWnX0/edit)
- [AI Site Report Prompt v0.3](https://drive.google.com/file/d/1jLHM5_kzlaXOeDWlRjREIwR1skO38Y5W/view)
- [Rhino Planetary Survey and Mapping Drive folder](https://drive.google.com/drive/folders/1gLF2IFqG8FP6FQeOw6YhIs32tqKuAIAg)

The Google Drive package contains the user-facing manual and companion tools; this repository is the canonical auditable source for the extractor.

## What the extractor does

The script is deliberately short enough to inspect directly.

It:

1. Looks for the 10 most recent `Journal.*.log` files in the folder where it is run when no journal path is supplied.
2. Lets the commander choose one journal.
3. Reads that journal locally.
4. Keeps only this fixed event whitelist:

```text
Fileheader
Location
FSDJump
ApproachBody
SupercruiseExit
SAAScanComplete
SAASignalsFound
Scan
LaunchSRV
DockSRV
Touchdown
Liftoff
Screenshot
SendText
Cargo
MiningRefined
MaterialCollected
```

5. Keeps **all outgoing `SendText` events** so structured survey tags, corrections, duplicate notes, terrain notes and other commander annotations are not silently lost.
6. For `Screenshot` events, keeps only the screenshot **basename** rather than the local filesystem path.
7. Adds:
   - `_source_file` — the original journal filename;
   - `_source_line` — the original journal line number.
8. Writes a new file named:

```text
Rhino_Survey_Extract_<journal-tag>.jsonl
```

9. Makes **no network calls**.

## What it does NOT do

The extractor does **not**:

- upload anything;
- contact an AI service;
- contact SMART;
- install software or dependencies;
- modify the selected Elite Dangerous journal;
- permanently change Windows execution policy;
- anonymize the mining site.

The original journal remains the raw evidence.

## Privacy: data-minimized is not anonymous

The reduced JSONL may still contain private site information such as:

- system/body identity;
- body properties;
- coordinates;
- PML-related context;
- relative survey geometry;
- commander annotations.

Inspect the generated JSONL before sharing it.

If you are protecting a high-value mining site, treat the extract and any report/map derived from it as **private unless you deliberately authorize publication**.

## Usage

### 1. Put the script beside your Elite journals

Open the folder where Elite Dangerous is saving its journal files.

A common location is:

```text
%USERPROFILE%\Saved Games\Frontier Developments\Elite Dangerous\
```

Your installation may use a different location.

Place this file in that folder:

```text
Rhino_Journal_Extractor.ps1
```

Confirm that the script and one or more `Journal.*.log` files are visible together.

### 2. Open PowerShell from that folder

While viewing the journal folder in File Explorer, click the address bar, type:

```text
powershell
```

and press Enter.

### 3. Run the extractor

Copy/paste:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Rhino_Journal_Extractor.ps1
```

The bypass applies only to that launched PowerShell process for this run. It is not a permanent machine-wide execution-policy change.

### 4. Choose the journal

The script lists the 10 most recently modified `Journal.*.log` files. Enter the number corresponding to the survey journal.

### 5. Inspect the output

The resulting file is written into the current folder:

```text
Rhino_Survey_Extract_<journal-tag>.jsonl
```

You can open it in Notepad or another text editor before sharing it.

For the archival-report workflow, provide the reduced JSONL to your chosen AI together with **AI Site Report Prompt v0.3**. The full journal is not required for the normal reduced-data workflow.

## Why the command uses `-ExecutionPolicy Bypass`

Windows may block unsigned PowerShell scripts depending on the local execution-policy configuration.

The manual therefore uses:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Rhino_Journal_Extractor.ps1
```

This starts a child PowerShell process with the bypass applied to that invocation. It does **not** ask the commander to permanently relax the machine's execution policy.

The source is intentionally published here so commanders can inspect exactly what they are choosing to run.

## Audit notes

The script uses ordinary local PowerShell operations including:

- `Get-ChildItem`
- `Get-Content`
- `ConvertFrom-Json`
- `ConvertTo-Json`
- `Add-Content`
- `Resolve-Path`

There are no network/download cmdlets in the released script.

For maximum confidence, review [`Rhino_Journal_Extractor.ps1`](./Rhino_Journal_Extractor.ps1) directly before running it.

## Versioning

The executable filename intentionally remains:

```text
Rhino_Journal_Extractor.ps1
```

Versioning belongs in Git history, tags and releases rather than in the filename because the public field manual uses that exact filename in copy/paste commands.

Initial public repository release: **v0.3.1**.

## Relationship to SMART

This utility does not replace SMART.

The Survey & Mapping workflow supports either or both:

- **SMART** for deterministic local interactive mapping/analytics; and
- **Rhino Journal Extractor → AI Site Report Prompt** for a reduced-data, durable private site report and revisit/research synthesis.

Both can use the same preserved raw journal.

## License

Released under the [MIT License](./LICENSE).

## Disclaimer

This is an independent community research utility for Elite Dangerous. It is not an official Frontier Developments tool, and no Frontier endorsement is implied.
