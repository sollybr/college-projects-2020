breed [dirties dirty]
breed [walls wall]
breed [vacuum cleaner]
vacuum-own [
  percmax-x
  percmin-x
  percmax-y
  percmin-y
  refposx
  refposy
  curposx
  curposy
  score
  gave-up-at
  count-possib
  possib-whites
  dir
]
globals [
  stress-results
  valid-corx
  valid-cory
  usable-area
  unoperating
]
to setup
  clear-all
  set-patch-size 16 * zoom / 100
  let counter pxmin
  set valid-corx [ ]
  set valid-cory [ ]
  while [counter <= pxmax]
  [
    set valid-corx lput counter valid-corx
    set counter counter + 2
  ]
  set counter pymin
  while [counter <= pymax]
  [
    set valid-cory lput counter valid-cory
    set counter counter + 2
  ]
  set usable-area (length valid-corx * length valid-cory)
  set-default-shape vacuum "car"
  set-default-shape dirties "circle"
  set-default-shape walls "square"
  setup-room
  ask turtles [set size 2.5]
  reset-ticks
  set stress-results 0
end

to setup-room
  ask patches [ set pcolor 9 ]
  setup-obstacles
  setup-dirties
  setup-vacuum one-of valid-corx one-of valid-cory
end

to setup-obstacles
  create-walls round (20 * usable-area / 100) [ setxy one-of valid-corx one-of valid-cory
    set color black
    while [any? other turtles-here ]
    [ setxy one-of valid-corx one-of valid-cory ]
  ]
end
to reset-vacuum
  ask self [
    set heading one-of [ 45 90 135 180 ]
    set heading heading * one-of [ 1 -1 ]
    set curposx 0
    set curposy 0
    set percmax-x 0
    set percmin-x 0
    set percmax-y 0
    set percmin-y 0
    set score 0
    set gave-up-at 0
    set refposx 0
    set refposy 0
    set count-possib 0
    set dir one-of [ 1 -1 ]
    set possib-whites [ ]
  ]
end
to setup-vacuum [ ?1 ?2 ]
  create-vacuum quant-cleaners [ setxy ?1 ?2
    set heading 90
    set color ((who - 1) * 10) + 15
    reset-vacuum
    while [any? other walls-here or any? other vacuum-here]
    [ setxy one-of valid-corx one-of valid-cory ]
  ]
end

to setup-dirties
  create-dirties round ((dirty-quant / 100) * (80 * usable-area / 100)) [ setxy one-of valid-corx one-of valid-cory
    set color 5
    while [ any? other turtles-here ]
    [ setxy one-of valid-corx one-of valid-cory ]
  ]
end

to re-run
  if ticks > 1 [
    ifelse stress-results != 0
    [ set stress-results ((stress-results + ticks) / 2) ]
    [ set stress-results ticks]
  ]
  reset-perspective
  reset-ticks
  clear-plot
  set-patch-size 16 * zoom / 100
  let counter 0
  while [ counter < quant-cleaners ] [ ask cleaner (counter + count walls + count dirties) [
    setxy (xcor - ( 2 * curposx )) (ycor - ( 2 * curposy ))
    reset-vacuum
    ]
    set counter counter + 1
  ]
  set unoperating 0
  ask dirties [ set color 5 ]
end

to get-dirty [ ? ]
  ask cleaner ? [
    ask dirties-here [
      set color 8
      ;can change deterministic behavior
    ]
    set score score + 1
  ]
end

