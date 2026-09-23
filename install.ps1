#Requires -Version 5.1
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$Repo = "brandazine/solari"
$Version = if ($env:SOLARI_VERSION) { $env:SOLARI_VERSION } else { "latest" }
$SolariHome = if ($env:SOLARI_HOME) { $env:SOLARI_HOME } else { Join-Path $env:USERPROFILE ".solari" }
$InstallDir = if ($env:SOLARI_INSTALL_DIR) { $env:SOLARI_INSTALL_DIR } else { Join-Path $SolariHome "bin" }
$LegacyInstallDir = if ($env:LOCALAPPDATA) { Join-Path (Join-Path $env:LOCALAPPDATA "Programs") "solari" } else { $null }

function Write-Log([string]$Message) { Write-Host "solari-install: $Message" }
function Fail([string]$Message) { throw "solari-install: $Message" }

function Get-DirKey([string]$Path) {
	if (-not $Path) { return "" }
	return $Path.Trim().TrimEnd([char[]]@('\', '/')).ToLowerInvariant()
}

function Test-PathEntry([string]$PathValue, [string]$Dir) {
	$key = Get-DirKey $Dir
	foreach ($entry in ($PathValue -split ";")) {
		if ($entry -and ((Get-DirKey $entry) -eq $key)) { return $true }
	}
	return $false
}

function Remove-PathEntry([string]$PathValue, [string]$Dir) {
	if (-not $PathValue) { return $PathValue }
	$key = Get-DirKey $Dir
	return (($PathValue -split ";") | Where-Object { (-not $_) -or ((Get-DirKey $_) -ne $key) }) -join ";"
}

function Remove-LegacyInstall {
	if (-not $LegacyInstallDir) { return }
	if ((Get-DirKey $LegacyInstallDir) -eq (Get-DirKey $InstallDir)) { return }
	$legacyExe = Join-Path $LegacyInstallDir "solari.exe"
	if (Test-Path -LiteralPath $legacyExe) {
		try {
			Remove-Item -LiteralPath $legacyExe -Force
			Write-Log "removed the old copy at $legacyExe"
		} catch {
			Write-Log "note: could not remove the old copy at $legacyExe - close programs that use it, then delete it"
		}
	}
	if ((Test-Path -LiteralPath $LegacyInstallDir) -and -not (Get-ChildItem -LiteralPath $LegacyInstallDir -Force | Select-Object -First 1)) {
		Remove-Item -LiteralPath $LegacyInstallDir -Force -ErrorAction SilentlyContinue
	}
	$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
	if ($userPath -and (Test-PathEntry $userPath $LegacyInstallDir)) {
		[Environment]::SetEnvironmentVariable("Path", (Remove-PathEntry $userPath $LegacyInstallDir), "User")
		Write-Log "removed the old folder $LegacyInstallDir from your user PATH"
	}
	if ($env:Path -and (Test-PathEntry $env:Path $LegacyInstallDir)) {
		$env:Path = Remove-PathEntry $env:Path $LegacyInstallDir
	}
}

$arch = "x64"
if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64" -or $env:PROCESSOR_ARCHITEW6432 -eq "ARM64") { $arch = "arm64" }
$asset = "solari-windows-$arch.exe"

if ($Version -eq "latest") {
	$baseUrl = "https://github.com/$Repo/releases/latest/download"
} else {
	$tag = "v" + $Version.TrimStart("v")
	$baseUrl = "https://github.com/$Repo/releases/download/$tag"
}

$tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("solari-install-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
try {
	Write-Log "downloading $asset ($Version)"
	Invoke-WebRequest -Uri "$baseUrl/$asset" -OutFile (Join-Path $tmpDir $asset) -UseBasicParsing
	Invoke-WebRequest -Uri "$baseUrl/SHA256SUMS" -OutFile (Join-Path $tmpDir "SHA256SUMS") -UseBasicParsing

	$pattern = "\s" + [regex]::Escape($asset) + "$"
	$sumsLine = Get-Content (Join-Path $tmpDir "SHA256SUMS") | Where-Object { $_ -match $pattern } | Select-Object -First 1
	if (-not $sumsLine) { Fail "no checksum entry for $asset in SHA256SUMS" }
	$expected = ($sumsLine -split "\s+")[0].ToLowerInvariant()
	$actual = (Get-FileHash -Algorithm SHA256 -Path (Join-Path $tmpDir $asset)).Hash.ToLowerInvariant()
	if ($actual -ne $expected) { Fail "checksum mismatch for ${asset}: expected $expected, got $actual" }

	New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
	Move-Item -Force (Join-Path $tmpDir $asset) (Join-Path $InstallDir "solari.exe")
	Write-Log "installed $(Join-Path $InstallDir 'solari.exe')"

	try {
		Remove-LegacyInstall
	} catch {
		Write-Log "note: could not clean up the old install at $LegacyInstallDir - $($_.Exception.Message)"
	}

	try {
		New-Item -ItemType Directory -Path $SolariHome -Force | Out-Null
		$marker = [ordered]@{
			channel     = "script"
			installedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
			path        = (Join-Path $InstallDir "solari.exe")
		}
		$marker | ConvertTo-Json -Compress | Set-Content -Path (Join-Path $SolariHome "install.json") -Encoding utf8
	} catch {
		Write-Log "note: could not record the install channel in $SolariHome"
	}

	try {
		$previousErrorAction = $ErrorActionPreference
		$ErrorActionPreference = "Continue"
		$initOutput = & (Join-Path $InstallDir "solari.exe") init --detected 2>&1
		$ErrorActionPreference = $previousErrorAction
		foreach ($line in $initOutput) {
			$text = "$line".Trim()
			if ($text) { Write-Log $text }
		}
	} catch {
		Write-Log "note: could not register agents automatically - run: solari init"
	}

	if (-not (Test-PathEntry $env:Path $InstallDir)) {
		$env:Path = "$InstallDir;$env:Path"
	}
	$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
	if (-not $userPath) { $userPath = "" }
	if (-not (Test-PathEntry $userPath $InstallDir)) {
		[Environment]::SetEnvironmentVariable("Path", ($userPath.TrimEnd(";") + ";" + $InstallDir).TrimStart(";"), "User")
		Write-Log "added $InstallDir to your user PATH — this session can use solari now; other shells need to be reopened"
	}
	Write-Log "next: solari auth login"
} finally {
	Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
}
