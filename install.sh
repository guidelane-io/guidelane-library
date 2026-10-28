#!/bin/sh
# Installs Guidelane Library on Linux, as a systemd service, or on
# macOS, as a launchd daemon:
#
#   curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh
#   curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh -s -- --name "Acme library"
#
# It reads library/latest.json from the downloads address, downloads the
# package for this system, checks its SHA-256 against latest.json, installs
# the binary to /usr/local/bin, makes a system user and the data folder
# /var/lib/guidelane-library, sets the server up there once, and starts it as
# a service that starts at boot. Run again, it replaces the binary and
# restarts the service, and leaves the data folder as it is.
#
#   --name <name>  The server's name when it is set up. "Guidelane library" unless given.
#   --version <x.y.z>  Install that version rather than the latest, checked against its
#                  SHA256SUMS.
#   --uninstall    Stop and remove the service and the binary, and keep the data folder.
#   --purge        With --uninstall, remove the data folder and the system user too.
#   --dry-run      Download and check the package, and say what the installer would
#                  change, without changing anything. It does not need root.
#
# GUIDELANE_DOWNLOADS_URL names another downloads address, such as a mirror.
#
# Everything is inside main, which runs on the last line, so a download that
# stops partway runs nothing.

set -eu

DOWNLOADS=${GUIDELANE_DOWNLOADS_URL:-https://downloads.guidelane.io}
DOWNLOADS=${DOWNLOADS%/}
SERVICE=guidelane-library
BINARY=/usr/local/bin/guidelane-library
DATA=/var/lib/guidelane-library
CONFIG=$DATA/library.toml
DEFAULT_NAME="Guidelane library"
# The service files the README documents.
UNIT=/etc/systemd/system/guidelane-library.service
LABEL=io.guidelane.library
PLIST=/Library/LaunchDaemons/io.guidelane.library.plist
LOG=/var/log/guidelane-library.log

say() {
	printf '%s\n' "$*"
}

fail() {
	printf '%s\n' "$*" >&2
	exit 1
}

usage() {
	say "Usage: install.sh [--name <name>] [--version <x.y.z>] [--dry-run]"
	say "       install.sh --uninstall [--purge] [--dry-run]"
	say ""
	say "Installs Guidelane Library as a service, or upgrades the one installed."
	say "--version installs that version rather than the latest."
	say "--uninstall removes the service and the binary and keeps the data folder."
	say "--purge also removes the data folder and the system user."
	say "--dry-run says what the installer would change, without changing anything."
}

# The words given, quoted where a shell would need it, to show a command.
shown() {
	line=
	for word in "$@"; do
		case $word in
		'' | *[!A-Za-z0-9_./:=@%+-]*)
			word="'$(printf '%s' "$word" | sed "s/'/'\\\\''/g")'"
			;;
		esac
		line="$line${line:+ }$word"
	done
	printf '%s\n' "$line"
}

# Runs a command that changes the system, or in a dry run says it would.
run() {
	if [ "$dry_run" = true ]; then
		say "Would run: $(shown "$@")"
	else
		"$@"
	fi
}

# Writes what it reads to the file $1 with the mode $2, replacing it whole, or
# in a dry run shows it.
write_file() {
	if [ "$dry_run" = true ]; then
		say "Would write $1:"
		sed 's/^/    /'
	else
		cat >"$1.new"
		chmod "$2" "$1.new"
		mv -f "$1.new" "$1"
	fi
}

download() {
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL -o "$2" "$1"
	elif command -v wget >/dev/null 2>&1; then
		wget -q -O "$2" "$1"
	else
		fail "The installer needs curl or wget to download the server."
	fi
}

sha256_of() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$1" | awk '{ print $1 }'
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | awk '{ print $1 }'
	else
		fail "The installer needs sha256sum or shasum to check the download."
	fi
}

# The value of "$2" in the JSON $1, which has no spaces or line breaks: a
# string without its quotes, or a number.
json_value() {
	printf '%s' "$1" | sed -n "s/.*\"$2\":\"\{0,1\}\([^\",}]*\)\"\{0,1\}[,}].*/\1/p"
}

# Sets os, target, user and group for this system, or stops when there is no
# build for it.
detect() {
	os=$(uname -s)
	arch=$(uname -m)
	case $os in
	Linux)
		case $arch in
		x86_64 | amd64) target=x86_64-unknown-linux-musl ;;
		aarch64 | arm64) target=aarch64-unknown-linux-musl ;;
		*) fail "There is no build of the Library for $arch." ;;
		esac
		user=guidelane
		group=guidelane
		;;
	Darwin)
		# One binary for Apple silicon and Intel.
		target=universal-apple-darwin
		user=_guidelane
		group=_guidelane
		;;
	*)
		fail "This installer is for Linux and macOS. On Windows, follow the README's Windows section."
		;;
	esac
	if [ "$os" = Linux ] && [ ! -d /run/systemd/system ]; then
		if [ "$dry_run" = true ]; then
			say "systemd is not running here, so an install would stop at this point."
		else
			fail "The installer needs systemd, which is not running here. The README says how to run the server without it."
		fi
	fi
}

