globals [ urban-to-rural  rural-to-urban] ;Lori
patches-own [
my-patches
number-of-jobs
wage
vacancies
utility
seeds
unemployment
employment
]

turtles-own [
  similar-around
  other-around
  total-around
  similartopatch?
  turtles-moved?
]

to setup
ca
createregions
introduceagents
set rural-to-urban 0
set urban-to-rural 0
reset-ticks
end

to createregions
  if mode = "all urban" [
    ask patch 0 0 [
      set pcolor 95
      set number-of-jobs random-normal Mean_Jobs_Urban Stdev_Jobs_Urban
      set wage random-normal Mean_Wage_Urban Stdev_Wage_Urban
      set my-patches patches with [
        pycor < [pycor] of myself + 21 and
        pycor > [pycor] of myself - 21 and
        pxcor > [pxcor] of myself - 21 and
        pxcor < [pxcor] of myself + 21
      ]
     set seeds random-float 100
     ask my-patches [
        set pcolor [pcolor] of myself
        set number-of-jobs ([number-of-jobs] of myself)
        set wage ([wage] of myself)
        set seeds ([seeds] of myself)
      ]
    set vacancies number-of-jobs - ( count turtles-on patches with [number-of-jobs = [number-of-jobs] of myself])
    ask my-patches [
    set vacancies ([vacancies] of myself)
    ]
  ]
  ]

  if mode = "multiples"[
  ask patches with [ pxcor mod 5 = 0 and pycor mod 5 = 0 ] [
;      ask patches with [ pxcor mod random-normal 6 1  = 0 and pycor mod random-normal 6 1  = 0 ] [
      set pcolor one-of [95 75]
      if pcolor = 75 [set number-of-jobs random-normal Mean_Jobs_Rural Stdev_Jobs_Rural ]
      if pcolor = 95 [ set number-of-jobs random-normal Mean_Jobs_Urban Stdev_Jobs_Urban ]
      ifelse pcolor = 95 [ set wage random-normal Mean_Wage_Urban Stdev_Wage_Urban] [set wage random-normal Mean_Wage_Rural Stdev_Wage_Rural]
      set my-patches patches with [
        pxcor > [pxcor] of myself - 3 and
        pxcor < [pxcor] of myself + 3 and
        pycor > [pycor] of myself - 3 and
        pycor < [pycor] of myself + 3
      ]

      set seeds random-float 100
      ask my-patches [
        set pcolor [pcolor] of myself
        set number-of-jobs ([number-of-jobs] of myself)
        set wage ([wage] of myself)
        set seeds ([seeds] of myself)

      ]

     set vacancies (number-of-jobs -( count turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]))

  ask my-patches [
    set vacancies ([vacancies] of myself)
      ]


  let urban patches with [pcolor = 95]
  let rural patches with [pcolor = 75]

]
  ]

  if mode = "one rural and one urban" [
  let rural patches with [pxcor = 0  and pycor = 0]
  let urban patches with [pxcor = 0 and pycor =  1]
  ask rural [set pcolor 75 set number-of-jobs random-normal Mean_Jobs_Rural Stdev_Jobs_Rural
      set wage random-normal Mean_Wage_Rural Stdev_Wage_Rural
      set seeds random-float 100
      set my-patches patches with [
        pycor <= [pycor] of myself and
        pxcor > [pxcor] of myself - 21 and
        pxcor < [pxcor] of myself + 21
    ]

    ask my-patches [
        set pcolor [pcolor] of myself
        set number-of-jobs ([number-of-jobs] of myself)
        set wage ([wage] of myself)
        set seeds ([seeds] of myself)
    ]
     set vacancies number-of-jobs - (count turtles-on patches with [number-of-jobs = [number-of-jobs] of self])
      ask my-patches[set vacancies [vacancies] of myself]
    ]

  ask urban [set pcolor 95 set number-of-jobs random-normal Mean_Jobs_Urban Stdev_Jobs_Urban
      set wage random-normal Mean_Wage_Urban Stdev_Wage_Urban
      set seeds random-float 100
       set my-patches patches with [
        pycor >= [pycor] of myself and
        pxcor > [pxcor] of myself - 21 and
        pxcor < [pxcor] of myself + 21
      ]

      ask my-patches [
        set pcolor [pcolor] of myself
        set number-of-jobs ([number-of-jobs] of myself)
        set wage ([wage] of myself)
        set seeds ([seeds] of myself)
    ]

      set vacancies number-of-jobs - (count turtles-on patches with [number-of-jobs = [number-of-jobs] of self])
      ask my-patches[set vacancies [vacancies] of myself]
    ]
  ]

end

to introduceagents
create-turtles people
[
    set label who
    set shape one-of [ "person business" "person farmer"]
    set color white
    set size 1.8
    setxy random-xcor random-ycor
  ]

end

