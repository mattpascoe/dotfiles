#!/usr/bin/env bash
# Report helpers. Sourced by dot.sh only when running report.
# shellcheck disable=SC2154

function trim_line() {
  local VALUE="$1"
  VALUE="${VALUE//$'\r'/}"
  VALUE="${VALUE#"${VALUE%%[![:space:]]*}"}"
  VALUE="${VALUE%"${VALUE##*[![:space:]]}"}"
  printf '%s\n' "$VALUE"
}

function status_field() {
  local LINE="$1" KEY="$2" WORD
  local -a WORDS
  read -r -a WORDS <<< "$LINE"
  for WORD in "${WORDS[@]}"; do
    if [[ "$WORD" == "${KEY}="* ]]; then
      printf '%s\n' "${WORD#*=}"
      return 0
    fi
  done
  return 1
}

function upgrade_label() {
  local COUNT="$1"
  case "$COUNT" in
    0) printf 'pkgs up to date' ;;
    1) printf '1 upgrade' ;;
    *)
      if [[ "$COUNT" =~ ^[0-9]+$ ]]; then
        printf '%s pkg upgrades' "$COUNT"
      else
        printf 'unknown'
      fi
      ;;
  esac
}

function column_width() {
  local WIDTH=0 ITEM
  for ITEM in "$@"; do
    if [[ ${#ITEM} -gt $WIDTH ]]; then
      WIDTH=${#ITEM}
    fi
  done
  printf '%s\n' "$WIDTH"
}

# Underline NEEDLE inside TEXT, then pad to WIDTH. Codes are not part of the width.
function print_marked_field() {
  local TEXT="$1" WIDTH="$2" NEEDLE="$3"
  local BEFORE AFTER PAD
  if [[ -n "$NEEDLE" && "$TEXT" == *"$NEEDLE"* ]]; then
    BEFORE="${TEXT%%"$NEEDLE"*}"
    AFTER="${TEXT#*"$NEEDLE"}"
    printf '%s%b%s%b%s' "$BEFORE" "$UL" "$NEEDLE" "$UL_OFF" "$AFTER"
    PAD=$((WIDTH - ${#TEXT}))
    if [[ $PAD -gt 0 ]]; then
      printf '%*s' "$PAD" ""
    fi
  else
    printf '%-*s' "$WIDTH" "$TEXT"
  fi
}

# Short hashes from different clones can differ in length. Treat either as a match if one prefixes the other.
function commits_match() {
  local LEFT="$1" RIGHT="$2"
  [[ -n "$LEFT" && -n "$RIGHT" && "$LEFT" != "-" && "$RIGHT" != "-" ]] || return 1
  [[ "$LEFT" == "$RIGHT" || "$LEFT" == "$RIGHT"* || "$RIGHT" == "$LEFT"* ]]
}

# SSH status-short for each masterlist host, in parallel, and compare commits to this repo.
function dot_report() {
  local LINE HOST IDX RC ERR ANY_BAD=0 COMMIT_DIFFERS=false
  local REF_COMMIT REF_BRANCH fd OUTPUT PART
  local MARK COLOR NAME PLAT ROLE_NAME BRANCH COMMIT UP REF STATE UPTIME
  local UNDER_HASH_FLAG UNDER_STATE_FLAG
  local W_NAME W_PLAT W_ROLE W_REF W_UP I
  local -a HOSTS SSH_OPTS OUT_FDS
  local -a MARKS COLORS NAMES PLATS ROLES REFS UPTIMES STATES UNDER_HASHES UNDER_STATES

  if [[ ! -f "$DOTFILE_MASTERLIST" ]]; then
    msg "${RED}Does not have a masterlist defined. This should be run from a primary dotfile instance."
    exit 1
  fi

  while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    LINE=$(trim_line "$LINE")
    [[ -z "$LINE" || "$LINE" == \#* ]] && continue
    HOSTS+=("$LINE")
  done < "$DOTFILE_MASTERLIST"

  if [[ ${#HOSTS[@]} -eq 0 ]]; then
    msg "${RED}Masterlist has no hosts."
    exit 1
  fi

  # Compare to this checkout only when it already has the upstream commits. Do not pull.
  local BEHIND COMPARE=false
  REF_BRANCH=$(git -C "$DOTREPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")
  REF_COMMIT=$(git -C "$DOTREPO" rev-parse --short HEAD 2>/dev/null || echo "-")
  if [[ "$REF_COMMIT" != "-" ]] && GIT_TERMINAL_PROMPT=0 git -C "$DOTREPO" fetch --quiet origin "$REF_BRANCH"; then
    BEHIND=$(git -C "$DOTREPO" rev-list --count "HEAD..origin/${REF_BRANCH}" 2>/dev/null || echo unknown)
    if [[ "$BEHIND" == "0" ]]; then
      COMPARE=true
    else
      msg "!! Dotfile repo is NOT up to date on branch ${REF_BRANCH}. Commit comparison skipped. Use ${UL}${BLU}pull${UL_OFF}${YEL} to update."
    fi
  else
    msg "${RED}Could not check upstream. Commit comparison skipped."
  fi

  if [[ "$COMPARE" == true ]]; then
    msg "${BLU}Checking ${#HOSTS[@]} host(s) against commit ${REF_COMMIT}"
  else
    msg "${BLU}Checking ${#HOSTS[@]} host(s) without commit comparison"
  fi

  # Non-interactive ssh does not expand the dot alias. Call the script directly.
  # Output stays in pipe buffers, not on disk.
  SSH_OPTS=(-n -o BatchMode=yes -o ConnectTimeout=8 -o ConnectionAttempts=1)

  for HOST in "${HOSTS[@]}"; do
    exec {fd}< <(
      ssh "${SSH_OPTS[@]}" "$HOST" 'bash "$HOME/dotfiles/dot.sh" status-short' 2>&1
      printf '\n__DOT_RC__%s\n' $?
    )
    OUT_FDS+=("$fd")
  done

  IDX=0
  for HOST in "${HOSTS[@]}"; do
    fd="${OUT_FDS[$IDX]}"
    OUTPUT=$(cat <&"$fd")
    exec {fd}<&-
    RC=1
    LINE=""
    ERR=""
    while IFS= read -r PART || [[ -n "$PART" ]]; do
      if [[ "$PART" == __DOT_RC__* ]]; then
        RC="${PART#__DOT_RC__}"
      elif [[ -z "$LINE" && "$PART" == hostname=* ]]; then
        LINE="$PART"
      elif [[ -n "$PART" ]]; then
        ERR="${ERR:+$ERR }$PART"
      fi
    done <<< "$OUTPUT"
    if [[ "$RC" -eq 0 && -n "$LINE" ]]; then
      NAME=$(status_field "$LINE" hostname || true)
      PLAT=$(status_field "$LINE" platform || true)
      ROLE_NAME=$(status_field "$LINE" role || true)
      BRANCH=$(status_field "$LINE" branch || true)
      COMMIT=$(status_field "$LINE" commit || true)
      UP=$(status_field "$LINE" upgradeable || true)
      UPTIME=$(status_field "$LINE" uptime || true)
      UPTIME=$(uptime_label "$UPTIME")
      NAME="${NAME:-$HOST}"
      PLAT="${PLAT:--}"
      ROLE_NAME="${ROLE_NAME:--}"
      if [[ -n "$BRANCH" && -n "$COMMIT" && "$BRANCH" != "-" && "$COMMIT" != "-" ]]; then
        REF="${BRANCH}@${COMMIT}"
      else
        REF="-"
      fi
      STATE=$(upgrade_label "$UP")
      UNDER_HASH_FLAG=0
      UNDER_STATE_FLAG=0
      if [[ "$COMPARE" == true ]] && ! commits_match "$REF_COMMIT" "$COMMIT"; then
        MARK=$'\u2716'
        COLOR="$RED"
        ANY_BAD=1
        COMMIT_DIFFERS=true
        UNDER_HASH_FLAG=1
      elif [[ "$UP" == "0" ]]; then
        MARK=$'\u2714'
        COLOR="$GRN"
      else
        MARK=$'\u25cf'
        COLOR="$YEL"
      fi
      if [[ "$UP" != "0" ]]; then
        UNDER_STATE_FLAG=1
      fi
    else
      ERR=$(trim_line "$ERR")
      ERR="${ERR:-status-short failed}"
      MARK=$'\u2716'
      COLOR="$RED"
      NAME="$HOST"
      PLAT="-"
      ROLE_NAME="-"
      REF="-"
      UPTIME="-"
      STATE="$ERR"
      UNDER_HASH_FLAG=0
      UNDER_STATE_FLAG=0
      ANY_BAD=1
    fi
    MARKS+=("$MARK")
    COLORS+=("$COLOR")
    NAMES+=("$NAME")
    PLATS+=("$PLAT")
    ROLES+=("$ROLE_NAME")
    REFS+=("$REF")
    UPTIMES+=("$UPTIME")
    STATES+=("$STATE")
    UNDER_HASHES+=("$UNDER_HASH_FLAG")
    UNDER_STATES+=("$UNDER_STATE_FLAG")
    IDX=$((IDX + 1))
  done

  W_NAME=$(column_width "${NAMES[@]}")
  W_PLAT=$(column_width "${PLATS[@]}")
  W_ROLE=$(column_width "${ROLES[@]}")
  W_REF=$(column_width "${REFS[@]}")
  W_UP=$(column_width "${UPTIMES[@]}")
  for I in "${!NAMES[@]}"; do
    printf '%b%s%b %-*s  %-*s  %-*s  ' \
      "${COLORS[$I]}" "${MARKS[$I]}" "$NC" \
      "$W_NAME" "${NAMES[$I]}" \
      "$W_PLAT" "${PLATS[$I]}" \
      "$W_ROLE" "${ROLES[$I]}"
    if [[ "${UNDER_HASHES[$I]}" == 1 ]]; then
      print_marked_field "${REFS[$I]}" "$W_REF" "${REFS[$I]##*@}"
    else
      printf '%-*s' "$W_REF" "${REFS[$I]}"
    fi
    printf '  %-*s  ' "$W_UP" "${UPTIMES[$I]}"
    if [[ "${UNDER_STATES[$I]}" == 1 ]]; then
      printf '%b%s%b\n' "$UL" "${STATES[$I]}" "$UL_OFF"
    else
      printf '%s\n' "${STATES[$I]}"
    fi
  done

  if [[ "$COMMIT_DIFFERS" == true ]]; then
    echo
    msg "Last 5 commits"
    git -C "$DOTREPO" log --graph --abbrev-commit -5 \
      --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
    echo
  fi

  exit "$ANY_BAD"
}
