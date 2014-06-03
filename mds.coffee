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

	## add :: Shape -> IO ()
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

	## prepareTr :: Shape -> Boolean -> $
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

	## remove :: Shape -> Maybe Boolean -> IO ()
	remove: (shape, parentDone) ->
		@shapeList = (s for s in @shapeList when s != shape)
		$ "#prop-#{shape.html_id}, #anime-#{shape.html_id}, #shape-#{shape.html_id}, #select-#{shape.html_id}"
			.remove()
		@remove s, true for s in shape.children
		if shape.parent?
			@remove shape.parent unless parentDone?

	## reload :: Shape -> IO ()
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

	## refresh :: IO ()
	refresh: ->
		$ '#canvas'
			.html $('#canvas').html()

	## select :: Shape -> IO ()
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

	## unselect :: Shape -> IO ()
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

	## toggleSelect :: Shape -> IO ()
	toggleSelect: (shape) ->
		if shape.selected
			@unselect shape
		else
			@select shape

	## unselectAll :: Maybe Shape -> IO ()
	unselectAll: (select) ->
		try
			@unselect shape for shape in @shapeList when shape.selected and shape != select
		catch err
			debug err

	## show :: Shape -> IO ()
	show: (shape) ->
		shape.visible = true
		$ "#shape-#{shape.html_id}, #prop-#{shape.html_id}, #anime-#{shape.html_id}"
			.css 'display', 'table-row'

	## hide :: Shape -> IO ()
	hide: (shape) ->
		shape.visible = false
		$ "#shape-#{shape.html_id}, #prop-#{shape.html_id}, #anime-#{shape.html_id}"
			.css 'display', 'none'

	## onClick :: Event -> IO ()
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

	## setMode :: ('none' | 'point' | 'line' | 'bezeir' | 'anime') -> IO ()
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

	## setFrame :: Int -> IO ()
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

	## moveStartFrame :: Int -> IO ()
	moveStartFrame: (d) ->
		unless 0 <= @frameShowStart + d <= view_sec * FPS - @animationFrameLength
			return false
		@frameShowStart += d
		@reload s for s in @shapeList
		true
