debug = (x) ->
	alert x
	console.log x
pass = undefined
RGBToHex = (rgb) ->
	hex = [
		rgb.r.toString 16
		rgb.g.toString 16
		rgb.b.toString 16
	]
	for val, i in hex
		if val.length == 1
			hex[i] = "0#{val}"
	hex.join ''
FPS = 10
view_sec = 10
MDS =
	shapeTypes: {}
	selectedMainly: null
	selectedTop: null
	shapeList: []
	html_id: 0
	mode: 'none'
	handlingShape: null
	nextIndex: 0
	editFrame: 0
	animationFrameLength : 80
	frameShowStart : 0
	add: (shape) ->
		@shapeList.push shape
		$s = $ shape.toSvg()
				 .attr 'id', "shape-#{shape.html_id}"
		$ '#canvas svg'
			.append $s
		propTr = @prepareTr shape, false
		animeTr = @prepareTr shape, true
		if shape.children.length == 0
			$ '#objects table'
				.append propTr
			$ '#animations table'
				.append animeTr
		else
			$ "#prop-#{shape.children[0].html_id}"
				.before propTr
			$ "#anime-#{shape.children[0].html_id}"
				.before animeTr
		[[x1, y1], [x2, y2]] = shape.coverRect()
		$ '<rect fill="none" stroke="#333" stroke-dasharray="5,10"/>'
			.attr
				x: x1
				y: y1
				width: x2 - x1
				height: y2 - y1
				id: "select-#{shape.html_id}"
			.css 'display', 'none'
			.appendTo '#canvas svg'
		@hide s for s in shape.children
		@select shape unless shape.parent?
	prepareTr: (shape, isAnime) ->
		tr = $ shape.toTr()
		if isAnime
			tr.attr 'id', "anime-#{shape.html_id}"
			for i in [@frameShowStart ... @frameShowStart + @animationFrameLength]
				do (td = $ "<td class='anime-grid' data-frame='#{i}'>　</td>") =>
					td.data frame: i
					if i == @editFrame
						td.addClass 'anime-grid-editing'
					if i % FPS == 0
						td.addClass 'bold-grid-line'
					else if i % (FPS / 2) == 0
						td.addClass 'thin-grid-line'
					td
						.click ->
							MDS.setFrame td.data 'frame'
						.contextMenu 'control-point-menu',
							bindings:
								'select-object-frame': =>
									@select shape
									@setFrame td.data 'frame'
								'select-object': =>
									@select shape
								'select-frame': =>
									@setFrame td.data 'frame'
								'delete-object': =>
									@remove shape
								'delete-control-point': =>
									delete shape.ps[td.data 'frame']
									td.removeClass 'grid-control-point'
							menuStyle:
								'border-radius': '1px'
								'background-color': '#eee'
								width: '150px'
					tr.append td
			if shape.ps?
				for i, _ of shape.ps
					tr.children "[data-frame=#{i}]"
						.addClass 'grid-control-point'
