#!/bin/bash

# EDAF v1.0 - Notification System
# Plays sound notifications for task completion and errors

SOUND="${2:-Glass}"

# OS検出 / OS Detection
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif grep -q Microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

OS=$(detect_os)

# 音声再生関数 / Sound playback function
play_sound() {
  local sound_file="$1"

  case "$OS" in
    macos)
      # macOS: afplay使用（フォアグラウンドで実行）
      afplay "$sound_file"
      ;;
    wsl)
      # WSL: PowerShellを使ってWindows側で再生
      local win_path=$(wslpath -w "$sound_file")
      powershell.exe -c "(New-Object Media.SoundPlayer '$win_path').PlaySync();" 2>/dev/null &
      ;;
    linux)
      # Linux: paplayまたはaplay使用
      if command -v paplay &> /dev/null; then
        paplay "$sound_file" 2>/dev/null &
      elif command -v aplay &> /dev/null; then
        aplay "$sound_file" 2>/dev/null &
      else
        echo "Warning: No audio player found (paplay or aplay required)" >&2
      fi
      ;;
    *)
      echo "Warning: Unsupported OS for audio playback" >&2
      ;;
  esac
}

# 音声アラート / Sound alert
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOUNDS_DIR="$SCRIPT_DIR/../sounds"

# Custom sounds / カスタム音声
if [ "$SOUND" = "CatMeow" ]; then
  # 猫の鳴き声を3回再生 / Play cat meow 3 times
  for i in 1 2 3; do
    if [ -f "$SOUNDS_DIR/cat-meowing.mp3" ]; then
      play_sound "$SOUNDS_DIR/cat-meowing.mp3"
      sleep 1.8
    fi
  done
elif [ "$SOUND" = "WarblerSong" ]; then
  # warbler-songを3回再生 / Play warbler song 3 times
  for i in 1 2 3; do
    if [ -f "$SOUNDS_DIR/bird_song_robin.mp3" ]; then
      play_sound "$SOUNDS_DIR/bird_song_robin.mp3"
      sleep 1.8
    fi
  done
elif [ "$SOUND" = "TaskComplete" ]; then
  # タスク完了音 / Task completion sound
  if [ -f "$SOUNDS_DIR/task-complete.mp3" ]; then
    play_sound "$SOUNDS_DIR/task-complete.mp3"
  elif [ "$OS" = "macos" ]; then
    afplay "/System/Library/Sounds/Glass.aiff"
  fi
elif [ "$SOUND" = "Error" ]; then
  # エラー音 / Error sound
  if [ -f "$SOUNDS_DIR/error.mp3" ]; then
    play_sound "$SOUNDS_DIR/error.mp3"
  elif [ "$OS" = "macos" ]; then
    afplay "/System/Library/Sounds/Basso.aiff"
  fi
else
  # システムサウンド / System sound
  if [ "$OS" = "macos" ]; then
    afplay "/System/Library/Sounds/${SOUND}.aiff"
  else
    echo "Warning: System sounds only supported on macOS" >&2
  fi
fi
