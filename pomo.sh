
#!/bin/bash

# =========================
# Timer State
# =========================

PAUSED=false
PAUSE_SHOWN=false

# =========================
# OS Detection
# =========================

OS_NAME=$(uname)

IS_MAC=false

if [[ "$OS_NAME" == "Darwin" ]]; then
  IS_MAC=true
fi

# =========================
# Emoji Support Detection
# =========================

SUPPORTS_EMOJI=false

if [[ "$LANG" == *"UTF-8"* ]] || [[ "$LC_ALL" == *"UTF-8"* ]]; then
  SUPPORTS_EMOJI=true
fi

# =========================
# Emoji Setup
# =========================

if [[ "$SUPPORTS_EMOJI" == true ]]; then
  EMOJI_TIMER="⏳"
  EMOJI_WORK="🔥"
  EMOJI_BREAK="☕"
  EMOJI_LONG="🌴"
  EMOJI_END="🏁"
  EMOJI_PAUSE="⏸️"
  EMOJI_PLAY="▶️"
  EMOJI_QUIT="👋"
  EMOJI_POMO="🍅"
  EMOJI_BELL="🔔"
  EMOJI_ARMS="💪"
  EMOJI_PIN="📌"
  EMOJI_CLOCK="⏱️"
  EMOJI_GRAPH="📊"
else
  EMOJI_TIMER=""
  EMOJI_WORK=""
  EMOJI_BREAK=""
  EMOJI_LONG=""
  EMOJI_END=""
  EMOJI_PAUSE=""
  EMOJI_PLAY=""
  EMOJI_QUIT=""
  EMOJI_POMO=""
  EMOJI_BELL=""
  EMOJI_ARMS=""
  EMOJI_PIN=""
  EMOJI_CLOCK=""
  EMOJI_GRAPH=""
fi

# =========================
# Pomodoro Settings (seconds)
# =========================
WORK=1500        # 25 min
SHORT_BREAK=120  # 2 min
LONG_BREAK=600   # 10 min
CYCLES=4

APP_NAME="Pomodoro CLI"

# =========================
# Sounds
# =========================
WORK_SOUND="Hero"
BREAK_SOUND="Ping"
LONG_BREAK_SOUND="Submarine"
END_SOUND="Glass"

# =========================
# Quotes
# =========================

WORK_QUOTES=(
  "Discipline is choosing between what you want now and what you want most."
  "Focus is the gateway to mastery."
  "Small progress is still progress."
  "Your future self is watching you right now."
  "Deep work creates rare value."
  "Do it with full presence."
)

BREAK_QUOTES=(
  "Rest is part of the process."
  "Recovery fuels performance."
  "Breathe. Reset. Return stronger."
  "Short pause. Long power."
  "Stillness builds clarity."
)

END_QUOTES=(
  "Session complete. Respect your effort."
  "You showed up. That matters."
  "Consistency beats motivation."
  "Another brick laid in your future."
)

# =========================
# Stats Storage
# =========================

POMO_DIR="$HOME/.pomo"
STATS_FILE="$POMO_DIR/stats.log"

mkdir -p "$POMO_DIR"

# =========================
# Helpers
# =========================

random_quote() {
  local ARRAY=("$@")
  echo "${ARRAY[RANDOM % ${#ARRAY[@]}]}"
}

notify() {
  local TITLE="$1"
  local MESSAGE="$2"
  local SOUND="$3"

  if [[ "$IS_MAC" == true ]]; then
    # macOS notification
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"$SOUND\""
  else
    # Fallback for other OS
    echo ""
    echo "$EMOJI_BELL $TITLE: $MESSAGE"
    echo ""
  fi
}

log_session() {
  local TYPE="$1"     # work / break
  local SECONDS="$2"
  local DATE

  DATE=$(date +"%Y-%m-%d")

  echo "$DATE,$TYPE,$SECONDS" >> "$STATS_FILE"
}

show_summary() {

  if [[ ! -f "$STATS_FILE" ]]; then
    echo "No stats found yet. Start a session first."
    return
  fi

  local TODAY
  TODAY=$(date +"%Y-%m-%d")

  local DATA
  DATA=$(grep "^$TODAY" "$STATS_FILE")

  if [[ -z "$DATA" ]]; then
    echo "No sessions logged for today."
    return
  fi

  local WORK_SECS=0
  local BREAK_SECS=0
  local WORK_COUNT=0

  while IFS=',' read -r DATE TYPE SECS; do

    if [[ "$TYPE" == "work" ]]; then
      ((WORK_SECS+=SECS))
      ((WORK_COUNT++))
    else
      ((BREAK_SECS+=SECS))
    fi

  done <<< "$DATA"

  # Convert seconds
  local WORK_H=$((WORK_SECS/3600))
  local WORK_M=$(((WORK_SECS%3600)/60))
  local BREAK_M=$((BREAK_SECS/60))

  echo ""
  echo "$EMOJI_GRAPH Pomodoro Summary (Today)"
  echo "--------------------------"
  echo "Date          : $TODAY"
  echo "Work Sessions : $WORK_COUNT"
  echo "Focus Time    : ${WORK_H}h ${WORK_M}m"
  echo "Break Time    : ${BREAK_M}m"
  echo ""
}