to go
  if not any? dirties with [color = 5] or ticks = 144000 or not any? vacuum or unoperating >= quant-cleaners
  [
    if count vacuum > 1 [      watch item (quant-cleaners - 1) (sort-on [score] vacuum)    ]
    stop
  ]
  tick
  let counter 0
  while [ counter < quant-cleaners ]
  [
    ask cleaner (counter + count walls + count dirties) [
      if (gave-up-at = 0)[
        ifelse ((score / ticks) < (0.25 * dirty-quant / 100))
        and ticks >= round((2 * (1 + percmax-x - percmin-x) * (1 + percmax-y - percmin-y)) + handcap) and not any? dirties-here with [color = 5][
          set gave-up-at ticks
          set unoperating unoperating + 1
        ]
        [
          ifelse any? dirties-here with [color = 5]
          [ get-dirty (counter + count walls + count dirties) ]
          [ ifelse smart-moves?
            [ ifelse intel-level > 0 and count-possib = 0 [move-smartA (counter + count walls + count dirties) ]
              [move-smart (counter + count walls + count dirties) 1]
            ]
            [move-random (counter + count walls + count dirties) 0]
          ]
        ]
      ]
    ]
    set counter counter + 1
  ]
end

to move-random [ ? ?1 ]
  ask cleaner ? [
    let max-count 0
    let extraspc 0
    let check-dirties 0
    if member? heading [ 45 315 225 135 ]
    [ set extraspc 1 ]
    while [(any? walls-on patch-ahead (2 + extraspc) or any? vacuum-on patch-ahead (2 + extraspc)
      or not (member? ([pxcor] of patch-ahead (2 + extraspc)) valid-corx
        and member? ([pycor] of patch-ahead (2 + extraspc)) valid-cory))
      or (smart-moves? = false and intel-level = 1 and (not any? (dirties-on patch-ahead (2 + extraspc)) with [color = 5] and max-count < 8))
     ]
    [
      set heading heading - 45
      set extraspc 0
      if member? heading [ 45 315 225 135 ]
      [ set extraspc 1 ]
      set max-count max-count + 1
    ]
    if max-count != 4 [
      ifelse max-count != 4 and member? heading [ 0 90 180 270 360 ][
        move-to patch-ahead 2
        set curposx curposx + round (sin heading)
        set curposy curposy + round (cos heading)
      ]
      [
        move-to patch-ahead (2 + extraspc)
        set curposx curposx + round (sin heading / sin 45)
        set curposy curposy + round (cos heading / sin 45)
      ]
      ifelse curposx > percmax-x
              [ set percmax-x curposx ]
      [
        if curposx < percmin-x
        [ set percmin-x curposx ]
      ]
      ifelse curposy > percmax-y
      [ set percmax-y curposy ]
      [
        if curposy < percmin-y
        [ set percmin-y curposy ]
      ]
      if ?1 = 0 [
        set heading heading - one-of [45 90 135 180 225 270]
      ]
    ]
  ]
end

to move-smart [ ? ?1]
  ask cleaner ? [
    ifelse ?1 < 8[
      let extraspc 0
      if member? heading [ 45 315 225 135 ]
      [ set extraspc 1 ]
      ifelse ((any? walls-on patch-ahead (2 + extraspc) or any? vacuum-on patch-ahead (2 + extraspc)
        or not (member? ([pxcor] of patch-ahead (2 + extraspc)) valid-corx
          and member? ([pycor] of patch-ahead (2 + extraspc)) valid-cory))
      or any? (dirties-on patch-ahead (2 + extraspc)) with [color = 8] or not any? turtles-on patch-ahead (2 + extraspc))
      or ((((extraspc = 0 and (curposx + round (sin heading) > refposx + sin heading and curposy + round (cos heading) > refposy + cos heading))
        or (extraspc = 1 and (curposx + round (sin heading / sin 45) > refposx + round (sin heading / sin 45)
          and curposy + round (cos heading / sin 45) > refposy + round (cos heading / sin 45))))) and count-possib > 0)
      [
        set heading heading - 45 * dir
        move-smart ? (?1 + 1)
      ]
      [
        move-random ? 1
        if extraspc = 1 [
          ifelse ?1 = 2 [set heading heading + 90 ]
          [if ?1 = 3 [set heading heading + 180 ]]
        ]
        if count-possib != 0 [
          set count-possib count-possib - 1
        ]
      ]
    ]
    [
      ifelse intel-level > 0 and length possib-whites != 0 [ set heading one-of possib-whites
      move-random ? 1]
      [move-random ? 0]
    ]
  ]
