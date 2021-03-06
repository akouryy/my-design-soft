class Shape

	visible: false

	selected: false

	## constructor :: Maybe (Shape -> Int) -> IO ()
	constructor: (parent, index) ->
		@children = []
		@cs = {
			0: [255, 0, 0]
		}
		@parent = parent ? null
		@html_id = if parent? then "#{parent.html_id}-#{index}" else MDS.html_id++
		@parent?.children.push this

	## setColor :: Int -> Int -> Int -> Maybe Int -> IO ()
	setColor: (r, g, b, f = MDS.editFrame) ->
		@cs[f] = [r, g, b]

	## getColor :: Maybe Int -> {r: Int, g: Int, b: Int}
	getColor: (f = MDS.editFrame) ->
		oldF = -1
		[oldR, oldG, oldB] = @cs[0]
		for newF, [newR, newG, newB] of @cs
			if newF >= f
				return {
					r: oldR + (newR - oldR) // (newF - oldF) * (f - oldF)
					g: oldG + (newG - oldG) // (newF - oldF) * (f - oldF)
					b: oldB + (newB - oldB) // (newF - oldF) * (f - oldF)
				}
			oldF = newF
			oldR = newR
			oldG = newG
			oldB = newB
		return {r: oldR, g: oldG, b: oldB}

	## toSvg :: Maybe Int -> $
	toSvg: (f = MDS.editFrame) ->
		pass

	## updateSvg :: $ -> Maybe Int -> IO ()
	updateSvg: (svg, f = MDS.editFrame) ->
		pass

	## toTr :: Maybe Int -> $
	toTr: (f = MDS.editFrame) ->
		pass

	## updateTr :: $ -> Maybe Int -> IO ()
	updateTr: (tr, f = MDS.editFrame) ->
		pass

	## coverRect :: Maybe Int -> [[Int, Int], [Int, Int]]
	coverRect: (f = MDS.editFrame) ->
		pass

class Pointlike extends Shape

	## constructor :: Maybe (Shape -> Int) -> IO ()
	constructor: (parent, index) ->
		super parent, index 

class Point extends Pointlike

	MDS.shapeTypes['point'] = @

	shapeName: '点'

	posStr: (f = MDS.editFrame) ->
		[x, y] = @get f
		"(#{x}, #{y})"

	## constructor :: Maybe (Shape -> Int) -> IO ()
	constructor: (parent, index) ->
		@ps = {}
		super parent, index

	## set :: Int -> Int -> Maybe Int -> IO ()
	set: (x, y, f = MDS.editFrame) ->
		@ps[f] = [x, y]

	## get :: Maybe Int -> [Int, Int]
	get: (f = MDS.editFrame) ->
		oldF = -1
		[oldX, oldY] = @ps[0]
		for newF, [newX, newY] of @ps
			if newF >= f
				return [
					oldX + (newX - oldX) // (newF - oldF) * (f - oldF)
					oldY + (newY - oldY) // (newF - oldF) * (f - oldF)
				]
			oldF = newF
			oldX = newX
			oldY = newY
		return [oldX, oldY]

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

	shapeName: '直線'

	posStr: (f = MDS.editFrame) ->
		[x1, y1] = @s.get f
		[x2, y2] = @e.get f
		"(#{x1}, #{y1}) (#{x2}, #{y2})"

	## constructor :: Maybe (Shape -> Int) -> IO ()
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

	shapeName: 'ベジェ曲線'

	posStr: (f = MDS.editFrame) ->
		[x1, y1] = @s.get f
		[x2, y2] = @c1.get f
		[x3, y3] = @c2.get f
		[x4, y4] = @e.get f
		"(#{x1}, #{y1}) (#{x2}, #{y2}) (#{x3}, #{y3}) (#{x4}, #{y4})"

	## constructor :: Maybe (Shape -> Int) -> IO ()
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
			[a, b, c, d] = [
				-(p0 - 3 * p1 + 3 * p2 - p3)
				3 * p0 - 6 * p1 + 3 * p2
				-(3 * p0 - 3 * p1)
				p0
			]
			f = (k) -> (a * k ** 3) + (b * k ** 2) + (c * k) + d
			max = Math.max f(0), f(1)
			min = Math.min f(0), f(1)
			if a != 0
				D_ = b ** 2 - 3 * a * c
				if D_ > 0
					α = (-b - Math.sqrt b ** 2 - 3 * a * c) / (3 * a)
					β = (-b + Math.sqrt b ** 2 - 3 * a * c) / (3 * a)
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