countdown() {
    local SECONDS=$1
    local LABEL=$2

    PAUSED=false
    PAUSE_SHOWN=false

    echo "Controls: [p] pause | [r] resume | [q] quit"

    while [ $SECONDS -gt 0 ]; do

    # Check for keypress (1 sec timeout)
    read -rsn1 -t 1 key

    case "$key" in
        p)
            if [[ "$PAUSED" == false ]]; then
                PAUSED=true
                PAUSE_SHOWN=false
              fi
              ;;
        r)
            if [[ "$PAUSED" == true ]]; then
                PAUSED=false
                PAUSE_SHOWN=false
                echo -e "\n$EMOJI_PLAY  Resumed"
              fi
              ;;
        q)
            echo -e "\n$EMOJI_QUIT Session ended"
            exit 0
            ;;
    esac

    # If paused, skip countdown
    if [[ "$PAUSED" == true ]]; then

      if [[ "$PAUSE_SHOWN" == false ]]; then
        echo -e "\n$EMOJI_PAUSE  Paused — press [r] to resume"
        PAUSE_SHOWN=true
      fi

      continue
    fi

    # Show timer
    printf "\r$EMOJI_TIMER %s — %02d:%02d " \
        "$LABEL" \
        $((SECONDS/60)) \
        $((SECONDS%60))

    ((SECONDS--))

    done

    echo ""
}

# =========================
# Main Pomodoro Logic
# =========================

start_pomo() {

  clear
  echo "$EMOJI_POMO Pomodoro Started"
  echo "======================"
  echo ""

  notify "$APP_NAME" "Focus session started $EMOJI_ARMS" "$WORK_SOUND"

  while true; do

    for ((i=1; i<=CYCLES; i++)); do

      # -----------------
      # Work
      # -----------------
      WORK_QUOTE=$(random_quote "${WORK_QUOTES[@]}")

      echo ""
      echo "$EMOJI_WORK WORK SESSION $i/$CYCLES"
      echo "$EMOJI_PIN $WORK_QUOTE"
      echo "$EMOJI_CLOCK 25 minutes"
      echo "----------------------"

      notify "Work Started" "$WORK_QUOTE (25 mins)" "$WORK_SOUND"

      countdown $WORK "Work"
      log_session "work" "$WORK"

      # -----------------
      # Short Break
      # -----------------
      BREAK_QUOTE=$(random_quote "${BREAK_QUOTES[@]}")

      echo ""
      echo "$EMOJI_BREAK SHORT BREAK"
      echo "$EMOJI_PIN $BREAK_QUOTE"
      echo "$EMOJI_CLOCK 2 minutes"
      echo "----------------------"

      notify "Break Time" "$BREAK_QUOTE (2 mins)" "$BREAK_SOUND"

      countdown $SHORT_BREAK "Break"
      log_session "break" "$SHORT_BREAK"

    done

    # -----------------
    # Long Break
    # -----------------
    LONG_QUOTE=$(random_quote "${BREAK_QUOTES[@]}")

    echo ""
    echo "$EMOJI_LONG LONG BREAK"
    echo "$EMOJI_PIN $LONG_QUOTE"
    echo "$EMOJI_CLOCK 10 minutes"
    echo "----------------------"

    notify "Long Break" "$LONG_QUOTE (10 mins)" "$LONG_BREAK_SOUND"

    countdown $LONG_BREAK "Long Break"
    log_session "break" "$LONG_BREAK"

    # -----------------
    # Cycle End
    # -----------------
    END_QUOTE=$(random_quote "${END_QUOTES[@]}")

    echo ""
    echo "$EMOJI_END CYCLE COMPLETE"
    echo "$EMOJI_PIN $END_QUOTE"
    echo "----------------------"

    notify "Cycle Finished" "$END_QUOTE" "$END_SOUND"

  done
}

# =========================
# Command Handler
# =========================

case "$1" in
  start)
    start_pomo
    ;;
  summary)
    show_summary
    ;;
  *)
    echo "Usage: pomo start"
    ;;
esac