# Sets file and expected for the version $pinned from its SHA256SUMS.
pinned_package() {
	version=$pinned
	file="guidelane-library-$version-$target.tar.gz"
	say "Reading $DOWNLOADS/library/$version/SHA256SUMS."
	download "$DOWNLOADS/library/$version/SHA256SUMS" "$work/SHA256SUMS" ||
		fail "The installer could not download $DOWNLOADS/library/$version/SHA256SUMS. Check that $version is a released version."
	expected=$(awk -v file="$file" '$2 == file || $2 == "*" file { print $1 }' "$work/SHA256SUMS")
	printf '%s\n' "$expected" | grep -Eq '^[0-9a-f]{64}$' ||
		fail "Version $version has no build for $target."
	sums=SHA256SUMS
}

# Downloads latest.json, or with --version that version's SHA256SUMS, and the
# package for $target into $work, checks the package against it, unpacks it,
# and sets version and unpacked.
fetch() {
	if [ -n "$pinned" ]; then
		pinned_package
	else
		latest_package
	fi

	say "Downloading Guidelane Library $version for $target."
	download "$DOWNLOADS/library/$version/$file" "$work/$file" ||
		fail "The installer could not download $DOWNLOADS/library/$version/$file."
	actual=$(sha256_of "$work/$file")
	[ "$actual" = "$expected" ] ||
		fail "The download's SHA-256 is $actual, and $sums says $expected, so nothing was installed."
	say "The download's SHA-256 matches $sums."
	tar -xzf "$work/$file" -C "$work"
	unpacked=$work/guidelane-library-$version-$target/guidelane-library
	[ -f "$unpacked" ] || fail "The package does not hold the server."
}

# Sets version, file and expected from latest.json.
latest_package() {
	say "Reading $DOWNLOADS/library/latest.json."
	download "$DOWNLOADS/library/latest.json" "$work/latest.json" ||
		fail "The installer could not download $DOWNLOADS/library/latest.json."
	latest=$(tr -d ' \t\r\n' <"$work/latest.json")
	version=$(json_value "$latest" version)
	printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' ||
		fail "latest.json does not name a version the installer can read."
	entry=$(printf '%s' "$latest" | sed -n "s/.*\"$target\":\({[^}]*}\).*/\1/p")
	[ -n "$entry" ] || fail "Version $version has no build for $target."
	file=$(json_value "$entry" file)
	expected=$(json_value "$entry" sha256)
	[ "$file" = "guidelane-library-$version-$target.tar.gz" ] ||
		fail "latest.json names the file $file for $target, which is not the package's name."
	printf '%s\n' "$expected" | grep -Eq '^[0-9a-f]{64}$' ||
		fail "latest.json has no SHA-256 for $file."
	sums=latest.json
}

# A system user id from 300 to 499 that no user or group on this Mac has.
free_id() {
	taken=$({
		dscl . -list /Users UniqueID
		dscl . -list /Groups PrimaryGroupID
	} | awk '{ print $2 }')
	id=300
	while [ "$id" -lt 500 ]; do
		if ! printf '%s\n' "$taken" | grep -qx "$id"; then
			printf '%s\n' "$id"
			return
		fi
		id=$((id + 1))
	done
	fail "No system user id from 300 to 499 is free for the $user user."
}

make_user() {
	if [ "$os" = Linux ]; then
		if id -u "$user" >/dev/null 2>&1; then
			return
		fi
		if ! command -v useradd >/dev/null 2>&1; then
			if [ "$dry_run" = true ]; then
				say "useradd is not here to make the $user user, so an install would stop at this point."
				return
			fi
			fail "The installer needs useradd to make the $user user."
		fi
		nologin=$(command -v nologin || printf '%s' /bin/false)
		run useradd --system --user-group --home-dir "$DATA" --no-create-home \
			--shell "$nologin" --comment "Guidelane Library" "$user"
		return
	fi
	if dscl . -read "/Users/$user" >/dev/null 2>&1; then
		return
	fi
	if dscl . -read "/Groups/$group" >/dev/null 2>&1; then
		gid=$(dscl . -read "/Groups/$group" PrimaryGroupID | awk '{ print $2 }')
	else
		gid=$(free_id)
		run dscl . -create "/Groups/$group"
		run dscl . -create "/Groups/$group" PrimaryGroupID "$gid"
		run dscl . -create "/Groups/$group" RealName "Guidelane Library"
		run dscl . -create "/Groups/$group" Password '*'
	fi
	uid=$gid
	if dscl . -search /Users UniqueID "$uid" | grep -q .; then
		uid=$(free_id)
	fi
	run dscl . -create "/Users/$user"
	run dscl . -create "/Users/$user" UniqueID "$uid"
	run dscl . -create "/Users/$user" PrimaryGroupID "$gid"
	run dscl . -create "/Users/$user" RealName "Guidelane Library"
	run dscl . -create "/Users/$user" NFSHomeDirectory /var/empty
	run dscl . -create "/Users/$user" UserShell /usr/bin/false
	run dscl . -create "/Users/$user" Password '*'
	run dscl . -create "/Users/$user" IsHidden 1
}

