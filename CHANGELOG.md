# Changelog

## Unreleased

- Windows: the installer turns off the PowerShell progress bar while it downloads. Windows PowerShell 5.1 redraws that bar for every chunk it receives, which made downloading the ~85 MB `solari.exe` many times slower than the network allowed. The previous setting is put back when the installer finishes.
- Windows: the installer now puts `solari.exe` in `%USERPROFILE%\.solari\bin` instead of `%LOCALAPPDATA%\Programs\solari`. Apps packaged as MSIX (for example the Codex desktop app) redirect writes under AppData into a private folder, so an install started from inside them left a PATH entry pointing at a folder no other program could see. Re-running the installer removes the old copy and takes the old folder off the user PATH. `SOLARI_INSTALL_DIR` still overrides the location.
- Initial public distribution: `solari` CLI binaries, the SOLARI connector, and the Claude Code plugin.
