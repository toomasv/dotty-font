Red []
tabulate: function [grid code][
	block: clear [] 
	n: 0 
	repeat y grid/y [
		repeat x grid/x [
			n: n + 1 
			repend block do bind code :tabulate
		]
	]
]
print-props: func [wh][
	print ["Properties of" form type? wh ":"]
	foreach prop exclude switch type?/word wh [
		event! [system/catalog/accessors/event!]
		object! [words-of wh]
	][window face parent on-change* on-deep-change*][
		print [prop ":" mold wh/:prop]
	]
]

dr: tabulate 5x7 [copy [
	'pen 'off
	'fill-pen white 
	'circle 10 * as-pair x y 3
]]

letters-panel: [
	origin 0x0
	dots dots dots dots dots dots dots dots dots dots dots dots dots 
	dots dots dots dots dots dots dots dots dots dots dots dots dots
	return
	dots dots dots dots dots dots dots dots dots dots dots dots dots 
	dots dots dots dots dots dots dots dots dots dots dots dots dots
]
chars-panel: [
	origin 0x0
	lets lets lets lets lets lets lets lets lets lets lets lets lets 
	lets lets lets lets lets lets lets lets lets lets lets lets lets
	return
	lets lets lets lets lets lets lets lets lets lets lets lets lets 
	lets lets lets lets lets lets lets lets lets lets lets lets lets
]
change-cols: func [face op /local op!][
	op!: get op
	idx: index? find letters/pane face
	len: (x: face/size/x / dx/data - pick [1 2] op = '+) * 7
	face/size/x: face/size/x op! dx/data
	draw: face/draw ; ??
	repeat y face/size/y / dy/data - 1 [
		draw: skip draw len
		draw: either op = '+ [
			insert draw reduce [
				'pen 'off
				'fill-pen white 
				'circle as-pair x + 1 * dx/data y * dy/data 3
			]
		][
			remove/part draw 7
		]
	]
	ofx: face/offset/x
	ofy: face/offset/y
	foreach-face/with letters [
		face/offset/x: face/offset/x op! dx/data
	][
		all [
			face/offset/y = ofy 
			face/offset/x > ofx
		]
	]
	chars/pane/:idx/size/x: chars/pane/:idx/size/x op! dx/data
	ofx: chars/pane/:idx/offset/x
	ofy: chars/pane/:idx/offset/y
	foreach-face/with chars [
		face/offset/x: face/offset/x op! dx/data
	][
		all [
			face/offset/y = ofy 
			face/offset/x > ofx
		]					
	]
]
change-all-cols: func [op][
	system/view/auto-sync?: off 
	foreach-face letters [change-cols face op]
	show [letters chars]
	system/view/auto-sync?: on 
]
change-all-rows: func [op /local op!][
	system/view/auto-sync?: off
	op!: get op
	probe ofsy: unique collect [foreach fc letters/pane [keep fc/offset/y]]
	diff: 10 * length? ofsy
	letters/size/y: letters/size/y op! diff
	pan/size/y: pan/size/y op! diff
	foreach-face letters [
		y: face/size/y
		face/size/y: face/size/y op! 10
		draw: tail face/draw
		repeat x face/size/x / 10 - 1 [
			draw: either op = '+ [
				insert draw reduce [
					'pen 'off
					'fill-pen white 
					'circle as-pair x * 10 y 3
				]
			][
				draw: skip draw -7
				remove/part draw 7
			]
		]
	]
	foreach face letters/pane [
		i: (index? find ofsy face/offset/y) - 1
		face/offset/y: face/offset/y op! (10 * i)
	]
	chars/offset/y: chars/offset/y op! diff
	foreach elem reduce [pan tabs][
		elem/size/y: elem/size/y op! diff
	]
	show lay
	system/view/auto-sync?: off
]
set-letter: func [face][
	idx: index? find letters/pane face 
	if attempt [ch: first chars/pane/:idx/text][
		chars/pane/:idx/color: 230.230.230
		face/extra: make map! compose/only [
			char: (ch) 
			size: (face/size / 10 - 1)
			dots: (parse face/draw [
				(n: 0) 
				collect any [
					s: tuple! (n: n + 1) if (s/1 = black) keep (n) 
				| 	skip
				]
			])
		]
	]
]
letter-actors: [
	on-menu [
		switch event/picked [
			clear [parse face/draw [any [change 0.0.0 255.255.255 | skip]]]
			set [set-letter face]
			add-column [change-cols face '+]
			add-letter [
				letter: find letters/pane face
				idx: index? next letter
				ofs: letter/1/offset
				sz: letter/1/size
				ofs: as-pair ofs/x + sz/x + 10 ofs/y
				letter: insert next letter make face! [
					type: 'base
					offset: ofs
					size: sz
					menu: letter-template/menu
					actors: object letter-template/actors
					draw: copy tabulate sz / 10 - 1 [
						['pen 'off 'fill-pen white 'circle as-pair 10 * x 10 * y 3]
					]
				]
				forall letter [if letter/1/offset/y = ofs/y [letter/1/offset/x: letter/1/offset/x + sz/x + 10]]
				char: at chars/pane idx
				ofs: char/-1/offset 
				char: insert char make face! [
					type: 'field 
					offset: as-pair ofs/x + sz/x + 10 ofs/y
					size: as-pair sz/x 25
					actors: object char-template/actors
				]
				forall char [if char/1/offset/y = ofs/y [char/1/offset/x: char/1/offset/x + sz/x + 10]]
			]
			add-newrow [
				system/view/auto-sync?: off
				letter: find letters/pane face
				dr: copy letter/1/draw
				parse dr [some [change 0.0.0 255.255.255 | skip]]
				idx: index? letter
				ofy: letter/1/offset/y + letter/1/size/y + 10 
				char: at chars/pane idx
				ofy2: char/1/offset/y
				sz: letter/1/size
				sz2: sz/x + 10
				repeat i 26 [
					ofx: i - 1 * sz2
					append letters/pane make face! compose/only [
						type: 'base
						offset: as-pair ofx ofy 
						size: sz
						menu: letter-template/menu
						draw: (copy dr)
						actors: object letter-template/actors
					]
					append chars/pane make face! [
						type: 'field
						offset: as-pair ofx ofy2 + 35
						size: as-pair sz/x 25
						menu: char-template/menu
						actors: object char-template/actors
					]
				]
				adjust-letter-tab-offsets
				show lay
				system/view/auto-sync?: on
			]
			remove-column [change-cols face '-]
			remove-letter [
				letter: find letters/pane face
				sz: letter/1/size
				ofs: letter/1/offset
				idx: index? letter
				remove letter
				forall letter [if letter/1/offset/y = ofs/y [letter/1/offset/x: letter/1/offset/x - sz/x - 10]]
				char: at chars/pane idx
				ofs: char/1/offset
				remove char
				forall char [if char/1/offset/y = ofs/y [char/1/offset/x: char/1/offset/x - sz/x - 10]]
			]
		]
	]
	on-down [
		parse face/draw [some [s: 
			pair! if (within? event/offset s/1 - 4 8x8) (
				s/-2: pick [255.255.255 0.0.0] s/-2 = 0.0.0
			)
		| 	skip
		]]
		idx: index? find letters/pane face
		if chars/pane/:idx/color = 230.230.230 [
			chars/pane/:idx/color: white
			face/extra: none
		]
	]
	on-over [
		if all [event/down? not event/away?][
			parse face/draw [some [s: 
				pair! if (all [within? event/offset - face/offset s/1 - 4 8x8 s/-2 = clr/extra]) (
					s/-2: 255.255.255 - clr/extra
				)
			| 	skip
			]]
			idx: index? find letters/pane face
			if chars/pane/:idx/color = 230.230.230 [
				chars/pane/:idx/color: white
				face/extra: none
			]
		]
	]
]
letter-template: [
	type: 'base
	menu: [
		"Clear" clear 
		"Set" set 
		"Add.." [
			"Column" add-column
			"Letter" add-letter
			"Return" add-return
			"New-row" add-newrow
		]
		"Remove.." [
			"Column" remove-column
			"Letter" remove-letter
		]
	]
	actors: [
		on-menu: func [face event] letter-actors/on-menu
		on-down: func [face event] letter-actors/on-down
		on-over: func [face event] letter-actors/on-over
	]
]
char-actors: [
	on-change [
		if face/color = 230.230.230 [
			face/color: white
			idx: index? find chars/pane face
			letters/pane/:idx/extra: none
		]
	]
]
char-template: [
	actors: [
		on-change: func [face event] char-actors/on-change
	]
]
adjust-letter-tab-offsets: does [
	last-letter: last letters/pane
	last-char: last chars/pane
	letters/size/y: last-letter/offset/y + last-letter/size/y + 10
	chars/offset/y: letters/offset/y + letters/size/y + 10
	chars/size/y: last-char/offset/y + last-char/size/y + 10
	pan/size/y: chars/offset/y + chars/size/y ;+ 10
	tabs/size/y: pan/size/y + 100
]
confirm-unset-letters: does [
	view/flags [
		text "There are unset letters. Proceed anyway?" return 
		button "Yes" [unset-letters?: no unview] 
		button "No" [unview]
	][modal popup]
]
compile-font: func [face][
	unset-letters?: no
	face/extra: collect [
		foreach-face letters [
			either face/extra [
				keep face/extra/char
				props: copy []
				repend props ['size face/size 'draw]
				char-draw: copy []
				parse face/draw [
					collect into char-draw some [
						0.0.0 3 [keep skip]
					| 	skip
					]
				]
				append/only props head insert char-draw [skew 0 0]
				keep/only props
			][unset-letters?: yes]
		]
	]
	if unset-letters? [confirm-unset-letters]
]
message-type: 'plain
rt-box: rtd-layout [""]
width: max-width: height: h: r: 0

fill-canvas: func [face][
	width: max-width: height: 0
	h: compiled/extra/2/size/y
	found: find compiled/extra/2/draw 'circle
	r: found/3
	clear canvas/draw
	foreach ch face/text [
		switch/default ch [
			#"^/" [width: 0 height: height + h]
		][
			repend canvas/draw ['translate as-pair width height] 
			append/only canvas/draw compiled/extra/:ch/draw
			width: width + compiled/extra/:ch/size/x
			max-width: max max-width width
		]
	]
]

letter-props: copy []
#include %../utils/rtd-simple.red
compile-rt: does [
	fill-canvas rt-box
	clear letter-props
	parse rt-box/data [some [
		set addr pair! copy props to [pair! | end](
			j: addr/1
			repeat i addr/2 [
				k: j + i - 1
				either found: select letter-props k [
					append found props
				][
					repend letter-props [k props]
				]
			]
		)
	]]
	i: 0
	parse canvas/draw [some [
		'translate pair! s: block! (
			probe i: i + 1
			if found: select letter-props i [
				probe found
				parse found [
					some [p:
						'backdrop tuple! (
							if found2: find s/1 block! [remove found2]
							width: any [attempt/safer [s/3/x - s/-1/x] width]
							insert/only s/1 reduce ['fill-pen p/2 'box 0x0 as-pair width h 'fill-pen black]
						)
					|	'italic (if found2: find/tail s/1 'skew [found2/1: -4])
					|	'bold (parse s/1 [some ['circle pair! q: change number! (q/1 * 1.3) | skip]])
					|	tuple! (either found2: find s/1 'fill-pen [found2/2: p/1][insert s/1 reduce ['fill-pen p/1]])
					;|	'strike
					;|	'underline
					;|	integer! (insert s/1 reduce ['])
					]
				]
			]
			case/all [
				all [probe any [probe not found probe not find found 'backdrop] found2: find s/1 block!] [probe "del-bg" remove found2]
				all [any [not found not find found 'italic] found2: find/tail s/1 'skew found2/1 <> 0] [probe "del-it" found2/1: 0]
				all [any [not found not find found tuple!] found2: find s/1 'fill-pen] [probe "del-clr" remove/part found2 2]
				any [not found not find found 'bold] [probe "del-bold" parse s/1 [any ['circle pair! change number! (r) | skip]]]
			]
		)
	|	skip
	]]
]
compile-message: has [rt-text s][
	system/view/auto-sync?: off
	if find [simple proper] message-type [
		rt-box/size/x: tabs/size/x - 20
	]
	switch message-type [
		plain [fill-canvas msg]
		simple [
			rtd-simple/with/width msg/text rt-box tabs/size/x - 20 
			compile-rt
		]
		proper [
			rtd-layout/with load/all msg/text rt-box
			compile-rt
		]
	]
	insert canvas/draw [pen off fill-pen black]
	canvas/size: as-pair max-width height + h
	canvas/parent/size: 20 + canvas/size
	show canvas/parent
	system/view/auto-sync?: on
]
char-draw: clear []