to go
if mode_order = "different order" [
  ask n-of (people / 2) turtles [
    set similar-around count (turtles-on patches with [number-of-jobs = [number-of-jobs] of myself])  with [ shape = [ shape ] of myself ]
    set other-around count (turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]) with [ shape != [ shape ] of myself ]
    set total-around similar-around + other-around
    set similartopatch? similar-around >= (%-similar-wanted * total-around / 100)
    ]
  ask patches [
  set vacancies (number-of-jobs -( count turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]))
  ifelse vacancies >= 0 [
  set utility (vacancies * wage)] [set utility (0.00000000001 * wage)]

   ]
    ask n-of (people / 2) turtles [
  ;;;;;;;;;;;;;;;;;;; DECIDE MIGRATE ALL URBAN MODE ;;;;;;;;;;;;;;;
  ifelse mode = "all urban"  [
  let location max-one-of patches [utility]
  if [utility] of location > (([utility] of patch-here))
  [move-to location  set turtles-moved? true]
  ifelse (([number-of-jobs] of patch-here) >= count (turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]))
        [ask turtles-on patches with [number-of-jobs = [number-of-jobs] of myself] [set color yellow]]
        [if ticks < 1 [changestatus]  ]
      ]
   ;;;;;;;;;;; DECIDE MIGRATE FOR OTHER MODES ;;;;;;;;;;;
  [
  ifelse similartopatch? = nobody
  [set utility utility * random-float (0.8 - 0.79 + 1) + 0.79][set utility utility * random-float (1.2 - 1.19 + 1) + 1.19]
  let location max-one-of patches [utility]
  changestatus
  if ([utility] of location > (([utility] of patch-here) * 1.5))
  [move-to location    set turtles-moved? true]
  if ticks > 0 and ticks mod 3 = 0 [changestatus]
  ifelse [pcolor] of location = 75 [
    if [pcolor] of location != [pcolor] of patch-here [set urban-to-rural urban-to-rural + 1]]
   [if [pcolor] of location != [pcolor] of patch-here [set rural-to-urban rural-to-urban + 1]]
    ]
    ]

  if ticks > 0 and ticks mod 5 = 0 [ask n-of (people / 2) turtles [

    set similar-around count (turtles-on patches with [number-of-jobs = [number-of-jobs] of myself])  with [ shape = [ shape ] of myself ]
    set other-around count (turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]) with [ shape != [ shape ] of myself ]
    set total-around similar-around + other-around
    set similartopatch? similar-around >= (%-similar-wanted * total-around / 100)
    ]
  ask patches [

   set vacancies (number-of-jobs -( count turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]))
   ifelse vacancies >= 0
      [set utility (vacancies * wage)] [set utility (0.00000000001 * wage)]
   ]
    ask n-of (people / 2) turtles [
ifelse mode = "all urban"  [
  let location max-one-of patches [utility]
 if [utility] of location > (([utility] of patch-here))
[move-to location  set turtles-moved? true]
if ticks < 1[changestatus]
ifelse [pcolor] of location = 75 [
    if [pcolor] of location != [pcolor] of patch-here [set urban-to-rural urban-to-rural + 1]]
  [if [pcolor] of location != [pcolor] of patch-here [set rural-to-urban rural-to-urban + 1]]
]


  [
  ifelse similartopatch? = nobody
  [set utility utility * random-float (0.8 - 0.79 + 1) + 0.79][set utility utility * random-float (1.2 - 1.19 + 1) + 1.19]
  let location max-one-of patches [utility]
  if ([utility] of location > (([utility] of patch-here) * 1.5))
  [move-to location  set turtles-moved? true]
    if ticks > 0 and ticks mod 3 = 0 [changestatus]
  ifelse [pcolor] of location = 75 [
  if [pcolor] of location != [pcolor] of patch-here [set urban-to-rural urban-to-rural + 1]]
  [if [pcolor] of location != [pcolor] of patch-here [set rural-to-urban rural-to-urban + 1]]
]

    ]
      ]
  ]


  if mode_order = "same order" [
  ask turtles [

    set similar-around count (turtles-on patches with [number-of-jobs = [number-of-jobs] of myself])  with [ shape = [ shape ] of myself ]
    set other-around count (turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]) with [ shape != [ shape ] of myself ]
    set total-around similar-around + other-around
    set similartopatch? similar-around >= (%-similar-wanted * total-around / 100)
    ]
  ask patches [
  set vacancies (number-of-jobs -( count turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]))
  ifelse vacancies >= 0
      [set utility (vacancies * wage)] [set utility (0.00000000001 * wage)]

   ]
    ask turtles [
ifelse mode = "all urban"  [
  let location max-one-of patches [utility]
  if [utility] of location > (([utility] of patch-here))
  [move-to location  set turtles-moved? true]
  if ticks < 1 [changestatus]
      ]
  [
  ifelse similartopatch? = nobody
  [set utility utility * random-float (0.8 - 0.79 + 1) + 0.79][set utility utility * random-float (1.2 - 1.19 + 1) + 1.19]
  let location max-one-of patches [utility]
  changestatus
  if ([utility] of location > (([utility] of patch-here) * 1.5))
  [move-to location    set turtles-moved? true]
  if ticks > 0 and ticks mod 3 = 0 [changestatus]
  ifelse [pcolor] of location = 75 [
    if [pcolor] of location != [pcolor] of patch-here [set urban-to-rural urban-to-rural + 1]]
   [if [pcolor] of location != [pcolor] of patch-here [set rural-to-urban rural-to-urban + 1]]
    ]
    ]
  ]

