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