#			td = $ "<td class='anime-grid' data-frame='???'></td>"
#			tr.append td
		else
			tr.attr 'id', "prop-#{shape.html_id}"
			tr.append $ '<td/>'
		tr.children '.html-id, .shape-type'
			.contextMenu 'object-menu',
				bindings:
					'delete-object': (t) =>
						@remove shape
					'select-object': (t) =>
						@toggleSelect shape
				menuStyle:
					'border-radius': '1px'
					'background-color': '#eee'
					width: '150px'
			.click =>
				@toggleSelect shape
				false
		tr
	remove: (shape, parentDone) ->
		@shapeList = (s for s in @shapeList when s != shape)
		$ "#prop-#{shape.html_id}, #anime-#{shape.html_id}, #shape-#{shape.html_id}, #select-#{shape.html_id}"
			.remove()
		@remove s, true for s in shape.children
		if shape.parent?
			@remove shape.parent unless parentDone?
	reload: (shape) ->
		$ "#shape-#{shape.html_id}"
			.replaceWith $(shape.toSvg()).attr 'id', "shape-#{shape.html_id}"
		r = shape.coverRect()
		[[x1, y1], [x2, y2]] = shape.coverRect()
		$ "#select-#{shape.html_id}"
			.attr
				x: x1
				y: y1
				width: x2 - x1
				height: y2 - y1
		$ 'th[data-frame]'
			.remove()
		for i in [@frameShowStart ... @frameShowStart + @animationFrameLength]
			$ "<th data-frame=#{i} class='#{
				if i == MDS.editFrame
					'anime-grid-editing '
				else
					''
			} #{
				if i % FPS == 0
					"bold-grid-line'>#{i}"
				else if i % (FPS / 2) == 0
					"thin-grid-line'>#{i}"
				else
					"'>"
			}</th>"
				.data frame: i
				.appendTo $ '#animations .header'
		propTr = @prepareTr shape, false
		animeTr = @prepareTr shape, true
		if shape.selected
			propTr.addClass 'prop-selected'
			animeTr.addClass 'prop-selected'
		$ "#prop-#{shape.html_id}"
			.replaceWith propTr
		$ "#anime-#{shape.html_id}"
			.replaceWith animeTr
		@reload shape.parent if shape.parent?
		@refresh()
	refresh: ->
		$ '#canvas'
			.html $('#canvas').html()
	select: (shape) ->
		try
			@unselectAll shape.parent
			@selectedMainly = shape
			@selectedTop = shape unless shape.parent?
			shape.selected = true
			$ "#prop-#{shape.html_id}, #anime-#{shape.html_id}"
				.addClass 'prop-selected'
			$ "#select-#{shape.html_id}"
				.css 'display', 'inline'
			$ '#change-color'
				.ColorPickerSetColor shape.getColor()
			@show s for s in shape.children
		catch err
			debug err
	unselect: (shape) ->
		try
			if shape == @selectedMainly
				@selectedMainly = shape.parent ? null
			else
				@selectedMainly = null
			if shape == @selectedTop
				@selectedTop = null
			shape.selected = false
			$ "#prop-#{shape.html_id}, #anime-#{shape.html_id}"
				.removeClass 'prop-selected'
			$ "#select-#{shape.html_id}"
				.css 'display', 'none'
			@unselect s for s in shape.children
			@hide s for s in shape.children
		catch err
			debug err
	toggleSelect: (shape) ->
		if shape.selected
			@unselect shape
		else
			@select shape
	unselectAll: (select) ->
		try
			@unselect shape for shape in @shapeList when shape.selected and shape != select
		catch err
			debug err
	show: (shape) ->
		shape.visible = true
		$ "#shape-#{shape.html_id}, #prop-#{shape.html_id}, #anime-#{shape.html_id}"
			.css 'display', 'table-row'
	hide: (shape) ->
		shape.visible = false
		$ "#shape-#{shape.html_id}, #prop-#{shape.html_id}, #anime-#{shape.html_id}"
			.css 'display', 'none'
	onClick: (ev) ->
		try
			switch @mode
				when 'none'
					pass
				when 'point'
					@unselectAll()
					p = new Point()
					p.set ev.pageX, ev.pageY, 0
					@add p
					@refresh()
				when 'line', 'bezeir'
					@unselectAll()
					unless @handlingShape?
						@nextIndex = 0
						@handlingShape = new @shapeTypes[@mode]()
					@handlingShape.children[@nextIndex].set ev.pageX, ev.pageY, 0
					@add @handlingShape.children[@nextIndex]
					@refresh()
					@nextIndex++
					if @nextIndex == @handlingShape.children.length
						@add @handlingShape
						@handlingShape = null
						@refresh()
				when 'move'
					unless @selectedMainly instanceof Pointlike
						alert "#{@selectedMainly.constructor.name}は動かせません"
						return
					@selectedMainly.set ev.pageX, ev.pageY
					@reload @selectedMainly
					@refresh()
		catch err
			debug err
	setMode: (mode) ->
		switch @mode
			when 'none'
				pass
			when 'point', 'line', 'bezeir'
				pass
			when 'anime'
				$ '#animations'
					.hide 100
		@mode = mode
		@remove @handlingShape if @handlingShape?
		@handlingShape = null
		@nextIndex = 0
		switch @mode
			when 'none'
				pass
			when 'point', 'line', 'bezeir'
				pass
			when 'anime'
				$ '#animations'
					.show 1000
	setFrame: (frame) ->
		@editFrame = frame
		$ '#animation-range'
			.val frame
		$ '.anime-grid-editing'
			.removeClass 'anime-grid-editing'
		$ "#animations [data-frame=#{frame}]"
			.addClass 'anime-grid-editing'
		for s in @shapeList
			s.updateSvg $("#shape-#{s.html_id}"), frame
			s.updateTr $("#prop-#{s.html_id}, #anime-#{s.html_id}"), frame
			[[x1, y1], [x2, y2]] = s.coverRect frame
			$ "#select-#{s.html_id}"
				.attr
					x: x1
					y: y1
					width: x2 - x1
					height: y2 - y1
	moveStartFrame: (d) ->
		unless 0 <= @frameShowStart + d <= view_sec * FPS - @animationFrameLength
			return false
		@frameShowStart += d
		@reload s for s in @shapeList
		true
