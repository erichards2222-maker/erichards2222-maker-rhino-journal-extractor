# Changelog

## v0.3.1 — Initial public repository release

- Selects one of the 10 most recent Elite Dangerous `Journal.*.log` files when no journal path is supplied.
- Keeps the fixed Rhino-relevant event whitelist used by the Survey & Mapping workflow.
- Preserves all outgoing `SendText` annotations.
- Reduces Screenshot `Filename` to the basename only.
- Adds `_source_file` and `_source_line` provenance to retained events.
- Writes a new `Rhino_Survey_Extract_*.jsonl`.
- Makes no network calls.
- Keeps the executable filename unversioned as `Rhino_Journal_Extractor.ps1` for compatibility with the public manual.
