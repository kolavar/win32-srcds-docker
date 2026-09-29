#!/bin/bash
cd "$(dirname "$0")"

exec wine srcds.exe -game csgo -console -ip 0.0.0.0 -port 27015 +sv_lan 1 +game_type 1 +game_mode 0 +map ar_shoots