end

to move-smartA [ ? ]
  let counter 0
  let hipposx 0
  let hipposy 0
  let possibW [ ]
  let possib [ ]
  ask cleaner ? [
    while [ counter < 8 ] [
      let extraspc 0
      if member? heading [ 45 315 225 135 ]
      [ set extraspc 1 ]
      if not (any? walls-on patch-ahead (2 + extraspc) or any? vacuum-on patch-ahead (2 + extraspc)
        or not (member? ([pxcor] of patch-ahead (2 + extraspc)) valid-corx
          and member? ([pycor] of patch-ahead (2 + extraspc)) valid-cory))
      [
        ifelse any? (dirties-on patch-ahead (2 + extraspc)) with [color = 8] [set possibW lput heading possibW]
        [set possib lput heading possib
          ifelse extraspc = 0 [
            set hipposx curposx + round (sin heading)
            set hipposy curposy + round (cos heading)
          ]
          [
            set hipposx curposx + round (sin heading / sin 45)
            set hipposy curposy + round (cos heading / sin 45)
          ]
          ifelse hipposx > percmax-x
          [ set percmax-x hipposx ]
          [
            if hipposx < percmin-x
            [ set percmin-x hipposx ]
          ]
          ifelse hipposy > percmax-y
          [ set percmax-y hipposy ]
          [
            if hipposy < percmin-y
            [ set percmin-y hipposy ]
          ]
        ]
      ]
      set heading heading - 45
      set counter counter + 1
    ] ; verifies 8 neighbors
    if ((1 + percmax-x - percmin-x) * (1 + percmax-y - percmin-y)) = 1 and length possibW = 0[
      set gave-up-at ticks
      set unoperating unoperating + 1
    ]
    set count-possib length possib
    set possib-whites possibW
    set refposx curposx
    set refposy curposy
  ]
  move-smart ? 1
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
614
415
-1
-1
12.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
13
10
201
65
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
13
67
78
100
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
145
67
200
100
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
14
102
47
262
zoom
zoom
25
75
75.0
25
1
%
VERTICAL

SLIDER
15
295
187
328
pxmax
pxmax
pxmin + 2
14
14.0
2
1
NIL
HORIZONTAL

SLIDER
15
327
187
360
pxmin
pxmin
-14
pxmax - 2
-14.0
2
1
NIL
HORIZONTAL

SLIDER
15
360
187
393
pymax
pymax
pymin + 2
14
14.0
2
1
NIL
HORIZONTAL

SLIDER
15
393
187
426
pymin
pymin
-14
pxmax - 2
-14.0
2
1
NIL
HORIZONTAL

SLIDER
129
102
162
263
quant-cleaners
quant-cleaners
1
round ((0.25 * count walls) - 1)
1.0
1
1
cleaner(s)
VERTICAL

SLIDER
165
102
198
263
dirty-quant
dirty-quant
33
100
100.0
1
1
%
VERTICAL

SWITCH
25
262
181
295
smart-moves?
smart-moves?
0
1
-1000

PLOT
618
10
818
160
Scores
Ticks
Clean spots
0.0
400.0
0.0
80.0
true
false
"" ""
PENS
"0" 1.0 0 -2674135 true "" "if [gave-up-at] of cleaner (count walls + count dirties) = 0[\nplot [score] of cleaner (count walls + count dirties)\n]"
"1" 1.0 0 -955883 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 1) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 1)\n]"
"2" 1.0 0 -6459832 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 2) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 2)\n]"
"3" 1.0 0 -1184463 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 3) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 3)\n]"
"4" 1.0 0 -10899396 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 4) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 4)\n]"
"5" 1.0 0 -13840069 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 5) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 5)\n]"
"6" 1.0 0 -14835848 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 6) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 6)\n]"
"7" 1.0 0 -11221820 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 7) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 7)\n]"
"8" 1.0 0 -13791810 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 8) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 8)\n]"
"9" 1.0 0 -13345367 true "" "if [gave-up-at] of cleaner (count walls + count dirties + 9) = 0[\nplot [score] of cleaner ((count walls + count dirties) + 9)\n]"

