# win32-srcds-docker

Build and run a containerized classic Source dedicated server.
On `linux/amd64` this uses Wine; on `linux/arm64` it uses [Hangover](https://github.com/AndreRH/hangover).
Both provide a virtual desktop (Xvfb + Fluxbox).
Optional noVNC access for the dedicated server console.

This project was originally developed *and tested* on an Ubuntu 26.04 LTS
x86_64 VM running a classic CS:GO dedicated server with manifests from
August 17, 2012. It also builds for `linux/arm64`, tested on a Raspberry Pi 5
(4KB page size via `kernel8.img`).

Obvious warning: do *not* expose this container to the internet as-is.
An outdated Source dedicated server is highly exploitable.

Steam content is fetched at `docker build` time with [DepotDownloader](https://github.com/SteamRE/DepotDownloader).

## Prerequisites

- Docker on Linux (`linux/amd64` or `linux/arm64`)
- Enough disk space for depot downloads
- If you change anything, lots of free time to diagnose why `srcds.exe`
  is exiting with an error

## Quick start

```bash
# To change the parameters for `srcds.exe`, edit `srcds_run.sh`
# To modify the parameters for `docker run`, e.g. to switch from
#   `--net=host` to `-p ...`, edit `Makefile`.
make run
```

To access the server console, open http://localhost:8080/vnc.html.

![Screenshot](https://raw.githubusercontent.com/kolavar/win32-srcds-docker/master/screenshot.png)

## Networking

Ports used:

| Port | Protocol | Service |
| --- | --- | --- |
| `27015` | UDP + TCP | Source dedicated server (game + rcon) |
| `8080` | TCP | noVNC (browser view of the Wine desktop) |

## How the Source dedicated server starts

1. Docker `ENTRYPOINT` is `/app/entrypoint.sh` which runs Supervisor.
2. Supervisor reads `/app/supervisord.conf` and `conf.d/*`.
3. Supervisor starts services including `srcds.exe` by running
     `/opt/steam/srcds_run.sh`.
4. Wine (amd64) or Hangover's Wine (arm64) runs `srcds.exe <args>`.
5. Supervisor reruns `/opt/steam/srcds_run.sh` if the server exits.

## Notes and limitations

Any changes to which packages are installed may negatively impact the
functionality of the server.

- **amd64:** Wine + 32-bit Source binaries need the i386 libraries
  installed in the second `RUN` (`lib32gcc-s1`, `libtinfo6:i386`, etc.)
  as well as the recommended packages installed alongside Xvfb.
- **arm64:** Hangover is installed from the upstream `.deb` tarball, then
  `armhf` libraries (`libgcc-s1:armhf`, `libtinfo6:armhf`, etc.) are
  added so the 32-bit ARM Windows translation stack can run `srcds.exe`.