tick
end
to changestatus

let region-pop count turtles-on patches with [number-of-jobs = [number-of-jobs] of myself]
set unemployment ( region-pop  - (floor ([number-of-jobs] of patch-here)))
set employment  (floor [number-of-jobs] of patch-here)

ifelse (region-pop > floor ([number-of-jobs] of patch-here))
[ask n-of unemployment turtles [set color red]
 ask n-of employment turtles [set color yellow]
  ]
 [set color yellow]

end
@#$#@#$#@
GRAPHICS-WINDOW
200
14
741
556
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
6
17
69
50
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

SLIDER
5
59
177
92
People
People
10
500
70.0
1
1
NIL
HORIZONTAL

BUTTON
72
17
135
50
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
1

BUTTON
137
17
200
50
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
96
177
129
%-similar-wanted
%-similar-wanted
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
5
209
177
242
Mean_Jobs_Rural
Mean_Jobs_Rural
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
1
246
173
279
Stdev_Jobs_Rural
Stdev_Jobs_Rural
0
5
0.0
1
1
NIL
HORIZONTAL

SLIDER
4
134
176
167
Mean_Jobs_Urban
Mean_Jobs_Urban
5
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
4
171
176
204
Stdev_Jobs_Urban
Stdev_Jobs_Urban
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
2
283
174
316
Mean_Wage_Urban
Mean_Wage_Urban
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
2
320
174
353
Stdev_Wage_Urban
Stdev_Wage_Urban
0
50
0.0
1
1
NIL
HORIZONTAL

SLIDER
1
356
173
389
Mean_Wage_Rural
Mean_Wage_Rural
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
2
394
174
427
Stdev_Wage_Rural
Stdev_Wage_Rural
0
50
0.0
1
1
NIL
HORIZONTAL

CHOOSER
2
431
174
476
mode
mode
"multiples" "one rural and one urban" "all urban"
1

PLOT
749
338
1010
488
People By Region Type
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13791810 true "" "plot count turtles-on patches with [pcolor = 95]"
"pen-1" 1.0 0 -13840069 true "" "plot count turtles-on patches with [pcolor = 75]"

CHOOSER
2
481
174
526
mode_order
mode_order
"same order" "different order"
1

MONITOR
1127
494
1221
539
unemployment
count turtles with [color = red]
17
1
11

MONITOR
758
493
862
538
turtles on blue
count turtles-on patches with [pcolor = 95]
17
1
11

MONITOR
868
493
975
538
turtles on green
count turtles-on patches with [pcolor = 75]
17
1
11

PLOT
1233
172
1459
322
Utility Urban vs Employment
Utility
Employment
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -14454117 true "" "plotxy mean [utility] of patches with [pcolor = 95] sum [employment] of turtles-on patches with [pcolor = 95]"

PLOT
1238
10
1460
160
Employment Urban
NIL
NIL
0.0
2.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -13791810 true "set-histogram-num-bars 2" "histogram [employment] of turtles-on patches with [pcolor = 95]"

PLOT
1015
10
1233
159
Employment Rural
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -14439633 true "set-histogram-num-bars 2" "histogram [employment] of turtles-on patches with [pcolor = 75]"

PLOT
1008
174
1229
324
Similar-to-Patch VS Migrations
similar to patch
turtles moved
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy count turtles with [similartopatch? = true] count turtles with [turtles-moved? = true]"

MONITOR
1249
341
1439
386
Similar To Patch Threshold TRUE
count turtles with [similartopatch? = true]
2
1
11

PLOT
746
174
1003
324
Average Employment by Region
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"urban" 1.0 0 -13791810 true "" "plot mean [employment] of turtles-on patches with [pcolor = 95]"
"rural" 1.0 0 -13840069 true "" "plot mean [employment] of turtles-on patches with [pcolor = 75]"

PLOT
748
10
1010
160
Employed VS Unemployed
Employed
Unemployed
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"employed" 1.0 0 -1184463 true "" "plot count turtles with [color = yellow]"
"unemployed" 1.0 0 -2674135 true "" "plot count turtles with [color = red]"

PLOT
1014
338
1234
488
Utility Rural VS Employment
Utility
Employment
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -12087248 true "" "plotxy mean [utility] of patches with [pcolor = 75] sum [employment] of turtles-on patches with [pcolor = 75]"

MONITOR
1030
494
1119
539
employment
count turtles with [color = yellow]
17
1
11

PLOT
1249
389
1449
539
Average Utility by Region
Ticks
Average Utility
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -14439633 true "" "plot mean [utility] of patches with [pcolor = 75]"
"pen-1" 1.0 0 -14454117 true "" "plot mean [utility] of patches with [pcolor = 95]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

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

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

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
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