class Shape
	visible: false
	selected: false
	constructor: (parent, index) ->
		@children = []
		@cs = {
			0: [255, 0, 0]
		}
		@parent = parent ? null
		@html_id = if parent? then "#{parent.html_id}-#{index}" else MDS.html_id++
		@parent?.children.push this
	setColor: (r, g, b, f = MDS.editFrame) ->
		@cs[f] = [r, g, b]
	getColor: (f = MDS.editFrame) ->
		oldF = -1
		[oldR, oldG, oldB] = @cs[0]
		for newF, [newR, newG, newB] of @cs
			if newF >= f
				return {
					r: Math.floor oldR + (newR - oldR) / (newF - oldF) * (f - oldF)
					g: Math.floor oldG + (newG - oldG) / (newF - oldF) * (f - oldF)
					b: Math.floor oldB + (newB - oldB) / (newF - oldF) * (f - oldF)
				}
			oldF = newF
			oldR = newR
			oldG = newG
			oldB = newB
		return {
			r: Math.floor oldR
			g: Math.floor oldG
			b: Math.floor oldB
		}
	toSvg: (f = MDS.editFrame) ->
		pass
	updateSvg: (svg, f = MDS.editFrame) ->
		pass
	toTr: (f = MDS.editFrame) ->
		pass
	updateTr: (tr, f = MDS.editFrame) ->
		pass
	coverRect: (f = MDS.editFrame) ->
		pass
class Pointlike extends Shape
	constructor: (parent, index) ->
		super parent, index 
class Point extends Pointlike
	MDS.shapeTypes['point'] = @
	constructor: (parent, index) ->
		@ps = {}
		super parent, index
	set: (x, y, f = MDS.editFrame) ->
		@ps[f] = [x, y]
	get: (f = MDS.editFrame) ->
		oldF = -1
		[oldX, oldY] = @ps[0]
		for newF, [newX, newY] of @ps
			if newF >= f
				return [
					Math.floor oldX + (newX - oldX) / (newF - oldF) * (f - oldF)
					Math.floor oldY + (newY - oldY) / (newF - oldF) * (f - oldF)
				]
			oldF = newF
			oldX = newX
			oldY = newY
		return [
			Math.floor oldX
			Math.floor oldY
		]
	toSvg: (f = MDS.editFrame) ->
		[x, y] = @get f
		if @parent?
			"<circle cx='#{x}' cy='#{y}' r='5' fill='transparent' stroke='#00f'/>"
		else
			"<circle cx='#{x}' cy='#{y}' r='2' fill='##{RGBToHex @getColor f}'/>"
	updateSvg: (svg, f = MDS.editFrame) ->
		[x, y] = @get f
		svg.attr
			cx: x
			cy: y
		unless @parent?
			svg.attr
				fill: '#' + RGBToHex @getColor f
	toTr: (f = MDS.editFrame) ->
		[x, y] = @get f
		"<tr><td class='html-id' title='点(#{x}, #{y})'>#{@html_id}</td>
			 <td class='shape-type' title='(#{x}, #{y})'>Point</td></tr>"
	updateTr: (tr, f = MDS.editFrame) ->
		[x, y] = @get f
		tr.children '.html-id'
			.attr title: "点(#{x}, #{y})"
		tr.children '.shape-type'
			.attr title: "(#{x}, #{y})"
	coverRect: (f = MDS.editFrame) ->
		[x, y] = @get f
		if @parent?
			[
				[x - 6, y - 6]
				[x + 6, y + 6]
			]
		else
			[
				[x - 3, y - 3]
				[x + 3, y + 3]
			]
