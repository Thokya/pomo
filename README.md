# 🍅 Pomodoro CLI

![Shell](https://img.shields.io/badge/Shell-Bash-green)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue)
![License](https://img.shields.io/github/license/Thokya/pomo)

> A minimalist, terminal-based Pomodoro timer for deep focus.

Built with Bash for developers, students, and terminal lovers who want **zero distractions and maximum flow**.

No bloated apps. No accounts. No nonsense. Just focus.

---

## 📸 Preview

```text
🔥 WORK SESSION 1/4
📌 Focus is the gateway to mastery.
⏳ Work — 24:59
```

---

## ✨ Features

✅ Clean terminal UI
✅ Customizable Pomodoro cycles
✅ macOS notifications (optional)
✅ Random motivation & rest quotes
✅ Infinite focus loops
✅ Fully hackable single-file script

---

## 🛠️ Requirements

### macOS (Default)

* Bash
* `osascript` (built-in on macOS)

### Linux / WSL / Others

* Bash only

> Notifications are optional. The timer works without them.

---

## 🚀 Installation

### Clone the Repository

```bash
git clone https://github.com/yourusername/pomodoro-cli.git
cd pomodoro-cli
```

### Make Executable

```bash
chmod +x pomo.sh
```

### (Optional) Add to PATH

```bash
sudo mv pomo.sh /usr/local/bin/pomo
```

Now you can run it anywhere:

```bash
pomo start
```

---

## ▶️ Usage

Start a Pomodoro session:

```bash
pomo start
```

You’ll get:

* 25 min focus
* 2 min break
* After 4 cycles → 10 min break
* Repeats forever

Lock in. 💪🍅

---

## ⚙️ Configuration

Open `pomo.sh` and edit:

```bash
WORK=1500        # 25 minutes
SHORT_BREAK=120  # 2 minutes
LONG_BREAK=600   # 10 minutes
CYCLES=4
```

You can also customize:

* Quotes
* Sounds
* Emojis
* App name

Everything lives in one file.

---

## 🖥️ Cross-Platform Support

By default, Pomodoro CLI uses `osascript` for macOS notifications.

If you’re on Linux, WSL, or another OS, you can disable notifications and the timer will still work perfectly.

### Disable macOS Notifications

Remove or comment out:

```bash
notify() {
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"$SOUND\""
}
```

And all `notify` calls.

---

### 🐧 Linux Notifications (Optional)

If you want notifications on Linux:

```bash
notify() {
  notify-send "$1" "$2"
}
```

Requires `libnotify`.

---

## 🧠 Philosophy

> “Searching for productivity apps is the fastest way to avoid being productive.”

So this exists.

One file.
Local.
No tracking.
No distractions.

Just work.

---

## 📄 License

MIT License — free to use, fork, and improve.

---

## 🌟 Contributing

PRs welcome.

Ideas:

* Windows notifications
* Config file support
* Stats tracking
* TUI interface

---

## ⭐ Support

If this helps you focus, consider giving it a star.
It helps more than you think ❤️