# Installs the unpacked binary over the one there, if any, once it has run
# here. A running server keeps the old file until it restarts.
install_binary() {
	[ -d /usr/local/bin ] || run install -d -m 0755 /usr/local/bin
	run install -m 0755 "$unpacked" "$BINARY.new"
	if [ "$dry_run" = false ] && ! "$BINARY.new" --help >/dev/null 2>&1; then
		rm -f "$BINARY.new"
		fail "The downloaded server does not run on this system, so nothing was installed."
	fi
	run mv -f "$BINARY.new" "$BINARY"
	if [ "$os" = Linux ] && command -v restorecon >/dev/null 2>&1; then
		run restorecon "$BINARY"
	fi
}

# Makes the data folder and sets the server up in it, unless it is set up
# already, in which case nothing in the folder is touched.
set_up() {
	if [ -f "$CONFIG" ]; then
		say "The server is set up already in $DATA, so its data folder is left as it is."
		if [ -n "$name_given" ]; then
			say "--name changes nothing now. The admin page can change the server's name."
		fi
		return
	fi
	if [ ! -d "$DATA" ]; then
		run mkdir -p "$DATA"
		run chmod 0700 "$DATA"
	fi
	if [ "$dry_run" = true ]; then
		run "$BINARY" --config "$CONFIG" init --data . --name "$name"
	else
		made=$("$BINARY" --config "$CONFIG" init --data . --name "$name" 2>&1) || {
			printf '%s\n' "$made" >&2
			fail "The server could not be set up in $DATA."
		}
		# init's last line says to start the server, which the installer does.
		printf '%s\n' "$made" | grep -v '^Start it with' || true
	fi
	run chown -R "$user:$group" "$DATA"
}

start_linux() {
	write_file "$UNIT" 0644 <<EOF
[Unit]
Description=Guidelane Library
After=network-online.target
Wants=network-online.target

[Service]
User=$user
Group=$group
ExecStart=$BINARY --config $CONFIG run
Restart=on-failure
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
ReadWritePaths=$DATA

[Install]
WantedBy=multi-user.target
EOF
	since=$(date '+%Y-%m-%d %H:%M:%S')
	run systemctl daemon-reload
	run systemctl enable --quiet "$SERVICE"
	run systemctl restart "$SERVICE"
}

start_macos() {
	# The log holds the setup code, so it is the server's user's alone.
	if [ ! -f "$LOG" ]; then
		run touch "$LOG"
		run chown "$user:$group" "$LOG"
		run chmod 0600 "$LOG"
	fi
	write_file "$PLIST" 0644 <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>UserName</key>
    <string>$user</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BINARY</string>
        <string>--config</string>
        <string>$CONFIG</string>
        <string>run</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$LOG</string>
</dict>
</plist>
EOF
	unload_macos
	logged=0
	if [ -f "$LOG" ]; then
		logged=$(wc -c <"$LOG" | tr -d ' ')
	fi
	run launchctl enable "system/$LABEL"
	run launchctl bootstrap system "$PLIST"
}

# Stops the launchd daemon if it is loaded, and waits until it has gone.
unload_macos() {
	launchctl print "system/$LABEL" >/dev/null 2>&1 || return 0
	run launchctl bootout "system/$LABEL" || true
	[ "$dry_run" = false ] || return 0
	waited=0
	while launchctl print "system/$LABEL" >/dev/null 2>&1; do
		[ "$waited" -lt 20 ] || fail "The service did not stop within 20 seconds."
		sleep 1
		waited=$((waited + 1))
	done
}

# What the server has written since the installer started it.
server_lines() {
	if [ "$os" = Linux ]; then
		journalctl -u "$SERVICE" --since "$since" -o cat --no-pager 2>/dev/null || true
	elif [ -f "$LOG" ]; then
		tail -c "+$((logged + 1))" "$LOG"
	fi
}

