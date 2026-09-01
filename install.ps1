#Requires -Version 5.1
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$Repo = "brandazine/solari"
$Version = if ($env:SOLARI_VERSION) { $env:SOLARI_VERSION } else { "latest" }
$InstallDir = if ($env:SOLARI_INSTALL_DIR) { $env:SOLARI_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "Programs\solari" }

function Write-Log([string]$Message) { Write-Host "solari-install: $Message" }
function Fail([string]$Message) { throw "solari-install: $Message" }

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

	$markerDir = if ($env:SOLARI_HOME) { $env:SOLARI_HOME } else { Join-Path $env:USERPROFILE ".solari" }
	try {
		New-Item -ItemType Directory -Path $markerDir -Force | Out-Null
		$marker = [ordered]@{
			channel     = "script"
			installedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
			path        = (Join-Path $InstallDir "solari.exe")
		}
		$marker | ConvertTo-Json -Compress | Set-Content -Path (Join-Path $markerDir "install.json") -Encoding utf8
	} catch {
		Write-Log "note: could not record the install channel in $markerDir"
	}

	$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
	if (-not $userPath) { $userPath = "" }
	if (($userPath -split ";") -notcontains $InstallDir) {
		[Environment]::SetEnvironmentVariable("Path", ($userPath.TrimEnd(";") + ";" + $InstallDir), "User")
		Write-Log "added $InstallDir to your user PATH — open a new terminal to pick it up"
	}
	Write-Log "next: solari auth login"
} finally {
	Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
}
