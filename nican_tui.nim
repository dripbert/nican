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

proc draw_day_info(d: int): void =
  tb.write(50, 1, reset_style, bg_black, fg_white, $cmmm & " " & $d & " " &  $cy)


var width:  int = terminal_width()
var height: int = terminal_height()

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