move-whole-msg: func [mode dir /local coord stop old-canvas][
	old-canvas: copy canvas/draw
	coord: 0x0
	stop: 0
	switch mode [
		in [
			coord: switch dir [
				right [as-pair canvas/parent/size/x 0]
				left [as-pair 0 - canvas/parent/size/x 0]
				top [as-pair 0 0 - canvas/parent/size/y]
				bottom [as-pair 0 canvas/parent/size/y]
			]
		]
		out [
			stop: switch dir [
				right [canvas/parent/size/x]
				left [0 - canvas/parent/size/x]
				top [0 - canvas/parent/size/y]
				bottom [canvas/parent/size/y]
			]
		]
	]
	canvas/draw: compose/only [
		translate (coord) (old-canvas)
	]
	reduce [coord stop]
]

msg-move-by-symbol: func [mode dir /local coord main-stop dim op current stop comp ofs next-stop][
	set [coord main-stop] move-whole-msg mode dir
	mode: to-word rejoin [mode "-" dir]
	case [
		mode = 'in-right [
			current: find/tail canvas/draw/3 'translate
			dim: 'x
			op: :-
			comp: :<=
			stop: current/1/:dim op coord/:dim
		]
		mode = 'in-left [
			current: find/reverse/tail tail canvas/draw/3 'translate
			dim: 'x
			op: :+
			comp: :>=	
			stop: current/1/:dim op absolute coord/:dim
		]
		mode = 'out-left [
			current: find/tail canvas/draw/3 'translate
			dim: 'x
			op: :-
			comp: :<=
			next-stop: either found: find/tail current 'translate [found/1/:dim][canvas/parent/size/:dim] 
			stop: 0 - next-stop
		]
		mode = 'out-right [
			current: find/reverse/tail tail canvas/draw/3 'translate
			dim: 'x
			op: :+
			comp: :>=	
			stop: move-struct/stop: canvas/parent/size/:dim
		]
	]
	ofs: current/1/:dim
	set move-struct probe reduce [coord main-stop dim :op current stop :comp ofs mode]
	print ["cur" current/1/:dim "coord" coord/:dim "stop" stop "main" main-stop "next" next-stop]
	bind msg-animate: msg-animate-move-by-symbol move-struct
]
msg-move-by-symbol2: func [current /local coord main-stop dim op ofs mode tmp next-stop][
	foreach word [coord main-stop dim ofs mode] [set word get in move-struct word]
	op: :move-struct/op
	print [type? mode mode mode = 'out-left]
	case [
		probe find [in-right out-left] mode [probe current: find/tail probe current 'translate]
		find [in-left out-right] mode [probe current: find/reverse/tail skip current -2 'translate]
	]
	either current [
		move-struct/current: current
		case [
			mode = 'in-right [
				move-struct/stop: stop: current/1/:dim op coord/:dim 
				current/1/:dim: 0
			]
			mode = 'in-left [
				move-struct/stop: stop: current/1/:dim + absolute coord/:dim
				;print ["coord" coord/:dim "ofs" ofs "cur" current/1/:dim "ofs-cur" ofs - current/1/:dim]
				tmp: current/1/:dim
				current/1/:dim: (absolute coord/:dim) - (ofs - current/1/:dim)
				move-struct/ofs: tmp
			]
			mode = 'out-left [
				next-stop: either found: find/tail current 'translate [found/1/:dim][canvas/parent/size/:dim]
				move-struct/stop: stop: 0 - (next-stop - current/1/:dim)
			]
			mode = 'out-right [
				move-struct/stop: stop: canvas/parent/size/:dim
			]
		]
		print ["cur2" current/1/:dim "stop" stop]
		bind msg-animate: msg-animate-move-by-symbol move-struct
		canvas/rate: 32
	][]
]
move-struct: object [
	coord: none
	main-stop: none
	dim: none
	op: none
	current: none
	stop: none
	comp: none
	ofs: none
	mode: none
]
msg-animate-move-by-symbol: [
	current/1/:dim: current/1/:dim op 3
	print ["in-proc curr:" current/1/:dim "stop" stop]
	if current/1/:dim comp stop [
		canvas/rate: none
		msg-move-by-symbol2 current
	]
]
msg-move: func [mode dir /local coord stop][
	set [coord stop] move-whole-msg mode dir
	msg-animate-move/stop: stop
	case [
		any [all [mode = 'in dir = 'right] all [mode = 'out dir = 'left]][
			msg-animate-move/dim: quote 'x msg-animate-move/op: quote :- msg-animate-move/comp: quote :<=
		]
		any [all [mode = 'in dir = 'left] all [mode = 'out dir = 'right]][
			msg-animate-move/dim: quote 'x msg-animate-move/op: quote :+ msg-animate-move/comp: quote :>=
		]
		any [all [mode = 'in dir = 'top] all [mode = 'out dir = 'bottom]][
			msg-animate-move/dim: quote 'y msg-animate-move/op: quote :+ msg-animate-move/comp: quote :>=
		]
		any [all [mode = 'in dir = 'bottom] all [mode = 'out dir = 'top]][
			msg-animate-move/dim: quote 'y msg-animate-move/op: quote :- msg-animate-move/comp: quote :<= 
		]
	]
	msg-animate: msg-animate-move
]
msg-animate-move: [
	dim: 'x
	op: :-
	stop: 0
	comp: :<=
	face/draw/2/:dim: face/draw/2/:dim op 3
	;print [face/draw/2/:dim stop face/draw/2/:dim = stop]
	if face/draw/2/:dim comp stop [
		face/rate: none
		;face/draw: face/draw/3
	]
]
msg-fade: func [mode][
	switch mode [
		in [
			pen: 240.240.240.0 
			msg-animate-fade/op: quote :+ 
			msg-animate-fade/stop: 255 
		]
		out [
			pen: 240.240.240.255
			msg-animate-fade/op: quote :-
			msg-animate-fade/stop: 0 
		]
	]
	repend canvas/draw [quote cover: 'fill-pen pen 'box 0x0 canvas/parent/size]
	msg-animate: msg-animate-fade
]
msg-animate-fade: [
	op: '+
	stop: 0
	cover/2/4: cover/2/4 op 2
	if cover/2/4 = stop [
		face/rate: none
		remove/part skip tail face/draw -6 tail face/draw
	]
]
msg-animate: none
view/options lay: layout compose/only/deep [
	size (system/view/screens/1/size - 30x80)
	tabs: tab-panel [
		"Letters" [
			opts: panel white [
				;origin 0x0
				button "Clear all" [
					system/view/auto-sync?: off 
					foreach-face letters [
						parse face/draw [any [change 0.0.0 255.255.255 | skip]]
					] 
					show letters
					system/view/auto-sync?: on
				]
				check "Hide white dots" [
					system/view/auto-sync?: off
					either face/data [
						foreach-face letters [
							parse face/draw [any [change 255.255.255 240.240.240 | skip]]
						]
					][
						foreach-face letters [
							parse face/draw [any [change 240.240.240 255.255.255 | skip]]
						]
					]
					show letters
					system/view/auto-sync?: on
				]
				panel white [
					origin 0x0 
					clr: radio 50 "black" data true extra 255.255.255 [
						either face/data [face/extra: 255.255.255][face/extra: 0.0.0]
					] 
					radio 50 "white"
				]
				button 40 "+ col" [change-all-cols '+]
				button 40 "- col" [change-all-cols '-]
				button 40 "+ row" [change-all-rows '+]
				button 40 "- row" [change-all-rows '-]
			
				button "Set all" [
					foreach-face letters [set-letter face]
				]
				text 20 "dx:" dx: field 40 "10" on-enter [
					system/view/auto-sync?: off
					foreach-face letters [
						face/size/x: face/size/x / dxc/data - 1 * dx/data + dx/data
						parse face/draw [some ['circle s: pair! (quote (s/1/x: s/1/x / dxc/data * dx/data)) | skip]]
					]
					dxc/text: dx/text
					show letters
					system/view/auto-sync?: on
				] at 0x0 dxc: field hidden "10"
				text 20 "dy:" dy: field 40 "10" on-enter [
					system/view/auto-sync?: off
					foreach-face letters [
						face/size/y: face/size/y / dyc/data - 1 * dy/data + dy/data
						parse face/draw [some ['circle s: pair! (quote (s/1/y: s/1/y / dyc/data * dy/data)) | skip]]
					]
					dyc/text: dy/text
					show letters
					system/view/auto-sync?: on
				] at 0x0 dyc: field hidden "10"
				text 40 "Radius:" radius: field 40 "3" on-enter [
					system/view/auto-sync?: off
					foreach-face letters [
						parse face/draw [some [
							'circle pair! change [integer! | float!] (quote (radius/data)) 
						| 	skip
						]]
					]
					show lay
					system/view/auto-sync?: on
				]
				button "Recalc" [
					system/view/auto-sync?: off
					foreach-face letters [
						face/size: face/size / (quote (as-pair dxc/data dyc/data)) - 1 * (quote (df: as-pair dx/data dy/data)) + df
						parse face/draw [some [
							'circle s: pair! (quote (
								s/1: s/1 / (as-pair dxc/data dyc/data) * as-pair dx/data dy/data
								s/2: radius/data
							))
							| 	skip
							]]
					]
					dxc/text: dx/text
					dyc/text: dy/text
					show letters
					system/view/auto-sync?: on
				]
				text 35 "Skew:" skw: field 40 "0" [
					system/view/auto-sync?: off
					foreach-face letters [face/draw/2: skw/data]
					show letters
					system/view/auto-sync?: on
				]
				compiled: button "Compile font" [compile-font face]
				button "Probe" [probe copy/part compiled/extra 4]
			]
			return
			style dots: box 60x80 draw (head insert dr [skew 0 0]) 
				with [menu: letter-template/menu];["Clear" clear "Set" set "Add col" add-col "Remove col" remove-col]]
				on-menu (letter-actors/on-menu)
				on-down (letter-actors/on-down)
				on-over (letter-actors/on-over)
			style lets: field white 60 
				on-change (char-actors/on-change)
			below pan: panel 230.230.230 loose [
				;origin 0x0
				letters: panel (letters-panel) return
				chars: panel 230.230.230 (chars-panel)
			] on-created [fy: face/offset/y] on-drag [face/offset/y: fy]
		]
		;"Font" [
		;
		;]
		;"Effects" [
		;
		;]
		"Message" [
			panel white [
				style msg-type: radio 60 [
					if face/data [
						message-type: to-word face/text
						either face/parent/type = 'panel [
							foreach-face rt-type [face/data: no]
						][
							face/parent/parent/pane/1/data: no
						]
					]
				]
				origin 0x0 pad 0x20
				msg-type 50 "Plain" data yes
				pad 0x-20 rt-type: group-box "Rich-text" [
					msg-type "Simple"
					msg-type "Proper"
				]
			]
			pad 0x20 live: check "Live" data yes
			button "Compile" [compile-message]
			button "Probe" [probe canvas/draw]
			return pad 0x-20
			msg: area 500x100 
				on-change [if live/data [compile-message]]
			return
			panel [
				canvas: box 800x300 draw []
				with [menu: [
					"Message" [
						"Whole" [
							"Move" [
								"In" [
									"From right" msg-move-in-from-right
									"From left" msg-move-in-from-left
									"From top" msg-move-in-from-top
									"From bottom" msg-move-in-from-bottom
								]
								"Out" [
									"To right" msg-move-out-to-right
									"To left" msg-move-out-to-left
									"To top" msg-move-out-to-top
									"To bottom" msg-move-out-to-bottom
								]
							]
							"Fade" [
								"In" msg-fade-in
								"Out" msg-fade-out
							]
						]
						"By line" msg-by-line
						"By column" msg-by-column
						"By word" msg-by-word
						"By symbol" [msg-by-symbol
							"Move" [
								"In" [
									"From right" msg-move-in-by-symbol-from-right
									"From left" msg-move-in-by-symbol-from-left
									"From top" msg-move-in-by-symbol-from-top
									"From bottom" msg-move-in-by-symbol-from-bottom
								]
								"Out" [
									"To right" msg-move-out-by-symbol-to-right
									"To left" msg-move-out-by-symbol-to-left
									"To top" msg-move-out-by-symbol-to-top
									"To bottom" msg-move-out-by-symbol-to-bottom
								]
							]
							"Fade" [
								"In" msg-fade-in-by-symbol
								"Out" msg-fade-out-by-symbol
							]							
						]
						"By row" msg-by-row
						"By col" msg-by-col
						"By dot" msg-by-dot
					]
					"Line" [
						"Whole" line
						"By word" line-by-word
						"By symbol" line-by-symbol
						"By row" line-by-row
						"By col" line-by-col
						"By dot" line-by-dot
					]
					"Column" [
						"Whole" column
						"By symbol" column-by-symbol
						"By row" column-by-row
						"By col" column-by-col
						"By dot" column-by-dot
					]
					"Word" [
						"Whole" word
						"By symbol" word-by-symbol
						"By row" word-by-row
						"By col" word-by-col
						"By dot" word-by-dot
					]
					"Symbol" [
						"Whole" sym
						"By row" sym-by-row
						"By col" sym-by-col
						"By dot" sym-by-dot
					]
					"Row" [
						"Whole" row
						"By word" row-by-word
						"By symbol" row-by-symbol
						"By dot" row-by-dot
					]
					"Col" [
						"Whole" col
						"By symbol" col-by-symbol
						"By dot" col-by-dot
					]
					"Dot" dot
				]]
				on-time [do bind msg-animate :face/actors/on-time]
				on-menu [
					switch event/picked [
						msg-move-in-from-right [msg-move 'in 'right]
						msg-move-in-from-left [msg-move 'in 'left]
						msg-move-in-from-top [msg-move 'in 'top]
						msg-move-in-from-bottom [msg-move 'in 'bottom]
						msg-move-out-to-right [msg-move 'out 'right]
						msg-move-out-to-left [msg-move 'out 'left]
						msg-move-out-to-top [msg-move 'out 'top]
						msg-move-out-to-bottom [msg-move 'out 'bottom]
						
						msg-fade-in [msg-fade 'in]
						msg-fade-out [msg-fade 'out]

						msg-move-in-by-symbol-from-right [msg-move-by-symbol 'in 'right]
						msg-move-in-by-symbol-from-left [msg-move-by-symbol 'in 'left]
						msg-move-in-by-symbol-from-top [msg-move-by-symbol 'in 'top]
						msg-move-in-by-symbol-from-bottom [msg-move-by-symbol 'in 'bottom]
						msg-move-out-by-symbol-to-right [msg-move-by-symbol 'out 'right]
						msg-move-out-by-symbol-to-left [msg-move-by-symbol 'out 'left]
						msg-move-out-by-symbol-to-top [msg-move-by-symbol 'out 'top]
						msg-move-out-by-symbol-to-bottom [msg-move-by-symbol 'out 'bottom]
						
						msg-fade-in-by-symbol [msg-fade-by-symbol 'in]
						msg-fade-out-by-symbol [msg-fade-by-symbol 'out]
					]
					face/rate: 32
				]
			]
		]
	]
][
	menu: [
		"File" [
			"Load.." [
				"Letters" load-letters
			] 
			"Save.." [
				"Letters" save-letters
			] 
			"Save as.." save-as 
			"Quit" quit
		]
		"Font" font
	]
	actors: object [
		on-menu: func [face event][
			switch event/picked [
				save-letters [
					unset-letters?: no
					s-letters: collect [
						foreach-face letters [
							either face/extra [
								keep face/extra
							][
								unset-letters?: yes
							]
						]
					]
					if unset-letters? [confirm-unset-letters]
					unless unset-letters? [
						either all [face/extra face/extra/letters] [
							
						][save file: request-file/save s-letters]
					]
				]
				load-letters [
					system/view/auto-sync?: off
					s-letters: load file: request-file
					clear letters/pane
					clear chars/pane
					ofs: -10x-10
					pan/visible?: no
					forall s-letters [
						ofs: case [
							1 = index? s-letters [5x5]
							(index? s-letters) % 26 = 1 [as-pair 5 ofs/y + sz/y + 5]
							'else [
								as-pair ofs/x + sz/x + 5 ofs/y
							]
						]
						;ofs: as-pair 
						;	(index? s-letters) - 1 % 26 * (s-letters/1/size/x * 10 + 20)
						;	(index? s-letters) - 1 / 26 * (s-letters/1/size/y * 10 + 20)
						sz: s-letters/1/size * 10 + 10
						append letters/pane make face! [
							type: 'base
							offset: ofs 
							size: sz
							menu: letter-template/menu
							actors: object letter-template/actors
							draw: copy head insert tabulate s-letters/1/size [
								['pen 'off 'fill-pen either find s-letters/1/dots n [0.0.0][255.255.255] 'circle as-pair 10 * x 10 * y 3]
							][skew 0 0]
						]
						append chars/pane make face! [
							type: 'field
							offset: as-pair ofs/x (index? s-letters) - 1 / 26 * 35
							size: as-pair s-letters/1/size/x * 10 + 10 25
							text: to-string s-letters/1/char
							menu: char-template/menu
							actors: object char-template/actors
						]
					]
					adjust-letter-tab-offsets
					pan/visible?: yes
					show lay
					system/view/auto-sync?: on
				]
				font [
					
				]
			]
		]
	]
]