# Install on Windows

The server runs as a Windows service. Download and extract it in PowerShell:

```powershell
$latest = Invoke-RestMethod https://downloads.guidelane.io/library/latest.json
Invoke-WebRequest $latest.targets.'x86_64-pc-windows-msvc'.url -OutFile guidelane-library.zip
(Get-FileHash guidelane-library.zip -Algorithm SHA256).Hash.ToLower() -eq $latest.targets.'x86_64-pc-windows-msvc'.sha256
Expand-Archive guidelane-library.zip
```

The third line prints `True` if the download matches its published SHA-256 checksum. To install
a specific version, download `guidelane-library-<version>-x86_64-pc-windows-msvc.zip` and
`SHA256SUMS` from `https://downloads.guidelane.io/library/<version>/` instead.

Then open PowerShell as administrator, go to the folder that contains `guidelane-library.exe`,
and run:

```powershell
.\guidelane-library.exe service install
```

This command:

- Copies the server to `C:\Program Files\Guidelane\Library`.
- Sets up the server in `C:\ProgramData\Guidelane\Library`, which only the service,
  administrators and the SYSTEM account can read.
- Adds a Windows Firewall rule for the server.
- Starts the "Guidelane Library" service, which starts automatically with Windows.

The admin page's address and the setup code are in the service's log:

```powershell
Get-Content C:\ProgramData\Guidelane\Library\library.log
```

Then continue with [First start](first-start.md).

## Run the server's commands

```powershell
& "C:\Program Files\Guidelane\Library\guidelane-library.exe" --config C:\ProgramData\Guidelane\Library\library.toml invite
```

## Upgrade

Download the new version and run `service install` from it. This replaces the program, restarts
the service, and doesn't change the data.

## Remove

```powershell
& "C:\Program Files\Guidelane\Library\guidelane-library.exe" service uninstall
```

This stops and removes the service, its firewall rule and the program, and keeps
`C:\ProgramData\Guidelane\Library`. A program can't delete itself while it's running, so the
program and its folder are deleted a moment after the command finishes. If you no longer need
the guides, also delete `C:\ProgramData\Guidelane\Library`.