# Waits for the server to say where its admin page is, then says it, and how
# to read the setup code when the admin page has no password yet.
report() {
	if [ "$os" = Linux ]; then
		read_log="sudo journalctl -u $SERVICE"
	else
		read_log="sudo cat $LOG"
	fi
	waited=0
	lines=
	while [ "$waited" -lt 30 ]; do
		lines=$(server_lines)
		case $lines in
		*"The admin page is at"*) break ;;
		esac
		sleep 1
		waited=$((waited + 1))
	done
	pages=$(printf '%s\n' "$lines" | sed -n 's/^The admin page is at \(.*\)\.$/\1/p')
	if [ -z "$pages" ]; then
		fail "The server has not said it is running. To see what it says, run: $read_log"
	fi
	say ""
	say "Guidelane Library $version is running and starts at boot."
	for page in $pages; do
		say "Its admin page is at $page"
	done
	case $lines in
	*"setup code"*)
		say "The admin page asks for a setup code the first time. To read it, run: $read_log"
		;;
	esac
}

install_server() {
	detect
	fetch
	install_binary
	make_user
	set_up
	if [ "$os" = Linux ]; then
		start_linux
	else
		start_macos
	fi
	if [ "$dry_run" = true ]; then
		say "This was a dry run, so nothing was changed."
	else
		report
	fi
}

uninstall_server() {
	detect
	if [ ! -f "$BINARY" ] && [ ! -f "$UNIT" ] && [ ! -f "$PLIST" ] && [ "$purge" = false ]; then
		say "Guidelane Library is not installed here."
		return
	fi
	if [ "$os" = Linux ]; then
		if [ -f "$UNIT" ]; then
			run systemctl disable --now --quiet "$SERVICE"
			run rm -f "$UNIT"
			run systemctl daemon-reload
		fi
	else
		unload_macos
		run rm -f "$PLIST"
	fi
	run rm -f "$BINARY"
	if [ "$purge" = true ]; then
		run rm -rf "$DATA"
		if [ "$os" = Linux ]; then
			if id -u "$user" >/dev/null 2>&1; then
				run userdel "$user"
			fi
			if command -v getent >/dev/null 2>&1 && getent group "$group" >/dev/null 2>&1; then
				run groupdel "$group"
			fi
		else
			run rm -f "$LOG"
			if dscl . -read "/Users/$user" >/dev/null 2>&1; then
				run dscl . -delete "/Users/$user"
			fi
			if dscl . -read "/Groups/$group" >/dev/null 2>&1; then
				run dscl . -delete "/Groups/$group"
			fi
		fi
	fi
	if [ "$dry_run" = true ]; then
		say "This was a dry run, so nothing was changed."
	elif [ "$purge" = true ]; then
		say "The service, the binary, the data folder and the $user user were removed."
	else
		say "The service and the binary were removed. The data folder is still at $DATA."
		say "To remove it and the $user user too, run the installer with --uninstall --purge."
	fi
}

main() {
	name=$DEFAULT_NAME
	name_given=
	pinned=
	uninstall=false
	purge=false
	dry_run=false
	while [ $# -gt 0 ]; do
		case $1 in
		--name)
			[ $# -ge 2 ] || fail "--name needs a value."
			name=$2
			name_given=yes
			shift 2
			;;
		--name=*)
			name=${1#--name=}
			name_given=yes
			shift
			;;
		--version)
			[ $# -ge 2 ] || fail "--version needs a value."
			pinned=$2
			shift 2
			;;
		--version=*)
			pinned=${1#--version=}
			shift
			;;
		--uninstall)
			uninstall=true
			shift
			;;
		--purge)
			purge=true
			shift
			;;
		--dry-run)
			dry_run=true
			shift
			;;
		-h | --help)
			usage
			exit 0
			;;
		*)
			fail "$1 is not an option of the installer. Run it with --help to see them."
			;;
		esac
	done
	if [ "$purge" = true ] && [ "$uninstall" = false ]; then
		fail "--purge goes with --uninstall."
	fi
	if [ -n "$pinned" ]; then
		[ "$uninstall" = false ] || fail "--version goes with an install, not --uninstall."
		pinned=${pinned#v}
		printf '%s\n' "$pinned" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' ||
			fail "--version takes a version such as 0.1.0."
	fi
	if [ "$dry_run" = false ] && [ "$(id -u)" -ne 0 ]; then
		fail "The installer must run as root, for example with sudo."
	fi

	work=$(mktemp -d)
	trap 'rm -rf "$work"' EXIT
	trap 'exit 1' INT TERM

	if [ "$uninstall" = true ]; then
		uninstall_server
	else
		install_server
	fi
}

main "$@"