MONITOR
618
162
818
211
"Best" Cleaner
([score] of item (quant-cleaners - 1) (sort-on [score] vacuum)) / ticks
2
1
12

MONITOR
618
262
818
311
% Locais sujos restantes
100 * (count dirties with [color = 5] / (count dirties with [color = 5] + count dirties with [color = 8]))
4
1
12

SLIDER
47
102
80
262
handcap
handcap
-100
100
0.0
10
1
ticks
VERTICAL

MONITOR
618
212
818
261
2nd "Best" Cleaner
([score] of item (quant-cleaners - 2) (sort-on [score] vacuum)) / ticks
2
1
12

BUTTON
79
67
144
100
Re-run
re-run
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
618
360
818
409
Stress ticks average
stress-results
0
1
12

MONITOR
618
313
818
358
Locais limpos
sum [score] of vacuum
17
1
11

SLIDER
86
102
119
263
intel-level
intel-level
0
1
1.0
1
1
NIL
VERTICAL

@#$#@#$#@
## WHAT IS IT?

Esse modelo busca introduzir conceitos básicos da sintaxe de NetLogo, agentes de resolução de problemas e agentes inteligentes.

## HOW IT WORKS

The agent has its set of movement styles chosen by the user, in order to look for the best approach to clean the ambient it is located at.

## HOW TO USE IT

O modelo possui diversas variáveis. As mais importantes são:

dirty-quant - Quantidade de sujeira na quantidade restante não ocupada por obstáculos.
quant-cleaners - Quantidade de aspiradores. (Máx. = em relação a área total usável.
smart-moves? - Define o tipo de movimentação. Inicialmente duas sendo uma especial.
handcap - Uma quantidade esperada de ticks a mais para completar a limpeza.

## THINGS TO NOTICE

Alterar algumas variáveis durante o experimento ou antes de usar re-run pode causar alguns erros.

## THINGS TO TRY

Você pode verificar como a pontuação de um agente e o comportamento de seu escalonamento mudam drasticamente alterando no meio de um experimento o switch de smart-moves?

## EXTENDING THE MODEL

Você pode alterar o comportamento determinístico do ambiente empregando possibilidades do aspirador conseguir ou não aspirar completamente e definindo a porcentagem restante de sujeira naquela área após a ação de limpar. Seria necessário nesse caso fazer uma alteração na medida de performance para que refletisse o comportamento do ambiente.

## NETLOGO FEATURES

Utilizamos um ambiente discreto e finito no modelo. A movimentação é feita utilizando pontos com cordenadas bem definidas, usando comando move-to juntamente com as variáveis heading e patch-ahead. Note que patch-ahead terá o número de patches a frente definido por qual tipo de movimento será feito (diagonal ou horizontal/vertical). Esses conceitos são fundamentais para o reconhecimento do ambiente.

## RELATED MODELS

A even more sophisticated vacuum cleaner also with discrete and deterministic behavior.
https://github.com/rsrgn/vacuum-cleaner-netlogo

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="STRESSTEST-RANDOM" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>[score] of cleaner (count dirties + count walls)</metric>
    <metric>100 * (count dirties with [color = 5] / (count dirties with [color = 5] + count dirties with [color = 8]))</metric>
    <enumeratedValueSet variable="pymin">
      <value value="-14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quant-cleaners">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pxmin">
      <value value="-14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pymax">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="zoom">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pxmax">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dirty-quant">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="handcap">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="smart-moves?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="STRESSTEST-SMART" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>[score] of cleaner (count dirties + count walls)</metric>
    <metric>100 * (count dirties with [color = 5] / (count dirties with [color = 5] + count dirties with [color = 8]))</metric>
    <enumeratedValueSet variable="pymin">
      <value value="-14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quant-cleaners">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pxmin">
      <value value="-14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pymax">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="zoom">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pxmax">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dirty-quant">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="handcap">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="smart-moves?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
