import os, times, strutils
import illwill

const days: int = 30

let c    = now()
let cy   = format(c, "yyyy")
let cym  = format(c, "yyyy-MM")
let cmy  = format(c, "MMMM yyyy")
let cdd  = format(c, "dd")
let cmmm = format(c, "MMM")
let d1om = parse($cym & "-01", "yyyy-MM-dd")

proc exit() {.noconv.} =
  illwill_deinit()
  show_cursor()
  quit(0)

illwill_init(fullscreen=true)
set_control_c_hook(exit)
hide_cursor()

var tb = new_terminal_buffer(terminal_width(), terminal_height())
# tb.draw_rect(0, 0,  40, 5)

proc get_notes(f: string): seq =
  let notes = read_file(f).split('\n')
  return notes

proc draw_days(): void =
  tb.write(0, 0, reset_style, bg_black, fg_white, cmy)
  var day: string = ""
  for n in countup(0, 6):
    day = format(d1om + n.days, "ddd")
    tb.write(n * 4, 1, reset_style, bg_black, fg_white, day)

proc draw_cal(c: int): void =
  draw_days()

  var x: int = 0
  var y: int = 2
  for n in countup(1, days):
    if n == c:
      tb.write(x, y, reset_style, bg_white, fg_black, $n)
    else:
      tb.write(x, y, reset_style, bg_black, fg_white, $n)
    x += 4
    if n mod 7 == 0:
      y += 1
      x = 0

const msg_width = 43
proc norm_len(str: string): string =
  if len(str) > msg_width:
    return str[0..^(msg_width - 3)] & "..."

  return str & repeat(" ", (msg_width - len(str)) )

proc pr_col(pr: int): string =
  if pr == 0: return "\e[31m"
  elif pr == 1: return "\e[33m"
  return "\e[32m"

var width:  int = terminal_width()
var height: int = terminal_height()

proc draw_notes(x: int, y: int, notes: seq[string], day: int): void =
  var line: string
  var snote: seq[string]
  for note in notes:
    if note == "": continue
    snote = split(note, "|")
    if snote[2] != $cym & "-" & $day: continue
    # line = pr_col(parse_int(snote[0])) & snote[0] & "\e[0m  | [ \"\e[1m" & norm_len(snote[1]) & "\e[0m\" ] | \e[34m" & snote[2]
    line = snote[0] & "  | [ \"" & norm_len(snote[1]) & "\" ] | " & snote[2]
    tb.write(x, y, reset_style, bg_black, fg_white, line)

const notes_file = "/home/robert/.nimem_notes"
let notes: seq[string] = get_notes(notes_file)

proc draw_day_info(d: int): void =
  tb.write(40, 1, reset_style, bg_black, fg_white, $cmmm & " " & $d & " " &  $cy)
  draw_notes(40, 2, notes, d)


var curs:   int = parse_int(cdd)


while true:
  var key = get_key()
  case key
  of Key.None: discard
  of Key.Q: exit()
  of Key.J:
    if curs + 7 <= days:
      curs += 7
  of Key.K:
    if curs - 7 > 0:
      curs -= 7
  of Key.L:
    if curs + 1 <= days:
      curs += 1
  of Key.H:
    if curs - 1 > 0:
      curs -= 1
  of Key.Enter: draw_day_info(curs)
  else:
    tb.write(8, 4, reset_style, fg_green, "a")

  width  = terminal_width()
  height = terminal_height()

  draw_cal(curs)

  tb.display()
  sleep(50)

