#!/usr/bin/env bash

set -axe

CONFIG_FILE="/opt/hlds/startup.cfg"

if [ -r "${CONFIG_FILE}" ]; then
    # TODO: make config save/restore mechanism more solid
    set +e
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
    set -e
fi

EXTRA_OPTIONS=( "$@" )

EXECUTABLE="/opt/hlds/hlds_run"
GAME="${GAME:-cstrike}"
MAXPLAYERS="${MAXPLAYERS:-32}"
START_MAP="${START_MAP:-de_dust2}"
SERVER_NAME=$(sed -E "s/(^(\"|')+|(\"|')+$)//g" <<< ${SERVER_NAME:-Counter-Strike 1.6 Server})
FRIENDLY_FIRE="${FRIENDLY_FIRE:-0}"
AUTO_TEAM_BALANCE="${AUTO_TEAM_BALANCE:-0}"
FREEZE_TIME="${FREEZE_TIME:-3}"
AUTO_TEAM_BALANCE="${AUTO_TEAM_BALANCE:-0}"
ROUND_TIME="${ROUND_TIME:-1.75}"

OPTIONS=( "-game" "${GAME}" "+maxplayers" "${MAXPLAYERS}" "+map" "${START_MAP}" "-mp_friendlyfire" "${FRIENDLY_FIRE}" "-mp_autoteambalance" "${AUTO_TEAM_BALANCE}" "-mp_freezetime" "${FREEZE_TIME}" "-mp_roundtime" "\"${ROUND_TIME}\"" "+hostname" "\"${SERVER_NAME}\"" )

if [ -n "${LAN+set}" ]; then
    OPTIONS+=(-insecure +sv_lan 1 )
fi

if [ -z "${RESTART_ON_FAIL}" ]; then
    OPTIONS+=(-norestart )
fi

if [ -n "${ADMIN_STEAM}" ]; then
    echo "\"STEAM_${ADMIN_STEAM}\" \"\"  \"abcdefghijklmnopqrstu\" \"ce\"" >> "/opt/hlds/cstrike/addons/amxmodx/configs/users.ini"
fi

set > "${CONFIG_FILE}"

exec "${EXECUTABLE}" "${OPTIONS[@]}" "${EXTRA_OPTIONS[@]}"
