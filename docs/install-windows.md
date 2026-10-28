# Install on Windows

The server installs itself as a Windows service. Download it and extract it in PowerShell:

```powershell
$latest = Invoke-RestMethod https://downloads.guidelane.io/library/latest.json
Invoke-WebRequest $latest.targets.'x86_64-pc-windows-msvc'.url -OutFile guidelane-library.zip
(Get-FileHash guidelane-library.zip -Algorithm SHA256).Hash.ToLower() -eq $latest.targets.'x86_64-pc-windows-msvc'.sha256
Expand-Archive guidelane-library.zip
```

The third line prints `True` when the download matches its published SHA-256. For a given
version, download `guidelane-library-<version>-x86_64-pc-windows-msvc.zip` and `SHA256SUMS`
from `https://downloads.guidelane.io/library/<version>/` instead.

Then open PowerShell as administrator, go to the folder that holds `guidelane-library.exe`, and
run:

```powershell
.\guidelane-library.exe service install
```

This command does the following:

- It copies the server to `C:\Program Files\Guidelane\Library`.
- It sets the server up in `C:\ProgramData\Guidelane\Library`, which only the service,
  administrators and the system can read.
- It adds a Windows Firewall rule for the server.
- It starts the service "Guidelane Library", which starts with Windows.

The address of the admin page and its setup code are in the service's log:

```powershell
Get-Content C:\ProgramData\Guidelane\Library\library.log
```

Then go on with [First start](first-start.md).

## Run the server's commands

```powershell
& "C:\Program Files\Guidelane\Library\guidelane-library.exe" --config C:\ProgramData\Guidelane\Library\library.toml invite
```

## Upgrade

Download the new version and run `service install` with the new program. It replaces the
program and restarts the service, and leaves the data as it is.

## Remove

```powershell
& "C:\Program Files\Guidelane\Library\guidelane-library.exe" service uninstall
```

This stops and removes the service, its firewall rule and the program, and keeps
`C:\ProgramData\Guidelane\Library`. Delete that folder too if you no longer need the guides.
