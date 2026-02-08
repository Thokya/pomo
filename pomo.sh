
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
    echo "🔔 $TITLE: $MESSAGE"
    echo ""
  fi
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
                echo -e "\n▶️  Resumed"
              fi
              ;;
        q)
            echo -e "\n👋 Session ended"
            exit 0
            ;;
    esac

    # If paused, skip countdown
    if [[ "$PAUSED" == true ]]; then

      if [[ "$PAUSE_SHOWN" == false ]]; then
        echo -e "\n⏸️  Paused — press [r] to resume"
        PAUSE_SHOWN=true
      fi

      continue
    fi

    # Show timer
    printf "\r⏳ %s — %02d:%02d " \
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
  echo "🍅 Pomodoro Started"
  echo "======================"
  echo ""

  notify "$APP_NAME" "Focus session started 💪" "$WORK_SOUND"

  while true; do

    for ((i=1; i<=CYCLES; i++)); do

      # -----------------
      # Work
      # -----------------
      WORK_QUOTE=$(random_quote "${WORK_QUOTES[@]}")

      echo ""
      echo "🔥 WORK SESSION $i/$CYCLES"
      echo "📌 $WORK_QUOTE"
      echo "⏱️ 25 minutes"
      echo "----------------------"

      notify "Work Started" "$WORK_QUOTE (25 mins)" "$WORK_SOUND"

      countdown $WORK "Work"

      # -----------------
      # Short Break
      # -----------------
      BREAK_QUOTE=$(random_quote "${BREAK_QUOTES[@]}")

      echo ""
      echo "☕ SHORT BREAK"
      echo "📌 $BREAK_QUOTE"
      echo "⏱️ 2 minutes"
      echo "----------------------"

      notify "Break Time" "$BREAK_QUOTE (2 mins)" "$BREAK_SOUND"

      countdown $SHORT_BREAK "Break"

    done

    # -----------------
    # Long Break
    # -----------------
    LONG_QUOTE=$(random_quote "${BREAK_QUOTES[@]}")

    echo ""
    echo "🌴 LONG BREAK"
    echo "📌 $LONG_QUOTE"
    echo "⏱️ 10 minutes"
    echo "----------------------"

    notify "Long Break" "$LONG_QUOTE (10 mins)" "$LONG_BREAK_SOUND"

    countdown $LONG_BREAK "Long Break"

    # -----------------
    # Cycle End
    # -----------------
    END_QUOTE=$(random_quote "${END_QUOTES[@]}")

    echo ""
    echo "🏁 CYCLE COMPLETE"
    echo "📌 $END_QUOTE"
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
  *)
    echo "Usage: pomo start"
    ;;
esac