class Line extends Shape
	MDS.shapeTypes['line'] = @
	constructor: (parent, index) ->
		super parent, index
		@s = new Point this, 0
		@e = new Point this, 1
	toSvg: (f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[ex, ey] = @e.get f
		"<line x1='#{sx}' y1='#{sy}' x2='#{ex}' y2='#{ey}' fill='none' stroke='##{RGBToHex @getColor f}'/>"
	updateSvg: (svg, f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[ex, ey] = @e.get f
		svg.attr
			x1: sx
			y1: sy
			x2: ex
			y2: ey
			stroke: '#' + RGBToHex @getColor f
	toTr: (f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[ex, ey] = @e.get f
		"<tr><td class='html-id' title='直線((#{sx}, #{sy}) (#{ex}, #{ey}))'>#{@html_id}</td>
			 <td class='shape-type' title='(#{sx}, #{sy}) (#{ex}, #{ey})'>Line</td></tr>"
	updateTr: (tr, f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[ex, ey] = @e.get f
		tr.children '.html-id'
			.attr title: "直線((#{sx}, #{sy}) (#{ex}, #{ey}))"
		tr.children '.shape-type'
			.attr title: "((#{sx}, #{sy}) (#{ex}, #{ey}))"
	coverRect: (f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[ex, ey] = @e.get f
		[
			[Math.min(sx, ex), Math.min(sy, ey)]
			[Math.max(sx, ex), Math.max(sy, ey)]
		]
class Bezeir extends Shape
	MDS.shapeTypes['bezeir'] = @
	constructor: (parent, index)->
		super parent, index
		@s = new Point this, 0
		@c1 = new Point this, 1
		@c2 = new Point this, 2
		@e = new Point this, 3
	toSvg: (f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[c1x, c1y] = @c1.get f
		[c2x, c2y] = @c2.get f
		[ex, ey] = @e.get f
		"<path d='M #{sx} #{sy} C #{c1x} #{c1y} #{c2x} #{c2y} #{ex} #{ey}' fill='none' stroke='##{RGBToHex @getColor f}'/>"
	updateSvg: (svg, f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[c1x, c1y] = @c1.get f
		[c2x, c2y] = @c2.get f
		[ex, ey] = @e.get f
		svg.attr
			d: "M #{sx} #{sy} C #{c1x} #{c1y} #{c2x} #{c2y} #{ex} #{ey}"
			stroke: '#' + RGBToHex @getColor f
	toTr: (f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[c1x, c1y] = @c1.get f
		[c2x, c2y] = @c2.get f
		[ex, ey] = @e.get f
		"<tr><td class='html-id' title='3次ベジェ曲線((#{sx}, #{sy}) (#{c1x}, #{c1y}) (#{c2x}, #{c2y}) (#{ex}, #{ey}))'>#{@html_id}</td>
			 <td class='shape-type' title='(#{sx}, #{sy}) (#{c1x}, #{c1y}) (#{c2x}, #{c2y}) (#{ex}, #{ey})'>Bezeir</td></tr>"
	updateTr: (tr, f = MDS.editFrame) ->
		[sx, sy] = @s.get f
		[c1x, c1y] = @c1.get f
		[c2x, c2y] = @c2.get f
		[ex, ey] = @e.get f
		tr.children '.html-id'
			.attr title: "3次ベジェ曲線((#{sx}, #{sy}) (#{c1x}, #{c1y}) (#{c2x}, #{c2y}) (#{ex}, #{ey}))"
		tr.children '.shape-type'
			.attr title: "(#{sx}, #{sy}) (#{c1x}, #{c1y}) (#{c2x}, #{c2y}) (#{ex}, #{ey})"
	coverRect: (f = MDS.editFrame) ->
		minmax = (p0, p1, p2, p3) ->
			[a, b, c, d] = [-(p0 - 3 * p1 + 3 * p2 - p3), 3 * p0 - 6 * p1 + 3 * p2, -(3 * p0 - 3 * p1), p0]
			f = (k) -> (a * k * k * k) + (b * k * k) + (c * k) + d
			max = Math.max f(0), f(1)
			min = Math.min f(0), f(1)
			if a != 0
				D_ = b * b - 3 * a * c
				if D_ > 0
					α = (-b - Math.sqrt b * b - 3 * a * c) / (3 * a)
					β = (-b + Math.sqrt b * b - 3 * a * c) / (3 * a)
					if 0 <= α <= 1
						max = Math.max max, f α
						min = Math.min min, f α
					if 0 <= β <= 1
						max = Math.max max, f β
						min = Math.min min, f β
			else
				if b != 0
					t = c / (2 * b)
					if 0 <= t <= 1
						max = Math.max max, f t
						min = Math.min min, f t
			return [min, max]
		[sx, sy] = @s.get f
		[c1x, c1y] = @c1.get f
		[c2x, c2y] = @c2.get f
		[ex, ey] = @e.get f
		[xmin, xmax] = minmax sx, c1x, c2x, ex
		[ymin, ymax] = minmax sy, c1y, c2y, ey
		[
			[xmin, ymin]
			[xmax, ymax]
		]
$ ->
	frame = 0
	interval = null
	isLooping = false
	$ '#mode-none'
		.click ->
			MDS.setMode 'none'
			$ '.mode-tool'
				.removeClass 'tool-selected'
			$ @
				.addClass 'tool-selected'
	$ '#draw-point'
		.click ->
			MDS.setMode 'point'
			$ '.mode-tool'
				.removeClass 'tool-selected'
			$ @
				.addClass 'tool-selected'
	$ '#draw-line'
		.click ->
			MDS.setMode 'line'
			$ '.mode-tool'
				.removeClass 'tool-selected'
			$ @
				.addClass 'tool-selected'
	$ '#draw-bezeir'
		.click ->
			MDS.setMode 'bezeir'
			$ '.mode-tool'
				.removeClass 'tool-selected'
			$ @
				.addClass 'tool-selected'
	$ '#change-color'
		.ColorPicker
			color: '#f00'
			onSubmit: (hsb, hex, rgb) ->
				MDS.selectedTop.setColor rgb.r, rgb.g, rgb.b
				MDS.reload MDS.selectedTop
	$ '#move-point'
		.click ->
			MDS.setMode 'move'
			$ '.mode-tool'
				.removeClass 'tool-selected'
			$ @
				.addClass 'tool-selected'
	$ '#animation-mode'
		.click ->
			MDS.setMode 'anime'
			$ '.mode-tool'
				.removeClass 'tool-selected'
			$ @
				.addClass 'tool-selected'
	$ '#animation-range'
		.attr max: view_sec * FPS
		.change ->
			MDS.setFrame frame = $(@).val()
	$ '#animation-start'
		.click ->
			$ '#animation-start'
				.css display: 'none'
				.addClass 'tool-selected'
			$ '#animation-pause'
				.css display: 'inline-block'
				.addClass 'tool-selected'
			$ '#animation-stop'
				.removeClass 'tool-selected'
			interval =
				setInterval =>
					frame++
					if frame >= view_sec * FPS
						frame = 0
						MDS.setFrame 0
						unless isLooping
							clearInterval interval
							$ '#animation-start'
								.css display: 'inline-block'
								.removeClass 'tool-selected'
							$ '#animation-pause'
								.css display: 'none'
								.removeClass 'tool-selected'
							$ '#animation-stop'
								.addClass 'tool-selected'
							$ '#animation-pause'
					else
						MDS.setFrame frame
				, 1000 / FPS
	$ '#animation-pause'
		.click ->
			$ '#animation-start'
				.css display: 'inline-block'
				.addClass 'tool-selected'
			$ '#animation-pause'
				.css display: 'none'
				.addClass 'tool-selected'
			$ '#animation-stop'
				.removeClass 'tool-selected'
			clearInterval interval
	$ '#animation-stop'
		.click ->
			$ '#animation-start'
				.css display: 'inline-block'
				.removeClass 'tool-selected'
			$ '#animation-pause'
				.css display: 'none'
				.removeClass 'tool-selected'
			$ '#animation-stop'
				.addClass 'tool-selected'
			clearInterval interval
			frame = 0
			MDS.setFrame 0
	$ '#animation-loop'
		.click ->
			isLooping = !isLooping
			if isLooping
				$ @
					.addClass 'tool-selected'
			else
				$ @
					.removeClass 'tool-selected'
	$ '#show-mds-info'
		.click ->
			$ '#mds-info'
				.css 'display', if $('#mds-info').css('display') == 'none' then 'block' else 'none'
			$ @
				.toggleClass 'tool-selected'
	$ '#unselect'
		.click ->
			MDS.unselectAll()
	$ '#remove'
		.click ->
			MDS.remove MDS.selectedMainly
	$ '#prev-frame'
		.click ->
			unless MDS.moveStartFrame -1
				alert '最初です'
	$ '#next-frame'
		.click ->
			unless MDS.moveStartFrame +1
				alert '最後です'
	$ '#canvas'
		.click (ev) ->
			MDS.onClick ev
	for i in [0 ... MDS.animationFrameLength]
		$ "<th data-frame=#{i} class='#{
			if i == MDS.editFrame
				'anime-grid-editing '
			else
				''
		} #{
			if i % FPS == 0
				"bold-grid-line'>#{i}"
			else if i % (FPS / 2) == 0
				"thin-grid-line'>#{i}"
			else
				"'>"
		}</th>"
			.data frame: i
			.appendTo $ '#animations .header'
