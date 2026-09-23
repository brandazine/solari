# Changelog

## Unreleased

- Windows: the installer now puts `solari.exe` in `%USERPROFILE%\.solari\bin` instead of `%LOCALAPPDATA%\Programs\solari`. Apps packaged as MSIX (for example the Codex desktop app) redirect writes under AppData into a private folder, so an install started from inside them left a PATH entry pointing at a folder no other program could see. Re-running the installer removes the old copy and takes the old folder off the user PATH. `SOLARI_INSTALL_DIR` still overrides the location.
- Initial public distribution: `solari` CLI binaries, the SOLARI connector, and the Claude Code plugin.
