{ pkgs, icons }:

let
  m = icons.media;
  pc = "${pkgs.playerctl}/bin/playerctl";

  # Ticker viewport width and per-character advance width in px, measured
  # against the "Nova Mono" font at the .media-title/.media-artist font
  # sizes below (9px -> 5px/char, 8px -> 4px/char; monospace, no padding).
  viewportPx = 44;
  titleCharPx = 5;
  artistCharPx = 4;

  statusScript = pkgs.writeShellScript "media-status" ''
    ${pc} status 2>/dev/null || echo Stopped
  '';

  # Streams a pixel offset (px) for the given metadata `field`
  # ("title"/"artist"): scrolls from 0 up to the text's overflow past
  # `viewport`, pauses, then snaps straight back to 0 (no reverse-animation)
  # and pauses again before the next pass. A label positioned with
  # `margin-left: -offsetpx` inside a fixed-size `scroll` (used purely as a
  # clipping viewport, not for user scrolling) then slides smoothly in place.
  # Resets to the start whenever the underlying text changes (track change).
  # Queries playerctl itself each tick rather than via a separate defpoll,
  # since eww only runs defpoll/deflisten vars that are referenced somewhere
  # in the widget tree — a poll that only fed an intermediate value would
  # otherwise never fire. Fetch and render cadence are decoupled: the frame
  # advances every 30ms, but playerctl is only re-invoked every ~1s.
  marqueeScript = pkgs.writeShellScript "media-marquee" ''
    field="$1"
    char_px="$2"
    viewport="$3"
    step=1
    end_pause_ticks=20
    start_pause_ticks=15
    fetch_every=33

    prev=""
    text=""
    offset=0
    state=2 # 0 = scrolling, 1 = paused at end (about to snap back), 2 = paused at start
    pause=$start_pause_ticks
    tick=0
    while true; do
      if [ $((tick % fetch_every)) -eq 0 ]; then
        text=$(${pc} metadata "$field" 2>/dev/null)
        if [ "$text" != "$prev" ]; then
          prev="$text"
          offset=0
          state=2
          pause=$start_pause_ticks
        fi
      fi

      len=''${#text}
      text_px=$((len * char_px))
      max_offset=$((text_px - viewport))
      if [ "$max_offset" -lt 0 ]; then
        max_offset=0
      fi

      printf '%s\n' "$offset"

      if [ "$max_offset" -gt 0 ]; then
        case "$state" in
          0)
            offset=$((offset + step))
            if [ "$offset" -ge "$max_offset" ]; then
              offset=$max_offset
              state=1
              pause=$end_pause_ticks
            fi
            ;;
          1)
            if [ "$pause" -gt 0 ]; then
              pause=$((pause - 1))
            else
              offset=0
              state=2
              pause=$start_pause_ticks
            fi
            ;;
          2)
            if [ "$pause" -gt 0 ]; then
              pause=$((pause - 1))
            else
              state=0
            fi
            ;;
        esac
      else
        offset=0
      fi

      tick=$((tick + 1))
      sleep 0.03
    done
  '';
in
{
  inherit statusScript marqueeScript;

  yuck = ''
    (defpoll media-status
      :interval "1s"
      "${statusScript}")

    (defpoll media-title
      :interval "1s"
      "${pc} metadata title 2>/dev/null")

    (defpoll media-artist
      :interval "1s"
      "${pc} metadata artist 2>/dev/null")

    (deflisten media-title-offset
      :initial "0"
      "${marqueeScript} title ${toString titleCharPx} ${toString viewportPx}")

    (deflisten media-artist-offset
      :initial "0"
      "${marqueeScript} artist ${toString artistCharPx} ${toString viewportPx}")

    (defvar media-hover false)

    (defwidget media []
      (eventbox
        :onhover "eww update media-hover=true"
        :onhoverlost "eww update media-hover=false"
        (box
          :class "media module"
          :orientation "v"
          :space-evenly false
          :halign "fill"
          :hexpand true
          :valign "center"
          :visible {media-status != "Stopped" && media-status != ""}
          (box
            :class "media-controls"
            :orientation "v"
            :space-evenly false
            :spacing 4
            :halign "center"
            (button :class "media-btn" :onclick "${pc} previous" "${m.prev}")
            (button
              :class "media-btn media-toggle"
              :onclick {"${pc} play-pause; eww update media-status=" + (media-status == "Playing" ? "Paused" : "Playing")}
              {media-status == "Playing" ? "${m.pause}" : "${m.play}"})
            (button :class "media-btn" :onclick "${pc} next" "${m.next}"))
          (revealer
            :transition "slidedown"
            :duration "150ms"
            :reveal {media-hover}
            (box
              :class "media-hover-content"
              :orientation "v"
              :space-evenly false
              :halign "fill"
              (scroll
                :class "media-ticker"
                :hscroll true
                :vscroll false
                :width ${toString viewportPx}
                :height 12
                (label
                  :class "media-title"
                  :halign "start"
                  :valign "center"
                  :style {"margin-left: -" + media-title-offset + "px;"}
                  :text {media-title}))
              (scroll
                :class "media-ticker"
                :hscroll true
                :vscroll false
                :width ${toString viewportPx}
                :height 11
                (label
                  :class "media-artist"
                  :halign "start"
                  :valign "center"
                  :style {"margin-left: -" + media-artist-offset + "px;"}
                  :text {media-artist})))))))
  '';

  scss = ''
    .media-btn {
      color: $accent2;
      background: transparent;
      border: none;
      box-shadow: none;
      padding: 0;
      font-size: 13px;
    }

    .media-toggle {
      color: $accent;
      font-size: 15px;
    }

    .media-hover-content {
      padding-top: 2px;
    }

    .media-ticker {
      background: transparent;
    }

    .media-ticker scrollbar {
      opacity: 0;
      min-width: 0;
      min-height: 0;
    }

    .media-title,
    .media-artist {
      font-family: "Nova Mono";
    }

    .media-title {
      color: $fg;
      font-size: 9px;
    }

    .media-artist {
      color: $fg-dim;
      font-size: 8px;
    }
  '';
}
