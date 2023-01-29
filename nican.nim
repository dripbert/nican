import std/[strutils, times, os]

const mdays: seq[int] = @[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const padding: int = 4
let notes_file: string = get_env("HOME") & "/.nimem_notes"

let cur     = now()
let cur_d   = format(cur, "dd")
let cur_m   = format(cur, "MM")
let cur_my  = format(cur, "MMMM yyyy")
let cur_ym  = format(cur, "yyyy-MM")
let cur_ymd = format(cur, "yyyy-MM-dd")

let cdays   = mdays[parse_int($cur_m) - 1]

proc norm_len(str: string, l: int): string =
    let slen: int = len(str)
    var nstr: string = ""

    if slen < l:
        nstr = str & "\e[0m" & repeat(" ", (l - slen))
    return nstr

proc get_notes(file: string): seq =
    let notes = read_file(file).split('\n')
    return notes

proc color_pr(pr: int): string =
    if pr == 2:
        return "\e[32;1m"
    elif pr == 1:
        return "\e[33;1m"
    return "\e[31;1m"
    
proc print_color(d: int): void =
    let notes: seq[string] = get_notes(notes_file)
    let cday: int = parse_int($cur_d)

    if cday == d:
        stdout.write("\e[30;47m")
    for note in notes:
        if note == "": continue

        let date: DateTime = parse(note.split('|')[^1], "yyyy-MM-dd")
        let pr: int = parse_int(note.split('|')[0])
        if format(date, "yyyy-MM") != cur_ym: continue

        let day: int = parse_int(format(date, "dd"))
        if d == day: 
            stdout.write(color_pr(pr))

proc print_calendar(): void =
    for n in countup(1, cdays):

        print_color(n)
        stdout.write(norm_len($n, padding))
        if n mod 7 == 0:
            stdout.write("\n")
    stdout.write("\n")

proc print_wdays(): void =
    let first = $cur_ym & "-01" 
    for n in countup(0, 6):
        let day = format(parse(first, "yyyy-MM-dd") + n.days, "ddd")

        let d: string = norm_len($day, padding)
        stdout.write(d)
    stdout.write("\n")

#let dt = parse("2000-01-01", "yyyy-MM-dd")
if not file_exists(notes_file):
    write_file(notes_file, "")
    
echo cur_my
print_wdays()
print_calendar()
