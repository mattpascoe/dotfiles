#!/bin/bash
# Start / restart Kanata on macOS.
#
# Usage:
#   start-kanata.sh           # start if not already running (quiet, detached)
#   start-kanata.sh start     # same as above
#   start-kanata.sh restart   # kill + start detached (re-grabs USB keyboards)
#   start-kanata.sh debug     # stop if running, then run kanata in the foreground
#                             # (full logs; Ctrl-C to stop)
#   start-kanata.sh stop      # stop kanata only
#   start-kanata.sh status    # show process state
#
# After plugging in a USB keyboard while the laptop was already on, run:
#   start-kanata.sh restart
# Live reload (lrld / both-shifts) does not re-scan devices.

set -euo pipefail

KANATA_CFG="${KANATA_CFG:-$HOME/.config/kanata/kanata.kbd}"
KARABINER_DAEMON="/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
CMD="${1:-start}"

function ensure_sudo() {
  sudo -v
}

function karabiner_running() {
  pgrep -x "Karabiner-VirtualHIDDevice-Daemon" >/dev/null 2>&1
}

function kanata_running() {
  pgrep -x "kanata" >/dev/null 2>&1
}

function ensure_karabiner() {
  if karabiner_running; then
    echo "Karabiner VirtualHID daemon is running"
    return
  fi
  echo "Starting Karabiner VirtualHID daemon"
  sudo sh -c 'nohup "$1" >/dev/null 2>&1 &' _ "$KARABINER_DAEMON"
  # Give the driver a moment before kanata grabs devices
  sleep 1
}

function stop_kanata() {
  if ! kanata_running; then
    echo "Kanata is not running"
    return
  fi
  echo "Stopping Kanata"
  # Prefer a clean kill; escalate if needed
  sudo pkill -x kanata 2>/dev/null || true
  # Wait briefly for exit
  local _
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if ! kanata_running; then
      echo "Kanata stopped"
      return
    fi
    sleep 0.2
  done
  echo "Kanata still running; sending SIGKILL"
  sudo pkill -9 -x kanata 2>/dev/null || true
}

function require_cfg() {
  if [[ ! -f "$KANATA_CFG" ]]; then
    echo "Config not found: $KANATA_CFG" >&2
    exit 1
  fi
}

function start_kanata() {
  if kanata_running; then
    echo "Kanata is already running (pid $(pgrep -x kanata | tr '\n' ' '))"
    echo "Use: $0 restart   # after plugging in a USB keyboard"
    echo "Use: $0 debug     # foreground with full logs"
    return
  fi
  require_cfg
  echo "Starting Kanata with $KANATA_CFG"
  # Quiet + detached: -q alone is not enough if stdout still points at this TTY.
  # Run under nohup with stdio discarded so poll/grab logs never hit the shell.
  sudo sh -c 'nohup kanata -q --no-wait --nodelay -c "$1" >/dev/null 2>&1 &' _ "$KANATA_CFG"
  sleep 0.3
  if kanata_running; then
    echo "Kanata started (pid $(pgrep -x kanata | tr '\n' ' '))"
  else
    echo "Kanata failed to stay running; check permissions / config" >&2
    exit 1
  fi
}

function debug_kanata() {
  require_cfg
  if kanata_running; then
    echo "Stopping existing Kanata so debug can take the devices"
    stop_kanata
    sleep 0.3
  fi
  echo "Starting Kanata in foreground (full logs). Ctrl-C to stop."
  echo "Config: $KANATA_CFG"
  # No -q, no redirect, no background — opposite of the normal start path.
  # exec so this script's PID is replaced and signals go straight to kanata.
  exec sudo kanata --no-wait --nodelay -c "$KANATA_CFG"
}

function show_status() {
  if karabiner_running; then
    echo "Karabiner: running (pid $(pgrep -x Karabiner-VirtualHIDDevice-Daemon | tr '\n' ' '))"
  else
    echo "Karabiner: not running"
  fi
  if kanata_running; then
    echo "Kanata:    running (pid $(pgrep -x kanata | tr '\n' ' '))"
  else
    echo "Kanata:    not running"
  fi
  echo "Config:    $KANATA_CFG"
}

case "$CMD" in
  start)
    ensure_sudo
    ensure_karabiner
    start_kanata
    ;;
  restart)
    ensure_sudo
    ensure_karabiner
    stop_kanata
    sleep 0.3
    start_kanata
    ;;
  debug)
    ensure_sudo
    ensure_karabiner
    debug_kanata
    ;;
  stop)
    ensure_sudo
    stop_kanata
    ;;
  status)
    show_status
    ;;
  -h|--help|help)
    sed -n '2,16p' "$0"
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Usage: $0 [start|restart|debug|stop|status]" >&2
    exit 1
    ;;
esac
